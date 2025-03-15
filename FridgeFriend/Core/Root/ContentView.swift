//
//  ContentView.swift
//  FridgeFriend
//
//  Created by Colin James on 2/22/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        
        //For login screen on launch TODO
        if viewModel.userSession != nil {
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
         else {
            LoginView()
        }
    }
    
}
 
    


#Preview {
    ContentView()
}
