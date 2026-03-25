import Foundation

struct CalorieEntry: Identifiable, Codable {
    let id: UUID
    let recipeName: String
    let calories: Int
    let date: Date

    init(id: UUID = UUID(), recipeName: String, calories: Int, date: Date = Date()) {
        self.id = id
        self.recipeName = recipeName
        self.calories = calories
        self.date = date
    }
}
