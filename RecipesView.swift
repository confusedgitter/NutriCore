//
//  RecipesView.swift
//  NutriCore
//
//  Created by Mukunth Parthasarathy on 09/03/2026.
//

import SwiftUI

struct RecipesView: View {
    
    @ObservedObject var viewModel: InventoryViewModel
    var suggestedIngredients: [String] = []
    @StateObject private var recipeEngine = RecipeEngine()
    @ObservedObject var shoppingManager = ShoppingListManager.shared
    
    var availableIngredients: [FoodItem] {
        viewModel.activeItems
    }
    
    var missingIngredients: [String] {
        let inventoryNames = availableIngredients.map {
            $0.name.lowercased()
        }

        var missing: Set<String> = []

        for recipe in recipeEngine.recipes {
            for ingredient in recipe.ingredients {
                if !inventoryNames.contains(ingredient.lowercased()) {
                    missing.insert(ingredient)
                }
            }
        }

        return Array(missing).sorted()
    }
    
    var filteredRecipes: [Recipe] {
        if suggestedIngredients.isEmpty {
            return recipeEngine.recipes
        }
        
        let scoredRecipes = recipeEngine.recipes.map { recipe -> (Recipe, Int) in
            let matchCount = suggestedIngredients.filter { ingredient in
                recipe.ingredients.contains {
                    $0.localizedCaseInsensitiveContains(ingredient)
                }
            }.count
            
            return (recipe, matchCount)
        }
        
        let filtered = scoredRecipes.filter {
            $0.1 >= max(1, suggestedIngredients.count / 2)
        }
        
        let sorted = filtered.sorted { $0.1 > $1.1 }
        
        return sorted.map { $0.0 }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("Cook From Your Pantry")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    if availableIngredients.isEmpty {
                        
                        VStack(spacing: 12) {
                            Image(systemName: "fork.knife")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            
                            Text("No ingredients available")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                    } else {
                        
                        // Cook Soon Section
                        if !recipeEngine.expiringIngredients.isEmpty {
                            
                            Text("⚠ Cook Soon")
                                .font(.title3)
                                .bold()
                                .padding(.horizontal)
                            
                            ForEach(recipeEngine.expiringIngredients) { item in
                                
                                HStack {
                                    Text(item.name)
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    Text("Expiring soon")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                                .padding()
                                .background(Color.orange.opacity(0.15))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                        // Suggested Recipes Section
                        Text("Suggested Recipes")
                                .font(.title3)
                                .bold()
                                .padding(.horizontal)
                            
                            if filteredRecipes.isEmpty {

                                Text(suggestedIngredients.isEmpty ? "No recipe suggestions yet" : "No exact matches — showing close recipes")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)

                            } else {

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {

                                        ForEach(filteredRecipes) { recipe in
                                            NavigationLink(destination: RecipeDetailView(recipe: recipe, viewModel: viewModel)) {
                                                VStack(alignment: .leading, spacing: 8) {

                                                    Text(recipe.name)
                                                        .font(.headline)
                                                        .foregroundColor(.primary)
                                                    Text("\(recipe.totalCalories) kcal")
                                                        .font(.caption2)
                                                        .foregroundColor(.secondary)

                                                    let matchCount = recipe.ingredients.filter { ingredient in
                                                        suggestedIngredients.contains { suggested in
                                                            ingredient.localizedCaseInsensitiveContains(suggested)
                                                        }
                                                    }.count

                                                    let total = recipe.ingredients.count
                                                    let missing = total - matchCount

                                                    if !suggestedIngredients.isEmpty {
                                                        Text("You have \(matchCount) • Missing \(missing)")
                                                            .font(.caption2)
                                                            .foregroundColor(.secondary)
                                                    }

                                                    Text("Ingredients:")
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)

                                                    VStack(alignment: .leading, spacing: 2) {
                                                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                                                            let isMatched = suggestedIngredients.contains { suggested in
                                                                ingredient.localizedCaseInsensitiveContains(suggested)
                                                            }
                                                            
                                                            Text(ingredient)
                                                                .font(.caption)
                                                                .foregroundColor(isMatched ? .green : .gray)
                                                        }
                                                    }

                                                    HStack {
                                                        Text("Cook Now")
                                                            .font(.caption)
                                                            .padding(.horizontal, 8)
                                                            .padding(.vertical, 4)
                                                            .background(Color.blue)
                                                            .foregroundColor(.white)
                                                            .cornerRadius(6)

                                                        Spacer()

                                                        Button("Add Missing") {
                                                            let missingIngredients = recipe.ingredients.filter { ingredient in
                                                                !suggestedIngredients.contains { suggested in
                                                                    ingredient.localizedCaseInsensitiveContains(suggested)
                                                                }
                                                            }

                                                            missingIngredients.forEach { item in
                                                                shoppingManager.add(item)
                                                            }
                                                        }
                                                        .font(.caption)
                                                    }
                                                }
                                                .padding()
                                                .frame(width: 220, alignment: .leading)
                                                .background(Color(.systemBackground))
                                                .cornerRadius(16)
                                                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                                            }
                                            .buttonStyle(.plain)
                                        }

                                    }
                                    .padding(.horizontal)
                                }

                            }
                            
                            // Weekly Meal Plan Section
                            if !filteredRecipes.isEmpty {
                                
                                Text("Weekly Meal Plan")
                                    .font(.title3)
                                    .bold()
                                    .padding(.horizontal)
                                
                                MealPlanView(recipes: filteredRecipes)
                                    .frame(height: 300)
                            }
                        }
                        
                        // Missing Ingredients Section
                        if !missingIngredients.isEmpty {
                            Text("Missing Ingredients")
                                .font(.title3)
                                .bold()
                                .padding(.horizontal)

                            VStack(spacing: 12) {
                                ForEach(missingIngredients, id: \.self) { ingredient in
                                    HStack {
                                        Text(ingredient)
                                            .font(.headline)

                                        Spacer()

                                        Button("+ Add") {
                                            shoppingManager.add(ingredient)
                                        }
                                        .font(.caption)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Ingredient List
                        Text("Available Ingredients")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(availableIngredients) { item in
                                
                                HStack {
                                    
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                            .font(.headline)
                                        
                                        Text("Qty: \(item.quantity)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                    
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                }
                .navigationTitle("Recipes")
                .onAppear {
                    Task {
                        await recipeEngine.generateRecipes(from: viewModel.activeItems)
                    }
                }
            }
        }
    }



