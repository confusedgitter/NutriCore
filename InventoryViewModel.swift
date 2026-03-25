import Foundation
import Combine
import SwiftUI

class InventoryViewModel: ObservableObject {
    
    private let storageKey = "inventory_items"
    
    @Published var items: [FoodItem] = [] {
        didSet {
            saveItems()
            saveWeeklySnapshotIfNeeded()
        }
    }
    
    // MARK: - Lifecycle
    
    init() {
        loadItems()
    }
    
    // MARK: - CRUD
    
    func addItem(_ item: FoodItem) {
        items.append(item)
        NotificationManager.shared.scheduleNotifications(for: item)
    }

    func updateItem(_ item: FoodItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            let oldItem = items[index]
            NotificationManager.shared.cancelNotifications(for: oldItem)
            items[index] = item
            NotificationManager.shared.scheduleNotifications(for: item)
        }
    }
    func deleteItem(at offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            NotificationManager.shared.cancelNotifications(for: item)
        }
        items.remove(atOffsets: offsets)
    }
    
    // MARK: - Analytics
    
    var activeItems: [FoodItem] {
        items.filter { $0.status == .active }
    }

    var consumedItems: [FoodItem] {
        items.filter { $0.status == .consumed }
    }

    var wastedItems: [FoodItem] {
        items.filter { $0.status == .wasted }
    }

    var expiredItems: [FoodItem] {
        let today = Calendar.current.startOfDay(for: Date())
        return activeItems.filter {
            Calendar.current.startOfDay(for: $0.expiryDate) < today
        }
    }

    var expiringSoonItems: [FoodItem] {
        let today = Calendar.current.startOfDay(for: Date())
        let sevenDays = Calendar.current.date(byAdding: .day, value: 7, to: today)!
        
        return activeItems.filter {
            let expiry = Calendar.current.startOfDay(for: $0.expiryDate)
            return expiry >= today && expiry <= sevenDays
        }
    }

    var completedItems: [FoodItem] {
        items.filter { $0.status == .consumed || $0.status == .wasted }
    }

    var efficiencyPercentage: Double {
        let completed = completedItems.count
        guard completed > 0 else { return 100 }
        
        let wasted = wastedItems.count
        let efficiency = 1.0 - (Double(wasted) / Double(completed))
        return efficiency * 100
    }

    // MARK: - Weekly Analytics

    private var startOfCurrentWeek: Date {
        let calendar = Calendar.current
        let today = Date()
        return calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
    }

    var weeklyConsumedItems: [FoodItem] {
        consumedItems.filter {
            guard let completedDate = $0.completedDate else { return false }
            return completedDate >= startOfCurrentWeek
        }
    }

    var weeklyWastedItems: [FoodItem] {
        wastedItems.filter {
            guard let completedDate = $0.completedDate else { return false }
            return completedDate >= startOfCurrentWeek
        }
    }

    var weeklyEfficiencyPercentage: Double {
        let total = weeklyConsumedItems.count + weeklyWastedItems.count
        guard total > 0 else { return 100 }
        
        let wasted = weeklyWastedItems.count
        return (1.0 - (Double(wasted) / Double(total))) * 100
    }

    // MARK: - Week-over-Week Comparison

    private var startOfLastWeek: Date {
        Calendar.current.date(byAdding: .weekOfYear, value: -1, to: startOfCurrentWeek)!
    }

    private var endOfLastWeek: Date {
        startOfCurrentWeek
    }

    var lastWeekConsumedItems: [FoodItem] {
        consumedItems.filter {
            guard let completedDate = $0.completedDate else { return false }
            return completedDate >= startOfLastWeek && completedDate < endOfLastWeek
        }
    }

    var lastWeekWastedItems: [FoodItem] {
        wastedItems.filter {
            guard let completedDate = $0.completedDate else { return false }
            return completedDate >= startOfLastWeek && completedDate < endOfLastWeek
        }
    }

    var lastWeekEfficiencyPercentage: Double {
        let total = lastWeekConsumedItems.count + lastWeekWastedItems.count
        guard total > 0 else { return 100 }

        let wasted = lastWeekWastedItems.count
        return (1.0 - (Double(wasted) / Double(total))) * 100
    }

    var weeklyEfficiencyChange: Double {
        weeklyEfficiencyPercentage - lastWeekEfficiencyPercentage
    }

    // MARK: - Dashboard Insights

    var thisWeekItems: [FoodItem] {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now

        return items.filter {
            guard let completed = $0.completedDate else { return false }
            return completed >= weekStart
        }
    }

    var consumedThisWeek: Int {
        thisWeekItems.filter { $0.status == .consumed }.count
    }

    var wastedThisWeek: Int {
        thisWeekItems.filter { $0.status == .wasted }.count
    }

    var wasteRate: Double {
        let total = consumedThisWeek + wastedThisWeek
        guard total > 0 else { return 0 }
        return Double(wastedThisWeek) / Double(total)
    }
    var savedThisWeekCount: Int {
        consumedThisWeek
    }

    func bestRecipeMatch(from recipes: [Recipe]) -> Recipe? {
        let expiringNames = expiringSoonItems.map { $0.name.lowercased() }
        
        let scored = recipes.map { recipe -> (Recipe, Int) in
            let matches = recipe.ingredients.filter { ingredient in
                expiringNames.contains(where: {
                    ingredient.lowercased().contains($0)
                })
            }.count
            
            return (recipe, matches)
        }
        
        return scored
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
            .first?
            .0
    }

    func wasteSavedCount(for recipe: Recipe) -> Int {
        let expiringNames = expiringSoonItems.map { $0.name.lowercased() }

        return recipe.ingredients.filter { ingredient in
            expiringNames.contains(where: {
                ingredient.lowercased().contains($0)
            })
        }.count
    }

    func savedItems(for recipe: Recipe) -> [String] {
        let expiringNames = expiringSoonItems.map { $0.name.lowercased() }

        return recipe.ingredients.compactMap { ingredient in
            expiringNames.first(where: {
                ingredient.lowercased().contains($0)
            })
        }
    }
    
    // MARK: - Persistence
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadItems() {
        if let savedData = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([FoodItem].self, from: savedData) {
            items = decoded
        }
    }
    // MARK: - Weekly History System
    
    @Published var weeklyHistory: [WeeklySnapshot] = []
    
    struct WeeklySnapshot: Identifiable, Codable {
        let id = UUID()
        let weekStartDate: Date
        let efficiency: Double
    }
    
    func saveWeeklySnapshotIfNeeded() {
        let calendar = Calendar.current
        let today = Date()
        
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return }
        
        // Prevent duplicate snapshot for same week
        if weeklyHistory.contains(where: {
            calendar.isDate($0.weekStartDate, equalTo: weekStart, toGranularity: .weekOfYear)
        }) {
            return
        }
        
        let snapshot = WeeklySnapshot(
            weekStartDate: weekStart,
            efficiency: weeklyEfficiencyPercentage
        )
        
        weeklyHistory.append(snapshot)
    }
}
