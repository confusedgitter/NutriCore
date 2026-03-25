//
//  Recipe.swift
//  NutriCore
//
//  Created by Mukunth Parthasarathy on 09/03/2026.
//

import Foundation

struct Recipe: Identifiable, Codable {
    let id = UUID()
    let name: String
    let ingredients: [String]
    let steps: [String]
    
    // Optional explicit calories (if provided)
    var calories: Int? = nil
    
    // Servings
    var servings: Int = 1
    
    // MARK: - Helpers
    
    private func quantityFrom(_ ingredient: String) -> Double {
        let words = ingredient.lowercased().split(separator: " ")
        guard let first = words.first else { return 1 }
        
        if first.contains("/") {
            let parts = first.split(separator: "/")
            if parts.count == 2,
               let numerator = Double(parts[0]),
               let denominator = Double(parts[1]) {
                return numerator / denominator
            }
        }
        
        if first == "½" { return 0.5 }
        if first == "¼" { return 0.25 }
        if first == "¾" { return 0.75 }
        
        if let number = Double(first) {
            return number
        }
        
        return 1
    }
    
    private func nameWithoutQuantity(_ ingredient: String) -> String {
        let words = ingredient.split(separator: " ")
        
        if let first = words.first,
           Double(first) != nil || first.contains("/") {
            return words.dropFirst().joined(separator: " ")
        }
        
        return ingredient
    }
    
    private func normalize(_ text: String) -> String {
        var value = text.lowercased()
        
        if value.hasSuffix("es") {
            value = String(value.dropLast(2))
        } else if value.hasSuffix("s") {
            value = String(value.dropLast())
        }
        
        let ignoreWords = ["fresh", "whole", "chopped", "sliced", "cup", "tbsp"]
        
        let words = value.split(separator: " ").filter {
            !ignoreWords.contains(String($0))
        }
        
        return words.joined(separator: " ")
    }
    
    // MARK: - Calories Engine
    
    var estimatedCalories: Int {
        let lookup: [(String, Int)] = [
            ("peanut butter", 190),
            ("maggi noodles", 350),
            ("noodles", 350),
            ("maggi", 350),
            ("egg", 78),
            ("milk", 103),
            ("bread", 80),
            ("rice", 206),
            ("chicken", 165),
            ("beef", 250),
            ("cheese", 113),
            ("butter", 102),
            ("oil", 120),
            ("tomato", 22),
            ("onion", 40),
            ("potato", 161),
            ("carrot", 25),
            ("pasta", 131),
            ("oats", 150),
            ("apple", 95),
            ("banana", 105),
            ("tofu", 76),
            ("beans", 150),
            ("sugar", 16),
            ("salt", 0)
        ]
        
        return ingredients.reduce(0) { total, ingredient in
            let quantity = quantityFrom(ingredient)
            let clean = normalize(nameWithoutQuantity(ingredient))
            
            if let match = lookup.first(where: { clean.contains($0.0) }) {
                return total + Int(Double(match.1) * quantity)
            }
            
            return total
        }
    }
    
    var totalCalories: Int {
        calories ?? estimatedCalories
    }
    
    var caloriesPerServing: Int {
        totalCalories / max(servings, 1)
    }
    
    var healthCategory: String {
        if totalCalories < 300 { return "Healthy" }
        else if totalCalories < 600 { return "Moderate" }
        else { return "High" }
    }
}
