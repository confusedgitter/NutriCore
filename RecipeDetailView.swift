import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @ObservedObject var viewModel: InventoryViewModel
    @ObservedObject var shoppingManager = ShoppingListManager.shared
    @ObservedObject var calorieManager = CalorieManager.shared
    @State private var showSuccess = false
    @Environment(\.dismiss) private var dismiss

    var missingIngredients: [String] {
        recipe.ingredients.filter { ingredient in
            let ingredientKey = normalize(ingredient)

            return !shoppingManager.items.contains(where: { item in
                normalize(item.name).contains(ingredientKey)
            })
        }
    }

    var primaryIngredients: [String] {
        let ignore = ["salt", "oil", "water", "pepper", "sugar"]

        return recipe.ingredients.filter { ingredient in
            !ignore.contains { ignoreItem in
                ingredient.localizedCaseInsensitiveContains(ignoreItem)
            }
        }
    }

    func normalize(_ text: String) -> String {
        var value = text.lowercased()

        if value.hasSuffix("es") {
            value = String(value.dropLast(2))
        } else if value.hasSuffix("s") {
            value = String(value.dropLast())
        }

        let ignoreWords = ["fresh", "whole", "chopped", "sliced", "cup", "tbsp"]

        let words = value.split(separator: " ").filter {
            !ignoreWords.contains(String($0))
        }

        return words.joined(separator: " ")
    }

    func quantityFrom(_ ingredient: String) -> Double {
        let words = ingredient.lowercased().split(separator: " ")
        guard let first = words.first else { return 1 }

        if first.contains("/") {
            let parts = first.split(separator: "/")
            if parts.count == 2,
               let numerator = Double(parts[0]),
               let denominator = Double(parts[1]) {
                return numerator / denominator
            }
        }

        if first == "½" { return 0.5 }
        if first == "¼" { return 0.25 }
        if first == "¾" { return 0.75 }

        if let number = Double(first) {
            return number
        }

        return 1
    }

    func nameWithoutQuantity(_ ingredient: String) -> String {
        let words = ingredient.split(separator: " ")

        if let first = words.first,
           Double(first) != nil || first.contains("/") {
            return words.dropFirst().joined(separator: " ")
        }

        return ingredient
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(recipe.name)
                    .font(.largeTitle)
                    .bold()

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(recipe.totalCalories) kcal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text(recipe.healthCategory)
                        .font(.caption)
                        .foregroundColor(
                            recipe.healthCategory == "Healthy" ? .green :
                            recipe.healthCategory == "Moderate" ? .orange : .red
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredients")
                        .font(.headline)

                    ForEach(recipe.ingredients, id: \.self) { ingredient in
                        HStack {
                            Text(ingredient)
                            Spacer()
                            if missingIngredients.contains(where: {
                                $0.localizedCaseInsensitiveContains(ingredient)
                            }) {
                                Text("Missing")
                                    .font(.caption2)
                                    .foregroundColor(.red)
                            } else {
                                Text("Available")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Steps")
                        .font(.headline)

                    ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top) {
                            Text("\(index + 1).")
                                .bold()
                            Text(step)
                        }
                    }
                }

                if !missingIngredients.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Need to buy")
                            .font(.headline)

                        ForEach(missingIngredients, id: \.self) { ingredient in
                            Button {
                                shoppingManager.add(ingredient)
                            } label: {
                                HStack {
                                    Text(ingredient)
                                    Spacer()
                                    Image(systemName: "cart.badge.plus")
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }

                Button("Mark as Cooked") {
                    for ingredient in primaryIngredients {
                        let cleanName = nameWithoutQuantity(ingredient)
                        let quantity = quantityFrom(ingredient)
                        let ingredientKey = normalize(cleanName)

                        if let index = viewModel.items.firstIndex(where: { item in
                            normalize(item.name).contains(ingredientKey)
                        }) {
                            var item = viewModel.items[index]
                            let deduction = Int(ceil(quantity))

                            if item.quantity > deduction {
                                item.quantity -= deduction
                            } else {
                                item.status = .consumed
                                item.completedDate = Date()
                            }

                            viewModel.updateItem(item)
                        }
                    }

                    calorieManager.log(recipe: recipe)

                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)

                    showSuccess = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        showSuccess = false
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)

                if showSuccess {
                    Text("Inventory updated")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            .padding()
        }
        .navigationTitle("Recipe")
        .navigationBarTitleDisplayMode(.inline)
    }
}
