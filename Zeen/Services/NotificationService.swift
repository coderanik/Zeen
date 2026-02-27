import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    // MARK: - Permission

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    func checkPermission() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Morning Reminder

    func scheduleMorningReminder(hour: Int = 8, minute: Int = 30) {
        let content = UNMutableNotificationContent()
        content.title = "Good morning ☀️"
        content.body = "Start your day mindfully — check your drift score."
        content.sound = .default
        content.categoryIdentifier = "morning_reminder"

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "zeen.morning", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Evening Summary

    func scheduleEveningReminder(hour: Int = 20, minute: Int = 0) {
        let content = UNMutableNotificationContent()
        content.title = "Daily Recap 🌙"
        content.body = "See how your attention held up today."
        content.sound = .default
        content.categoryIdentifier = "evening_reminder"

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "zeen.evening", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Focus Complete

    func scheduleFocusComplete(after seconds: TimeInterval = 0.5) {
        let content = UNMutableNotificationContent()
        content.title = "Focus session complete! 🎯"
        content.body = "Great work. Take a moment before your next task."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
        let request = UNNotificationRequest(identifier: "zeen.focus.\(UUID().uuidString)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Cancel

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func cancelMorning() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["zeen.morning"])
    }

    func cancelEvening() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["zeen.evening"])
    }
}
