//
//  InventoryView.swift
//  NutriCore
//

import SwiftUI
import UIKit

struct InventoryView: View {
    
    @ObservedObject var viewModel: InventoryViewModel
    @State private var showingAddItem = false
    @State private var editingItem: FoodItem?
    
    private var filteredItems: [FoodItem] {
        switch selectedFilter {
        case .active:
            return viewModel.activeItems.sorted { $0.expiryDate < $1.expiryDate }
        case .consumed:
            return viewModel.consumedItems
        case .wasted:
            return viewModel.wastedItems
        }
    }
    
    private func expiryColor(for item: FoodItem) -> Color {
        
        // Consumed items should appear neutral, not expired
        if item.status == .consumed {
            return .secondary
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let expiry = Calendar.current.startOfDay(for: item.expiryDate)
        
        if expiry < today {
            return .red
        } else if expiry <= Calendar.current.date(byAdding: .day, value: 2, to: today)! {
            return .orange
        } else {
            return .green
        }
    }

    private func expiryText(for item: FoodItem) -> String {
        let today = Calendar.current.startOfDay(for: Date())
        let expiry = Calendar.current.startOfDay(for: item.expiryDate)
        
        let components = Calendar.current.dateComponents([.day], from: today, to: expiry)
        let days = components.day ?? 0
        
        if days < 0 {
            let absDays = abs(days)
            return absDays == 1
                ? "Expired 1 day ago"
                : "Expired \(absDays) days ago"
        } else if days == 0 {
            return "Expires today"
        } else if days == 1 {
            return "Expires tomorrow"
        } else {
            return "Expires in \(days) days"
        }
    }
    enum FilterType: String, CaseIterable {
        case active = "Active"
        case consumed = "Consumed"
        case wasted = "Wasted"
    }
    @State private var selectedFilter: FilterType = .active
    
    private func delete(_ item: FoodItem) {
        if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            withAnimation(.spring()) {
                viewModel.items.remove(at: index)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(FilterType.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                HStack(spacing: 8) {
                    Text("\(viewModel.items.count) items")
                    Text("•")
                    Text("\(viewModel.activeItems.filter { expiryColor(for: $0) != .green }.count) expiring soon")
                    Text("•")
                    Text("\(viewModel.wastedItems.count) wasted")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                
                List {
                    ForEach(filteredItems) { item in
                        HStack(spacing: 12) {
                            
                            Rectangle()
                                .fill(expiryColor(for: item))
                                .frame(width: 4)
                                .cornerRadius(2)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(item.name)
                                        .font(.headline)
                                        .foregroundColor(item.status == .active ? .primary : .secondary)
                                        .strikethrough(item.status != .active)
                                    
                                    Spacer()
                                    
                                    Text("Qty: \(item.quantity)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(expiryText(for: item))
                                    .font(.caption)
                                    .foregroundColor(expiryColor(for: item))
                                
                                if item.status != .active {
                                    Text(item.status == .consumed ? "Consumed" : "Wasted")
                                        .font(.caption2)
                                        .foregroundColor(item.status == .consumed ? .green : .red)
                                }
                            }
                        }
                        .onTapGesture {
                            editingItem = item
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()

                                if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
                                    let item = viewModel.items[index]
                                    NotificationManager.shared.cancelNotifications(for: item)
                                    viewModel.items[index].status = .consumed
                                    viewModel.items[index].completedDate = Date()
                                }
                            } label: {
                                Label("Consumed", systemImage: "checkmark.circle")
                            }
                            .tint(.green)
                            
                            Button {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()

                                if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
                                    let item = viewModel.items[index]
                                    NotificationManager.shared.cancelNotifications(for: item)
                                    viewModel.items[index].status = .wasted
                                    viewModel.items[index].completedDate = Date()
                                }
                            } label: {
                                Label("Wasted", systemImage: "xmark.circle")
                            }
                            .tint(.red)
                            
                            Button(role: .destructive) {
                                delete(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Inventory")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView(viewModel: viewModel)
            }
            .sheet(item: $editingItem) { item in
                AddItemView(viewModel: viewModel, existingItem: item)
            }
        }
    }
}

#Preview {
    InventoryView(viewModel: InventoryViewModel())
}
