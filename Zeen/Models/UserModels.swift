import Foundation

struct UserProfile: Codable, Equatable {
    var name: String
    var email: String
    var goalAverageScore: Int = 40
    var joinDate: Date = .now

    var firstName: String {
        name.components(separatedBy: " ").first ?? name
    }

    var initial: String {
        String(name.trimmingCharacters(in: .whitespacesAndNewlines).prefix(1)).uppercased()
    }
}
