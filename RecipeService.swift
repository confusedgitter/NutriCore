//
//  RecipeService.swift
//  NutriCore
//
//  Created by Mukunth Parthasarathy on 09/03/2026.
//

import Foundation

class RecipeService {

    static let shared = RecipeService()

    func fetchRecipes(from ingredients: [String]) async throws -> [Recipe] {

        guard let url = URL(string: "https://your-backend.com/recipes/suggest") else {
            return []
        }

        let body: [String: Any] = [
            "ingredients": ingredients
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        let recipes = try JSONDecoder().decode([Recipe].self, from: data)

        return recipes
    }
}
