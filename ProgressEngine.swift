import Foundation
import Combine

// MARK: - Progress Engine

class ProgressEngine: ObservableObject {

    
    static let shared = ProgressEngine()
    
    // All health-related events
    @Published var events: [HealthEvent] = []

    // MARK: - Log Event

    func logEvent(_ type: HealthEventType) {
        let event = HealthEvent(type: type)
        events.append(event)
    }

    // MARK: - Workout Streak

    func workoutStreak() -> Int {
        let workouts = events.filter { $0.type == .workoutCompleted }

        let calendar = Calendar.current
        var streak = 0
        var date = Date()

        while workouts.contains(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = previousDay
        }

        return streak
    }

    // MARK: - Meal Streak

    func healthyMealStreak() -> Int {
        let meals = events.filter { $0.type == .healthyMeal }

        let calendar = Calendar.current
        var streak = 0
        var date = Date()

        while meals.contains(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = previousDay
        }

        return streak
    }

    // MARK: - Health Score

    func healthScore() -> Int {

        let workoutPoints = events.filter { $0.type == .workoutCompleted }.count * 10
        let mealPoints = events.filter { $0.type == .healthyMeal }.count * 5
        let hydrationPoints = events.filter { $0.type == .hydrationLogged }.count * 2
        let medicationPoints = events.filter { $0.type == .medicationTaken }.count * 3

        let total = workoutPoints + mealPoints + hydrationPoints + medicationPoints

        return min(total, 100)
    }
}
