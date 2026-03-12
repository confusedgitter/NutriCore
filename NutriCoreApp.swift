//
//  ShelfLifeApp.swift
//  ShelfLife
//
//  Created by Mukunth Parthasarathy on 23/02/2026.
//

import SwiftUI
import UserNotifications


@main
struct ShelfLifeApp: App {
    
    @StateObject private var viewModel = InventoryViewModel()
    
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notifications allowed")
            }
        }
    }
    
    
    var body: some Scene {
        WindowGroup {
            MainTabView(viewModel: viewModel)
                .onAppear {
                    NotificationManager.shared.scheduleWeeklySummary(using: viewModel)
                }
        }
    }
}
