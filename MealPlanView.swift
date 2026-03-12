//
//  MealPlanView.swift
//  NutriCore
//
//  Created by Mukunth Parthasarathy on 09/03/2026.
//

import SwiftUI

struct MealPlanView: View {
    
    var recipes: [Recipe]
    
    var mealPlan: [MealPlan] {
        MealPlannerEngine.generatePlan(from: recipes)
    }
    
    var body: some View {
        
        NavigationStack {
            
            List(mealPlan) { plan in
                
                HStack {
                    
                    VStack(alignment: .leading) {
                        
                        Text(plan.day)
                            .font(.headline)
                        
                        Text(plan.recipe.name)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "fork.knife")
                        .foregroundColor(.green)
                }
            }
            
            .navigationTitle("Weekly Meal Plan")
        }
    }
}
