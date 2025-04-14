//
//  ContentView.swift
//  FridgeFriend
//
//  Created by Colin James on 2/22/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var selectedTab = 0
    @State private var recipeInitialTab = 0
    @State private var isFromSuggestRecipes = false
    
    var body: some View {
        
        //For login screen on launch TODO
        if viewModel.userSession != nil {
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab, isFromSuggestRecipes: $isFromSuggestRecipes)
                    .tabItem{
                        Label("Home", systemImage: "house")
                    }
                    .tag(0)
                InventoryView()
                    .tabItem{
                        Label("Inventory", systemImage: "cart")
                    }
                    .tag(1)
                ScanReceiptView()
                    .tabItem{
                        Label("Scan", systemImage: "plus.circle")
                    }
                    .tag(2)
                RecipeView(initialTab: isFromSuggestRecipes ? 1 : 0)
                    .tabItem{
                        Label("Recipes", systemImage: "book")
                    }
                    .tag(3)
                    .onChange(of: selectedTab) { newValue in
                        if newValue != 3 {
                            isFromSuggestRecipes = false
                        }
                    }
                ProfileView()
                    .tabItem{
                        Label("Profile", systemImage: "person.circle")
                    }
                    .tag(4)
            }
            
        }
         else {
            LoginView()
        }
    }
    
}
 
    


#Preview {
    ContentView()
}
