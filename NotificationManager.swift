//
//  NotificationManager.swift
//  NutriCore
//
//  Created by Mukunth Parthasarathy on 03/03/2026.
//

import Foundation
import UserNotifications

class NotificationManager {
    
    static let shared = NotificationManager()
    private init() {}
    
    // MARK: - Schedule Expiry Notifications
    func scheduleNotifications(for item: FoodItem) {
        
        let center = UNUserNotificationCenter.current()
        
        let calendar = Calendar.current
        let expiryDate = calendar.startOfDay(for: item.expiryDate)
        
        // 1️⃣ Notification on expiry day
        createNotification(
            id: "\(item.id.uuidString)_expiry",
            title: "Item Expiring Today",
            body: "\(item.name) expires today.",
            date: expiryDate
        )
        
        // 2️⃣ Notification 1 day before expiry
        if let dayBefore = calendar.date(byAdding: .day, value: -1, to: expiryDate) {
            createNotification(
                id: "\(item.id.uuidString)_dayBefore",
                title: "Expiry Reminder",
                body: "\(item.name) expires tomorrow.",
                date: dayBefore
            )
        }
    }
    
    // MARK: - Weekly Summary Notification

    func scheduleWeeklySummary(using viewModel: InventoryViewModel) {
        
        let center = UNUserNotificationCenter.current()
        
        let consumed = viewModel.weeklyConsumedItems.count
        let wasted = viewModel.weeklyWastedItems.count
        let efficiency = Int(viewModel.weeklyEfficiencyPercentage)
        
        let content = UNMutableNotificationContent()
        content.title = "Your Weekly Food Summary"
        
        if consumed == 0 && wasted == 0 {
            content.body = "No completed items this week. Let’s stay on track!"
        } else if efficiency >= 85 {
            content.body = "Amazing week! You used \(consumed) items and kept waste very low. Efficiency: \(efficiency)%."
        } else if efficiency >= 60 {
            content.body = "Good job! Used \(consumed) items with \(wasted) wasted. Efficiency: \(efficiency)%."
        } else {
            content.body = "This week had higher waste (\(wasted) items). Let’s improve next week. Efficiency: \(efficiency)%."
        }
        
        content.sound = .default
        
        var components = DateComponents()
        components.weekday = 1   // Sunday
        components.hour = 9
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "weekly_summary",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
    
    // MARK: - Cancel Notifications
    func cancelNotifications(for item: FoodItem) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [
            "\(item.id.uuidString)_expiry",
            "\(item.id.uuidString)_dayBefore"
        ])
    }
    
    // MARK: - Private Helper
    private func createNotification(id: String, title: String, body: String, date: Date) {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = 9
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
