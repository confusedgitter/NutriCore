import SwiftUI

struct MainTabView: View {
    
    @ObservedObject var viewModel: InventoryViewModel
    
    var body: some View {
        TabView {
            DashboardView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            InventoryView(viewModel: viewModel)
                .tabItem {
                    Label("Inventory", systemImage: "archivebox")
                }
            
            RecipesView(viewModel: viewModel)
                .tabItem {
                    Label("Recipes", systemImage: "fork.knife")
                }
            
            CaloriesView()
                .tabItem {
                    Label("Calories", systemImage: "flame.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}
