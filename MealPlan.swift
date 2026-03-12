//
//  MealPlan.swift
//  NutriCore
//
//  Created by Mukunth Parthasarathy on 09/03/2026.
//

import Foundation

struct MealPlan: Identifiable {
    
    let id = UUID()
    let day: String
    let recipe: Recipe
}
