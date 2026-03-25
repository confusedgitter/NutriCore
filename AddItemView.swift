//
//  AddItemView.swift
//  NutriCore
//

import SwiftUI

struct AddItemView: View {
    
    @ObservedObject var viewModel: InventoryViewModel
    
    var existingItem: FoodItem? = nil
    
    @State private var name = ""
    @State private var quantity = 1
    @State private var expiryDate = Date()
    @State private var showingScanner = false
    @State private var isLookingUp = false
    
    @Environment(\.dismiss) var dismiss
    
    private func handleScannedCode(_ code: String) {
        isLookingUp = true
        
        Task {
            let result = await ProductLookupService.lookup(barcode: code)
            await MainActor.run {
                name = result ?? "Unknown item"
                isLookingUp = false
            }
        }
    }
    
    var suggestions: [String] {
        let catalog = ["Milk", "Eggs", "Bread", "Rice", "Tomato", "Onion", "Banana", "Peanut Butter"]

        if name.isEmpty { return [] }

        return catalog.filter {
            $0.lowercased().contains(name.lowercased())
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Food Name", text: $name)
                }
                
                if isLookingUp {
                    Section {
                        HStack {
                            ProgressView()
                            Text("Looking up product...")
                        }
                    }
                }
                
                if !suggestions.isEmpty {
                    Section("Suggestions") {
                        ForEach(suggestions, id: \.self) { item in
                            Button(item) {
                                name = item
                            }
                        }
                    }
                }
                
                Section("Popular") {
                    let popularItems = ["Milk", "Eggs", "Bread", "Rice", "Tomato", "Onion", "Banana"]

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                        ForEach(popularItems, id: \.self) { item in
                            Button(item) {
                                name = item
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                }

                Section {
                    Button("Scan Barcode") {
                        showingScanner = true
                    }
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
                            if let existingItem {
                                let updatedItem = FoodItem(
                                    id: existingItem.id,
                                    name: name,
                                    quantity: quantity,
                                    expiryDate: expiryDate,
                                    status: existingItem.status,
                                    completedDate: existingItem.completedDate
                                )
                                viewModel.updateItem(updatedItem)
                            } else {
                                let newItem = FoodItem(
                                    id: UUID(),
                                    name: name,
                                    quantity: quantity,
                                    expiryDate: expiryDate
                                )
                                viewModel.addItem(newItem)
                            }
                            dismiss()
                        }
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                BarcodeScannerView { code in
                    handleScannedCode(code)
                }
            }
            .onAppear {
                if let existingItem {
                    name = existingItem.name
                    quantity = existingItem.quantity
                    expiryDate = existingItem.expiryDate
                }
            }
        }
    }
}

#Preview {
    AddItemView(viewModel: InventoryViewModel())
}
