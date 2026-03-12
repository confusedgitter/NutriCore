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
