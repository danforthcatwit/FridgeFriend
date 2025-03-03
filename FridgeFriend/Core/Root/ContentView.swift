//
//  ContentView.swift
//  FridgeFriend
//
//  Created by Colin James on 2/22/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem{
                    Label("Home", systemImage: "house")
                }
            InventoryView()
                .tabItem{
                    Label("Inventory", systemImage: "cart")
                }
            ScanReceiptView()
                .tabItem{
                    Label("Scan", systemImage: "plus.circle")
                }
            RecipeView()
                .tabItem{
                    Label("Recipes", systemImage: "book")
                }
            ProfileView()
                .tabItem{
                    Label("Profile", systemImage: "person.circle")
                }
        }
 
    }
}

#Preview {
    ContentView()
}
