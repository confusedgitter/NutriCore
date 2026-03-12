//
//  RecipeEngine.swift
//  NutriCore
//
//  Created by Mukunth Parthasarathy on 09/03/2026.
//

import Foundation
import Combine

class RecipeEngine: ObservableObject {
    @Published var expiringIngredients: [FoodItem] = []
    @Published var recipes: [Recipe] = []

    func generateRecipes(from items: [FoodItem]) async {

        // Identify ingredients expiring soon (within 2 days)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let expiringSoon = items.filter {
            let expiry = calendar.startOfDay(for: $0.expiryDate)
            return expiry <= calendar.date(byAdding: .day, value: 2, to: today)!
        }

        await MainActor.run {
            self.expiringIngredients = expiringSoon
        }

        // Prioritize expiring ingredients first
        let prioritizedItems = expiringSoon + items.filter { item in
            !expiringSoon.contains(where: { $0.id == item.id })
        }

        let ingredients = prioritizedItems.map { $0.name.lowercased() }

        do {
            let result = try await RecipeService.shared.fetchRecipes(from: ingredients)

            await MainActor.run {
                self.recipes = result
            }

        } catch {
            print("Recipe fetch failed:", error)
        }
    }
}
