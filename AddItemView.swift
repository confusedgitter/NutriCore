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
    @State private var showingScanner = false
    
    @Environment(\.dismiss) var dismiss
    
    private func handleScannedCode(_ code: String) {
        name = ProductLookupService.name(for: code)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Food Name", text: $name)
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
            .sheet(isPresented: $showingScanner) {
                BarcodeScannerView { code in
                    handleScannedCode(code)
                }
            }
        }
    }
}

#Preview {
    AddItemView(viewModel: InventoryViewModel())
}
