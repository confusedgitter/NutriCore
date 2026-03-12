//
//  AddItemView.swift
//  NutriCore
//

import SwiftUI

struct AddItemView: View {
    
    @ObservedObject var viewModel: InventoryViewModel
    
    @State private var name = ""
    @State private var quantity = 1
    @State private var expiryDate = Date()
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Food Name", text: $name)
                }
                
                Section {
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...100)
                }
                
                Section {
                    DatePicker("Expiry Date",
                               selection: $expiryDate,
                               displayedComponents: .date)
                }
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !name.isEmpty {
                            let newItem = FoodItem(
                                id: UUID(),
                                name: name,
                                quantity: quantity,
                                expiryDate: expiryDate
                            )
                            
                            viewModel.addItem(newItem)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AddItemView(viewModel: InventoryViewModel())
}
