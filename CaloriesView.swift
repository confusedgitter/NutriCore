import SwiftUI
import Charts

struct CaloriesView: View {
    @ObservedObject var calorieManager = CalorieManager.shared
    @State private var goalDraft: Double = Double(CalorieManager.shared.dailyGoal)

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }

    private var visibleTodayEntries: [CalorieEntry] {
        calorieManager.todayEntries.filter { $0.calories > 0 }
    }

    private var last7DaysCalories: [(String, Int)] {
        let calendar = Calendar.current
        let today = Date()

        return (0..<7).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            let formatter = DateFormatter()
            formatter.dateFormat = "E"
            let label = formatter.string(from: date)

            let total = calorieManager.entries
                .filter { calendar.isDate($0.date, inSameDayAs: date) }
                .reduce(0) { $0 + $1.calories }

            return (label, total)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Calories")
                    .font(.largeTitle)
                    .bold()

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Today")
                            .font(.headline)

                        Spacer()

                        Text("🔥")
                    }

                    Text("\(calorieManager.todayCalories) kcal")
                        .font(.system(size: 34, weight: .bold))

                    ProgressView(value: calorieManager.progress)
                        .tint(.green)
                        .animation(.easeInOut, value: calorieManager.progress)

                    Text("\(calorieManager.todayCalories) / \(calorieManager.dailyGoal) kcal")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Daily Goal")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            Text("\(Int(goalDraft)) kcal")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Slider(value: $goalDraft, in: 1200...3500, step: 50)
                            .tint(.green)
                            .onChange(of: goalDraft) { _, newValue in
                                calorieManager.updateDailyGoal(Int(newValue))
                            }
                    }

                    if calorieManager.todayCalories == 0 {
                        Text("No calories logged today yet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if calorieManager.todayCalories < calorieManager.dailyGoal {
                        Text("You're on track today")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Text("You've reached your daily goal")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Last 7 Days")
                        .font(.headline)

                    Chart {
                        ForEach(last7DaysCalories, id: \.0) { item in
                            BarMark(
                                x: .value("Day", item.0),
                                y: .value("Calories", item.1)
                            )
                            .foregroundStyle(item.1 > calorieManager.dailyGoal ? .orange : .green)
                        }
                    }
                    .frame(height: 180)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Today's Meals")
                        .font(.headline)

                    if visibleTodayEntries.isEmpty {
                        Text("No meals logged yet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        let sortedEntries = visibleTodayEntries.sorted { $0.date > $1.date }

                        ForEach(sortedEntries) { entry in
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.recipeName)
                                        .font(.subheadline)

                                    Text(timeFormatter.string(from: entry.date))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Text("\(entry.calories) kcal")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)

                            if entry.id != sortedEntries.last?.id {
                                Divider()
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
        }
        .onAppear {
            goalDraft = Double(calorieManager.dailyGoal)
        }
    }
}
