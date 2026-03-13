//
//  shoppingListView.swift
//  NutriCore
//
//  Created by Mukunth Parthasarathy on 12/03/2026.
//

import SwiftUI

struct ShoppingListView: View {
    @ObservedObject var manager = ShoppingListManager.shared

    var body: some View {
        NavigationStack {
            List {
                ForEach(manager.items) { item in
                    HStack {
                        Text(item.name)

                        Spacer()

                        Image(systemName: item.isPurchased ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(item.isPurchased ? .green : .gray)
                            .onTapGesture {
                                manager.toggle(item)
                            }
                    }
                }
                .onDelete(perform: manager.remove)
            }
            .navigationTitle("Shopping List")
        }
    }
}
