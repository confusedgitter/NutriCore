import SwiftUI
import Charts

struct DashboardView: View {
    
    @ObservedObject var viewModel: InventoryViewModel
    @ObservedObject var progressEngine = ProgressEngine.shared
    @StateObject private var recipeEngine = RecipeEngine()
    @State private var isSuggestedActionExpanded = false
    @State private var highlightBestOption = false
    
    private var expiryChartData: [(String, Int)] {
        [
            ("Active", viewModel.activeItems.count),
            ("Expiring Soon", viewModel.expiringSoonItems.count),
            ("Expired", viewModel.expiredItems.count),
            ("Consumed", viewModel.consumedItems.count),
            ("Wasted", viewModel.wastedItems.count)
        ]
    }
    
    private var last7DaysData: [(String, Int, Int)] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<7).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            let label = DateFormatter.shortWeekday.string(from: date)
            
            let consumed = viewModel.items.filter {
                $0.status == .consumed &&
                $0.completedDate != nil &&
                calendar.isDate($0.completedDate!, inSameDayAs: date)
            }.count
            
            let wasted = viewModel.items.filter {
                $0.status == .wasted &&
                $0.completedDate != nil &&
                calendar.isDate($0.completedDate!, inSameDayAs: date)
            }.count
            
            return (label, consumed, wasted)
        }
    }
    
    private var mostWastedItem: String? {
        let wastedItems = viewModel.items.filter { $0.status == .wasted }
        let grouped = Dictionary(grouping: wastedItems, by: { $0.name })
        let sorted = grouped.sorted { $0.value.count > $1.value.count }
        return sorted.first?.key
    }
    
    private var mostConsumedItem: String? {
        let consumedItems = viewModel.items.filter { $0.status == .consumed }
        let grouped = Dictionary(grouping: consumedItems, by: { $0.name })
        let sorted = grouped.sorted { $0.value.count > $1.value.count }
        return sorted.first?.key
    }

    private var recommendationText: String? {
        if let wasted = mostWastedItem {
            return "You waste \(wasted) often — consider buying less"
        } else if let consumed = mostConsumedItem {
            return "You frequently use \(consumed) — consider stocking more"
        } else {
            return nil
        }
    }

    private var suggestedItems: [String] {
        let items = viewModel.expiringSoonItems.prefix(3)
        return items.map { $0.name }
    }
    
    private var bestRecipeToday: Recipe? {
        viewModel.bestRecipeMatch(from: recipeEngine.recipes)
    }

    private var bestRecipeSavedItems: [String] {
        guard let bestRecipeToday else { return [] }
        return viewModel.savedItems(for: bestRecipeToday)
    }

    private var urgentExpiryText: String? {
        guard let urgentItem = viewModel.expiringSoonItems.first else { return nil }

        let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: urgentItem.expiryDate).day ?? 0

        let urgencyText: String
        if daysLeft <= 0 {
            urgencyText = "expires today"
        } else if daysLeft == 1 {
            urgencyText = "expires in 1 day"
        } else {
            urgencyText = "expires in \(daysLeft) days"
        }

        return "⚠️ \(urgentItem.name) \(urgencyText)"
    }

    private var dailyTip: String {
        if let bestRecipeToday, bestRecipeSavedItems.count > 0 {
            return "Cooking \(bestRecipeToday.name) today helps reduce waste"
        } else if viewModel.wastedThisWeek > 3 {
            return "You're wasting more this week — try cooking expiring items first"
        } else if viewModel.expiringSoonItems.count > 0 {
            return "Cook items that expire soon to reduce waste"
        } else if viewModel.consumedThisWeek > 5 {
            return "Great job using your inventory efficiently"
        } else {
            return "Plan meals ahead to stay on track"
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    VStack(spacing: 4) {
                        Text("NutriCore")
                            .font(.largeTitle)
                            .bold()

                        Text("Your Smart Food & Nutrition Manager")
                            .foregroundColor(.gray)
                    }
                    HStack(spacing: 12) {
                        NavigationLink(destination: InventoryView(viewModel: viewModel)) {
                            Label("View Inventory", systemImage: "archivebox")
                                .frame(maxWidth: .infinity)
                        }
                        
                        NavigationLink(destination: RecipesView(viewModel: viewModel, suggestedIngredients: suggestedItems)) {
                            Label("Find Recipes", systemImage: "fork.knife")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)

                    if !suggestedItems.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isSuggestedActionExpanded.toggle()
                                }
                            } label: {
                                HStack {
                                    Text("Suggested Action")
                                        .font(.headline)
                                        .foregroundColor(.primary)

                                    Spacer()

                                    Image(systemName: isSuggestedActionExpanded ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .buttonStyle(.plain)

                            if isSuggestedActionExpanded {
                                Text("Use these items before they expire:")
                                    .font(.subheadline)

                                VStack(alignment: .leading, spacing: 6) {
                                    ForEach(Array(suggestedItems.enumerated()), id: \.offset) { index, item in
                                        HStack(alignment: .top, spacing: 8) {
                                            Text("\(index + 1).")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            Text(item)
                                                .font(.caption)
                                        }
                                    }
                                }

                                NavigationLink(destination: RecipesView(viewModel: viewModel, suggestedIngredients: suggestedItems)) {
                                    Text("Find recipes using these items")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            } else {
                                Text(suggestedItems.prefix(2).joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    if !dailyTip.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("💡 Tip")
                                .font(.headline)

                            Text(dailyTip)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray5))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    if let bestRecipeToday {
                        NavigationLink(destination: RecipeDetailView(recipe: bestRecipeToday, viewModel: viewModel)) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("🔥 Best option today")
                                    .font(.headline)

                                Text(bestRecipeToday.name)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)

                                Text("Saves \(bestRecipeSavedItems.count) item\(bestRecipeSavedItems.count > 1 ? "s" : "")")
                                    .font(.caption)
                                    .foregroundColor(.green)

                                Text(bestRecipeSavedItems.prefix(3).joined(separator: ", "))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)

                                if let urgentExpiryText {
                                    Text(urgentExpiryText)
                                        .font(.caption2)
                                        .foregroundColor(.red)
                                }

                                Text("Tap to cook")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                highlightBestOption
                                ? Color.green.opacity(0.08)
                                : Color(.systemGray6)
                            )
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }
                    
                    Chart {
                        ForEach(expiryChartData, id: \.0) { item in
                            SectorMark(
                                angle: .value("Count", item.1),
                                innerRadius: .ratio(0.6),
                                angularInset: 2
                            )
                            .foregroundStyle(by: .value("Category", item.0))
                        }
                    }
                    .frame(height: 280)
                    .chartLegend(position: .bottom, alignment: .center)
                    .padding()
                    
                    VStack(spacing: 8) {
                        Text("Weekly Efficiency")
                            .font(.headline)
                        
                        Text("\(Int(viewModel.weeklyEfficiencyPercentage))%")
                            .font(.title)
                            .bold()
                            .foregroundColor(viewModel.weeklyEfficiencyPercentage >= 70 ? .green : .orange)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("This Week")
                            .font(.headline)

                        Text("\(viewModel.consumedThisWeek) consumed • \(viewModel.wastedThisWeek) wasted")
                            .font(.subheadline)

                        Text("Waste rate: \(Int(viewModel.wasteRate * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        if viewModel.weeklyEfficiencyChange != 0 {
                            Text(
                                viewModel.weeklyEfficiencyChange > 0
                                ? "Improved by \(Int(viewModel.weeklyEfficiencyChange))% vs last week"
                                : "Dropped by \(Int(abs(viewModel.weeklyEfficiencyChange)))% vs last week"
                            )
                            .font(.caption2)
                            .foregroundColor(viewModel.weeklyEfficiencyChange > 0 ? .green : .red)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Weekly Impact")
                                .font(.headline)

                            Spacer()

                            Text("🌱")
                        }

                        Text("\(viewModel.savedThisWeekCount)")
                            .font(.system(size: 34, weight: .bold))

                        Text("items saved this week")
                            .font(.subheadline)

                        if viewModel.savedThisWeekCount == 0 {
                            Text("Start cooking expiring items to reduce waste")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else if viewModel.savedThisWeekCount < 5 {
                            Text("Good start — keep going")
                                .font(.caption)
                                .foregroundColor(.orange)
                        } else {
                            Text("Excellent work — you're reducing waste")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Last 7 Days")
                            .font(.headline)

                        Chart {
                            ForEach(last7DaysData, id: \.0) { item in
                                BarMark(
                                    x: .value("Day", item.0),
                                    y: .value("Consumed", item.1)
                                )
                                .foregroundStyle(.green)

                                BarMark(
                                    x: .value("Day", item.0),
                                    y: .value("Wasted", item.2)
                                )
                                .foregroundStyle(.red)
                            }
                        }
                        .frame(height: 200)

                        HStack(spacing: 16) {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                Text("Consumed")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }

                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                Text("Wasted")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }

                        if last7DaysData.allSatisfy({ $0.1 == 0 && $0.2 == 0 }) {
                            Text("No activity in the last 7 days")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else if viewModel.wastedThisWeek == 0 {
                            Text("Great job — no food wasted this week")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Text("Keep improving — reduce waste where possible")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        if let recommendationText {
                            Text(recommendationText)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Daily Progress
                    VStack(spacing: 10) {
                        Text("Daily Progress")
                            .font(.headline)
                        
                        HStack {
                            Text("🔥 Workout Streak")
                            Spacer()
                            Text("\(progressEngine.workoutStreak()) days")
                        }
                        
                        HStack {
                            Text("🥗 Meal Streak")
                            Spacer()
                            Text("\(progressEngine.healthyMealStreak()) days")
                        }
                        
                        HStack {
                            Text("⭐ Health Score")
                            Spacer()
                            Text("\(progressEngine.healthScore())")
                        }
                        if progressEngine.workoutStreak() >= 5 {
                            Text("🔥 Great consistency — keep your streak going")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else if progressEngine.workoutStreak() == 0 {
                            Text("Start your streak today")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        if progressEngine.healthyMealStreak() >= 5 {
                            Text("🥗 Strong nutrition streak — keep it up")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else if progressEngine.healthyMealStreak() == 0 {
                            Text("Log your first healthy meal today")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }

                        // Achievements
                        if progressEngine.workoutStreak() >= 7 {
                            Text("🏆 7-Day Workout Streak")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }

                        if viewModel.wastedThisWeek == 0 && viewModel.consumedThisWeek > 0 {
                            Text("🌱 Zero Waste Week")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // Removed Spacer() to reduce bottom cramping
                }
                .padding(.top, 12)
                .padding(.bottom, 110)
                .task {
                    await recipeEngine.generateRecipes(from: viewModel.activeItems)

                    withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                        highlightBestOption.toggle()
                    }
                }
            }
        }
    }
}

extension DateFormatter {
    static let shortWeekday: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
}
 
