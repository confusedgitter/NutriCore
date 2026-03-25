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

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let expiringSoon = items.filter {
            let expiry = calendar.startOfDay(for: $0.expiryDate)
            return expiry <= calendar.date(byAdding: .day, value: 2, to: today)!
        }

        await MainActor.run {
            self.expiringIngredients = expiringSoon
        }

        let prioritizedItems = expiringSoon + items.filter { item in
            !expiringSoon.contains(where: { $0.id == item.id })
        }

        let ingredients = prioritizedItems.map { normalizedIngredientName($0.name) }

        do {
            let result = try await RecipeService.shared.fetchRecipes(from: ingredients)

            await MainActor.run {
                if result.isEmpty {
                    self.recipes = self.fallbackRecipes(from: ingredients)
                } else {
                    self.recipes = result
                }
            }

        } catch {
            print("Recipe fetch failed:", error)

            await MainActor.run {
                self.recipes = self.fallbackRecipes(from: ingredients)
            }
        }
    }

    private func normalizedIngredientName(_ name: String) -> String {
        let lower = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if lower.contains("maggie") || lower.contains("maggi") {
            return "maggi noodles"
        }

        if lower.contains("peanut butter") {
            return "peanut butter"
        }

        return lower
    }

    private func fallbackRecipes(from ingredients: [String]) -> [Recipe] {
        let pantry = Set(ingredients)
        var suggestions: [Recipe] = []

        if pantry.contains(where: { $0.contains("maggi noodles") || $0.contains("noodles") }) {
            suggestions.append(
                Recipe(
                    name: "Maggi Noodles",
                    ingredients: ["1 maggi noodles", "1 cup water"],
                    steps: [
                        "Boil water in a pan.",
                        "Add Maggi noodles and tastemaker.",
                        "Cook for 2–3 minutes and serve hot."
                    ]
                )
            )
        }

        if pantry.contains("peanut butter") && pantry.contains(where: { $0.contains("bread") }) {
            suggestions.append(
                Recipe(
                    name: "Peanut Butter Sandwich",
                    ingredients: ["2 bread slices", "2 tbsp peanut butter"],
                    steps: [
                        "Spread peanut butter evenly on the bread.",
                        "Close the sandwich and serve."
                    ]
                )
            )
        }

        if pantry.contains("peanut butter") {
            suggestions.append(
                Recipe(
                    name: "Peanut Butter Toast",
                    ingredients: ["2 bread slices", "2 tbsp peanut butter"],
                    steps: [
                        "Toast the bread until golden.",
                        "Spread peanut butter on top.",
                        "Serve immediately."
                    ]
                )
            )
        }

        if pantry.contains(where: { $0.contains("egg") }) {
            suggestions.append(
                Recipe(
                    name: "Simple Omelette",
                    ingredients: ["2 eggs", "1 tbsp oil", "salt", "pepper"],
                    steps: [
                        "Beat the eggs with salt and pepper.",
                        "Heat oil in a pan.",
                        "Pour eggs into the pan and cook until set."
                    ]
                )
            )
        }

        if pantry.contains(where: { $0.contains("rice") }) {
            suggestions.append(
                Recipe(
                    name: "Simple Rice Bowl",
                    ingredients: ["1 cup rice", "salt", "1 tsp butter"],
                    steps: [
                        "Cook the rice until soft.",
                        "Season with salt and butter.",
                        "Serve warm."
                    ]
                )
            )
        }

        if suggestions.isEmpty {
            suggestions.append(
                Recipe(
                    name: "Quick Pantry Mix",
                    ingredients: ingredients.map { $0.capitalized },
                    steps: [
                        "Use your available pantry ingredients to assemble a quick meal.",
                        "Try combining ingredients that are closest to expiry first."
                    ]
                )
            )
        }

        return suggestions
    }
}
