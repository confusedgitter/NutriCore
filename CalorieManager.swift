import Foundation
import Combine

final class CalorieManager: ObservableObject {
    static let shared = CalorieManager()

    @Published var entries: [CalorieEntry] = [] {
        didSet { save() }
    }

    var dailyGoal: Int {
        ProfileManager.shared.profile.dailyCalorieGoal
    }

    private let storageKey = "calorie_entries"

    private init() {
        load()
    }

    func log(recipe: Recipe) {
        entries.append(
            CalorieEntry(
                recipeName: recipe.name,
                calories: recipe.totalCalories,
                date: Date()
            )
        )
    }

    func updateDailyGoal(_ value: Int) {
        ProfileManager.shared.update { profile in
            profile.dailyCalorieGoal = value
        }
        objectWillChange.send()
    }

    var todayCalories: Int {
        let calendar = Calendar.current
        return entries
            .filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.calories }
    }

    var todayEntries: [CalorieEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDateInToday($0.date) }
    }

    var progress: Double {
        min(Double(todayCalories) / Double(dailyGoal), 1.0)
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([CalorieEntry].self, from: data) else {
            entries = []
            return
        }
        entries = decoded
    }
}
