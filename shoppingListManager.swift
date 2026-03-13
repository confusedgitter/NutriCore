//
//  shoppingListManager.swift
//  NutriCore
//
//  Created by Mukunth Parthasarathy on 12/03/2026.
//
import Foundation
import Combine
import SwiftUI

class ShoppingListManager: ObservableObject {
    static let shared = ShoppingListManager()

    @Published var items: [ShoppingItem] = []

    func add(_ ingredient: String) {
        if !items.contains(where: { $0.name.lowercased() == ingredient.lowercased() }) {
            items.append(ShoppingItem(name: ingredient))
        }
    }

    func toggle(_ item: ShoppingItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isPurchased.toggle()
        }
    }

    func remove(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}
