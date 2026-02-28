import Foundation
import SwiftUI
import UserNotifications
import Combine

/// Tracks real user behavior signals: app switches, session durations, notifications, and focus breaks.
/// Persists hourly and daily data to UserDefaults so it survives app restarts.
@MainActor
final class ActivityTracker: ObservableObject {

    // MARK: - Singleton

    static let shared = ActivityTracker()

    // MARK: - Published State

    @Published private(set) var todayAppSwitches: Int = 0
    @Published private(set) var todayShortSessions: Int = 0
    @Published private(set) var todayNotificationInterruptions: Int = 0
    @Published private(set) var todayFocusBreaks: Int = 0

    // MARK: - Storage Keys

    private let kHourlyData           = "zeen_hourly_data"
    private let kDailyHistory         = "zeen_daily_history"
    private let kLastActiveDate       = "zeen_last_active_date"
    private let kLastForegroundTime   = "zeen_last_foreground_time"
    private let kSessionStartTime     = "zeen_session_start_time"
    private let kTodayAppSwitches     = "zeen_today_app_switches"
    private let kTodayShortSessions   = "zeen_today_short_sessions"
    private let kTodayNotifications   = "zeen_today_notifications"
    private let kTodayFocusBreaks     = "zeen_today_focus_breaks"

    // MARK: - Internal Tracking

    private var sessionStartTime: Date?
    private var lastBackgroundTime: Date?
    private let shortSessionThreshold: TimeInterval = 120 // < 2 min = short session
    private let calendar = Calendar.current
    private let defaults = UserDefaults.standard

    // MARK: - Init

    private init() {
        loadTodayCounters()
        rollOverIfNewDay()
    }

    // MARK: - Scene Phase Handling

    /// Call this from ZeenApp when scenePhase changes.
    func handleScenePhaseChange(_ newPhase: ScenePhase) {
        rollOverIfNewDay()

        switch newPhase {
        case .active:
            handleBecameActive()
        case .background:
            handleEnteredBackground()
        case .inactive:
            break
        @unknown default:
            break
        }
    }

    // MARK: - Notification Tracking

    /// Call this when the app detects a notification was delivered while the app was active.
    func recordNotificationInterruption() {
        todayNotificationInterruptions += 1
        persistCounters()
        recordHourlyEvent(type: .notification)
    }

    /// Record a batch of notifications (e.g. from checking pending notifications on foreground).
    func recordNotifications(count: Int) {
        guard count > 0 else { return }
        todayNotificationInterruptions += count
        persistCounters()
        for _ in 0..<count {
            recordHourlyEvent(type: .notification)
        }
    }

    // MARK: - Focus Break Tracking

    /// Call this when a focus session is interrupted (user leaves app during focus).
    func recordFocusBreak() {
        todayFocusBreaks += 1
        persistCounters()
        recordHourlyEvent(type: .focusBreak)
    }

    // MARK: - Data Access

    /// Returns the current day's drift input for scoring.
    func todayDriftInput() -> DriftInput {
        DriftInput(
            appSwitches: todayAppSwitches,
            shortSessions: todayShortSessions,
            notificationInterruptions: todayNotificationInterruptions,
            focusBreaks: todayFocusBreaks
        )
    }

    /// Returns hourly timeline for today.
    func hourlyTimeline() -> [TimelinePoint] {
        let hourlyData = loadHourlyData()
        let currentHour = calendar.component(.hour, from: .now)

        // Only return hours up to and including the current hour, starting from 6 AM
        let startHour = 6
        let endHour = max(currentHour, startHour)

        return (startHour...endHour).map { hour in
            if let entry = hourlyData[String(hour)] {
                return TimelinePoint(
                    hour: hour,
                    score: computeHourlyScore(entry),
                    interruptionCount: entry.notifications + entry.focusBreaks
                )
            } else {
                return TimelinePoint(hour: hour, score: 0, interruptionCount: 0)
            }
        }
    }

    /// Returns weekly summary from stored daily history.
    func weeklySummary() -> WeeklySummary {
        let history = loadDailyHistory()
        let weekStart = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: .now)) ?? .now

        // Build 7 daily points (0 = Mon-ish, mapping recent 7 days)
        let points: [WeeklyDriftPoint] = (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) ?? .now
            let dateStr = dateKey(for: date)
            let entry = history[dateStr]
            let score = entry?.score ?? 0
            let deepFocus = entry?.deepFocusMinutes ?? 0
            return WeeklyDriftPoint(dayIndex: dayOffset, score: score, deepFocusMinutes: deepFocus)
        }

        return WeeklySummary(weekStart: weekStart, points: points)
    }

    /// Returns historical daily records for the calendar view.
    func historicalRecords(days: Int) -> [DailyRecord] {
        let history = loadDailyHistory()
        let today = calendar.startOfDay(for: .now)

        return (0..<days).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -(days - 1 - offset), to: today) else { return nil }
            let key = dateKey(for: date)
            let score = history[key]?.score ?? 0
            return DailyRecord(date: date, score: score)
        }
    }

    // MARK: - Private: Scene Phase Handlers

    private func handleBecameActive() {
        let now = Date.now

        // Count an app switch if we were in the background
        if lastBackgroundTime != nil {
            todayAppSwitches += 1
            recordHourlyEvent(type: .appSwitch)
        }

        // Check if previous session was short
        if let bgTime = lastBackgroundTime {
            let sessionDuration = bgTime.timeIntervalSince(sessionStartTime ?? bgTime)
            if sessionDuration > 0 && sessionDuration < shortSessionThreshold {
                todayShortSessions += 1
                recordHourlyEvent(type: .shortSession)
            }
        }

        // Start new session
        sessionStartTime = now
        lastBackgroundTime = nil

        // Check for notifications that arrived while backgrounded
        checkPendingNotifications()

        persistCounters()
    }

    private func handleEnteredBackground() {
        lastBackgroundTime = .now
        persistCounters()
        saveEndOfDaySnapshotIfNeeded()
    }

    // MARK: - Notifications Check

    private func checkPendingNotifications() {
        UNUserNotificationCenter.current().getDeliveredNotifications { [weak self] notifications in
            let count = notifications.count
            if count > 0 {
                Task { @MainActor [weak self] in
                    // Only count new notifications since last check
                    let previousCount = UserDefaults.standard.integer(forKey: "zeen_last_notif_count")
                    let newNotifs = max(0, count - previousCount)
                    if newNotifs > 0 {
                        self?.recordNotifications(count: newNotifs)
                    }
                    UserDefaults.standard.set(count, forKey: "zeen_last_notif_count")
                }
            }
        }
    }

    // MARK: - Hourly Data

    private enum HourlyEventType {
        case appSwitch, shortSession, notification, focusBreak
    }

    private struct HourlyEntry: Codable {
        var appSwitches: Int = 0
        var shortSessions: Int = 0
        var notifications: Int = 0
        var focusBreaks: Int = 0
    }

    private func recordHourlyEvent(type: HourlyEventType) {
        var data = loadHourlyData()
        let hour = String(calendar.component(.hour, from: .now))
        var entry = data[hour] ?? HourlyEntry()

        switch type {
        case .appSwitch:    entry.appSwitches += 1
        case .shortSession: entry.shortSessions += 1
        case .notification: entry.notifications += 1
        case .focusBreak:   entry.focusBreaks += 1
        }

        data[hour] = entry
        saveHourlyData(data)
    }

    private func computeHourlyScore(_ entry: HourlyEntry) -> Int {
        // Mini version of the drift scoring, normalized per hour
        let maxSwitch = 8.0, maxShort = 5.0, maxNotif = 8.0, maxFocus = 4.0

        let switchNorm = min(Double(entry.appSwitches) / maxSwitch, 1.0)
        let shortNorm  = min(Double(entry.shortSessions) / maxShort, 1.0)
        let notifNorm  = min(Double(entry.notifications) / maxNotif, 1.0)
        let focusNorm  = min(Double(entry.focusBreaks) / maxFocus, 1.0)

        let raw = (switchNorm * 0.35 + shortNorm * 0.25 + notifNorm * 0.25 + focusNorm * 0.15) * 100
        return max(0, min(100, Int(raw)))
    }

    private func loadHourlyData() -> [String: HourlyEntry] {
        guard let data = defaults.data(forKey: kHourlyData),
              let decoded = try? JSONDecoder().decode([String: HourlyEntry].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private func saveHourlyData(_ data: [String: HourlyEntry]) {
        if let encoded = try? JSONEncoder().encode(data) {
            defaults.set(encoded, forKey: kHourlyData)
        }
    }

    // MARK: - Daily History

    private struct DailyEntry: Codable {
        var score: Int
        var deepFocusMinutes: Int
    }

    private func loadDailyHistory() -> [String: DailyEntry] {
        guard let data = defaults.data(forKey: kDailyHistory),
              let decoded = try? JSONDecoder().decode([String: DailyEntry].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private func saveDailyHistory(_ history: [String: DailyEntry]) {
        if let encoded = try? JSONEncoder().encode(history) {
            defaults.set(encoded, forKey: kDailyHistory)
        }
    }

    /// Saves a daily snapshot when the app goes to background (so we don't lose data).
    private func saveEndOfDaySnapshotIfNeeded() {
        let input = todayDriftInput()
        let scoringService = DriftScoringService()
        let driftScore = scoringService.score(input: input)

        let todayKey = dateKey(for: .now)
        var history = loadDailyHistory()

        // Read deep focus minutes from FocusSessionViewModel's persisted data
        let deepFocus = defaults.integer(forKey: "lifetimeFocusMinutes")

        history[todayKey] = DailyEntry(score: driftScore.value, deepFocusMinutes: deepFocus)
        saveDailyHistory(history)
    }

    /// Saves today's snapshot (called externally when data updates).
    func saveTodaySnapshot(deepFocusMinutes: Int = 0) {
        let input = todayDriftInput()
        let scoringService = DriftScoringService()
        let driftScore = scoringService.score(input: input)

        let todayKey = dateKey(for: .now)
        var history = loadDailyHistory()
        history[todayKey] = DailyEntry(score: driftScore.value, deepFocusMinutes: deepFocusMinutes)
        saveDailyHistory(history)
    }

    // MARK: - Day Rollover

    private func rollOverIfNewDay() {
        let todayStr = dateKey(for: .now)
        let lastDate = defaults.string(forKey: kLastActiveDate)

        if lastDate != todayStr {
            // Save yesterday's final state before resetting
            if lastDate != nil {
                // Yesterday's data is already persisted via saveEndOfDaySnapshotIfNeeded
            }

            // Reset today's counters
            todayAppSwitches = 0
            todayShortSessions = 0
            todayNotificationInterruptions = 0
            todayFocusBreaks = 0
            persistCounters()

            // Clear hourly data for the new day
            saveHourlyData([:])

            // Reset notification count tracking
            defaults.set(0, forKey: "zeen_last_notif_count")

            defaults.set(todayStr, forKey: kLastActiveDate)
        }
    }

    // MARK: - Persistence Helpers

    private func loadTodayCounters() {
        todayAppSwitches = defaults.integer(forKey: kTodayAppSwitches)
        todayShortSessions = defaults.integer(forKey: kTodayShortSessions)
        todayNotificationInterruptions = defaults.integer(forKey: kTodayNotifications)
        todayFocusBreaks = defaults.integer(forKey: kTodayFocusBreaks)
    }

    private func persistCounters() {
        defaults.set(todayAppSwitches, forKey: kTodayAppSwitches)
        defaults.set(todayShortSessions, forKey: kTodayShortSessions)
        defaults.set(todayNotificationInterruptions, forKey: kTodayNotifications)
        defaults.set(todayFocusBreaks, forKey: kTodayFocusBreaks)
    }

    private func dateKey(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }
}
