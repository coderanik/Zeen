import Foundation

@MainActor
final class FocusSessionViewModel: ObservableObject {
    @Published var state: FocusSessionState = .idle
    @Published var selectedType: FocusSessionType = .deepWork
    @Published var totalDuration: TimeInterval = 25 * 60
    @Published var remainingTime: TimeInterval = 25 * 60
    @Published private(set) var sessions: [FocusSessionRecord] = []

    private var timer: Timer?

    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return 1.0 - (remainingTime / totalDuration)
    }

    var timeLabel: String {
        let m = Int(remainingTime) / 60
        let s = Int(remainingTime) % 60
        return String(format: "%02d:%02d", m, s)
    }

    var totalSessionsToday: Int {
        sessions.filter { Calendar.current.isDateInToday($0.completedAt) }.count
    }

    var totalFocusMinutesToday: Int {
        let today = sessions.filter { Calendar.current.isDateInToday($0.completedAt) }
        return Int(today.map(\.elapsed).reduce(0, +)) / 60
    }

    var completedToday: Int {
        sessions.filter { Calendar.current.isDateInToday($0.completedAt) && $0.completed }.count
    }

    func selectType(_ type: FocusSessionType) {
        guard state == .idle else { return }
        selectedType = type
        totalDuration = type.defaultDuration
        remainingTime = type.defaultDuration
    }

    func start() {
        state = .running
        startTimer()
    }

    func pause() {
        state = .paused
        timer?.invalidate()
        timer = nil
    }

    func resume() {
        state = .running
        startTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        let elapsed = totalDuration - remainingTime
        if elapsed > 5 {
            sessions.insert(FocusSessionRecord(
                type: selectedType, elapsed: elapsed, target: totalDuration,
                completedAt: .now, completed: false
            ), at: 0)
        }
        state = .idle
        remainingTime = totalDuration
    }

    func reset() {
        timer?.invalidate()
        timer = nil
        state = .idle
        remainingTime = totalDuration
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                if self.remainingTime > 0 {
                    self.remainingTime -= 1
                } else {
                    self.completeSession()
                }
            }
        }
    }

    private func completeSession() {
        timer?.invalidate()
        timer = nil
        sessions.insert(FocusSessionRecord(
            type: selectedType, elapsed: totalDuration, target: totalDuration,
            completedAt: .now, completed: true
        ), at: 0)
        state = .idle
        remainingTime = totalDuration
    }
}
