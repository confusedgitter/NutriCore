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
}
