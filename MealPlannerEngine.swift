//
//  MealPlannerEngine.swift
//  NutriCore
//
//  Created by Mukunth Parthasarathy on 09/03/2026.
//

import Foundation

class MealPlannerEngine {
    
    static func generatePlan(from recipes: [Recipe]) -> [MealPlan] {
        
        let days = [
            "Monday","Tuesday","Wednesday",
            "Thursday","Friday","Saturday","Sunday"
        ]
        
        var plan: [MealPlan] = []
        
        for (index, recipe) in recipes.enumerated() {
            
            if index >= days.count { break }
            
            plan.append(
                MealPlan(
                    day: days[index],
                    recipe: recipe
                )
            )
        }
        
        return plan
    }
}
