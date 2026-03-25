import Foundation
import Combine

final class ProfileManager: ObservableObject {
    static let shared = ProfileManager()

    @Published var profile: UserProfile {
        didSet { save() }
    }

    private let storageKey = "user_profile"

    private init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = decoded
        } else {
            profile = UserProfile()
        }
    }

    func update(_ change: (inout UserProfile) -> Void) {
        var updated = profile
        change(&updated)
        profile = updated
    }

    func calculateRecommendedCalories() -> Int {
        let weight = profile.weightKg
        let height = Double(profile.heightCm)
        let age = Double(profile.age)

        let bmr: Double

        switch profile.gender {
        case .male:
            bmr = 10 * weight + 6.25 * height - 5 * age + 5
        case .female:
            bmr = 10 * weight + 6.25 * height - 5 * age - 161
        case .other:
            bmr = 10 * weight + 6.25 * height - 5 * age
        }

        let multiplier: Double = {
            switch profile.activityLevel {
            case .low: return 1.2
            case .moderate: return 1.55
            case .high: return 1.75
            }
        }()

        let maintenance = bmr * multiplier

        switch profile.goalType {
        case .loseWeight:
            return Int(maintenance - 300)
        case .maintain:
            return Int(maintenance)
        case .gainWeight:
            return Int(maintenance + 300)
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
