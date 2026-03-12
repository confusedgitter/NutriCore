import Foundation

// MARK: - Health Event Types

enum HealthEventType: String, Codable {
    case workoutCompleted
    case healthyMeal
    case medicationTaken
    case hydrationLogged
    case foodSaved
}

// MARK: - Health Event Model

struct HealthEvent: Identifiable, Codable {
    let id: UUID
    let type: HealthEventType
    let date: Date

    init(type: HealthEventType, date: Date = Date()) {
        self.id = UUID()
        self.type = type
        self.date = date
    }
}

// MARK: - Convenience Helpers

extension HealthEvent {

    var isWorkout: Bool {
        type == .workoutCompleted
    }

    var isMeal: Bool {
        type == .healthyMeal
    }

    var isMedication: Bool {
        type == .medicationTaken
    }

    var isHydration: Bool {
        type == .hydrationLogged
    }

    var isFoodSaved: Bool {
        type == .foodSaved
    }
}
