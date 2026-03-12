import SwiftUI
import Charts

struct DashboardView: View {
    
    @ObservedObject var viewModel: InventoryViewModel
    @ObservedObject var progressEngine = ProgressEngine.shared
    
    private var expiryChartData: [(String, Int)] {
        [
            ("Active", viewModel.activeItems.count),
            ("Expiring Soon", viewModel.expiringSoonItems.count),
            ("Expired", viewModel.expiredItems.count),
            ("Consumed", viewModel.consumedItems.count),
            ("Wasted", viewModel.wastedItems.count)
        ]
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
                    if viewModel.expiringSoonItems.count > 0 {
                        Text("⚠️ High Risk: \(viewModel.expiringSoonItems.count) items expiring soon")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(12)
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
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top)
            }
        }
    }
}
