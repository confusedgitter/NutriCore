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
            
            Text("Calories")
                .tabItem {
                    Label("Calories", systemImage: "flame")
                }
            
            Text("Profile")
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}
