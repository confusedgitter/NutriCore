//
//  RecipesView.swift
//  NutriCore
//
//  Created by Mukunth Parthasarathy on 09/03/2026.
//

import SwiftUI

struct RecipesView: View {
    
    @ObservedObject var viewModel: InventoryViewModel
    @StateObject private var recipeEngine = RecipeEngine()
    
    var availableIngredients: [FoodItem] {
        viewModel.activeItems
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
                            
                            if recipeEngine.recipes.isEmpty {

                                Text("No recipe suggestions yet")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)

                            } else {

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {

                                        ForEach(recipeEngine.recipes) { recipe in

                                            VStack(alignment: .leading, spacing: 8) {

                                                Text(recipe.name)
                                                    .font(.headline)

                                                Text("Ingredients:")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)

                                                Text(recipe.ingredients.joined(separator: ", "))
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                            .padding()
                                            .frame(width: 220, alignment: .leading)
                                            .background(Color(.systemBackground))
                                            .cornerRadius(16)
                                            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 4)
                                        }

                                    }
                                    .padding(.horizontal)
                                }

                            }
                            
                            // Weekly Meal Plan Section
                            if !recipeEngine.recipes.isEmpty {
                                
                                Text("Weekly Meal Plan")
                                    .font(.title3)
                                    .bold()
                                    .padding(.horizontal)
                                
                                MealPlanView(recipes: recipeEngine.recipes)
                                    .frame(height: 300)
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

