import Foundation

@MainActor
final class SessionViewModel: ObservableObject {
    @Published private(set) var profile: UserProfile?

    private let storageKey = "zeen_profile"

    var isAuthenticated: Bool { profile != nil }

    init() { loadProfile() }

    func loginOrRegister(name: String, email: String) {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let e = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !n.isEmpty, !e.isEmpty else { return }
        profile = UserProfile(name: n, email: e)
        persistProfile()
    }

    func updateProfile(name: String, email: String) {
        guard isAuthenticated else { return }
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let e = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if var p = profile {
            if !n.isEmpty { p.name = n }
            if !e.isEmpty { p.email = e }
            profile = p
        }
        persistProfile()
    }

    func updateGoal(_ goal: Int) {
        if var p = profile {
            p.goalAverageScore = max(10, min(90, goal))
            profile = p
            persistProfile()
        }
    }

    func logout() {
        profile = nil
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    private func loadProfile() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        if let loaded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = loaded
        }
    }

    private func persistProfile() {
        guard let profile else { return }
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
