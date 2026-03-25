//
//  ThemeManager.swift
//  NutriCore
//
//  Created by Mukunth Parthasarathy on 25/03/2026.
//

import SwiftUI
import Combine

enum AppTheme: String, CaseIterable, Codable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var selectedTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selected_theme")
        }
    }

    private init() {
        let stored = UserDefaults.standard.string(forKey: "selected_theme")
        selectedTheme = AppTheme(rawValue: stored ?? "") ?? .system
    }
}
