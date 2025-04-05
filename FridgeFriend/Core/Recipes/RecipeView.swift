//
//  RecipeView.swift
//  FridgeFriend
//
//  Created by Colin James on 2/27/25.
//

import SwiftUI

struct RecipeView: View {
    @StateObject private var recipeService = RecipeService()
    @StateObject private var inventoryViewModel = InventoryViewModel()
    @State private var showingAddRecipe = false
    @State private var selectedRecipe: Recipe?
    @State private var selectedTab: Int
    let initialTab: Int
    
    init(initialTab: Int = 0) {
        self.initialTab = initialTab
        _selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        NavigationView {
            VStack {
                // Picker to toggle between Custom and Suggested Recipes
                Picker("Recipe Type", selection: $selectedTab) {
                    Text("Custom Recipes").tag(0)
                    Text("Suggested Recipes").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Display content based on selected tab
                if selectedTab == 0 {
                    // Custom Recipes
                    List {
                        ForEach(recipeService.recipes, id: \.uniqueIdentifier) { recipe in
                            Button(action: {
                                selectedRecipe = recipe
                            }) {
                                VStack(alignment: .leading) {
                                    Text(recipe.title)
                                        .font(.headline)
                                    Text("Time to Cook: \(recipe.timeToCook, specifier: "%.1f") min")
                                        .font(.subheadline)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let recipe = recipeService.recipes[index]
                                recipeService.deleteRecipe(recipe) { error in
                                    if let error = error {
                                        print("Error deleting recipe: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                    }
                } else {
                    // Suggested Recipes
                    List {
                        ForEach(inventoryViewModel.suggestedRecipes, id: \.uniqueIdentifier) { recipe in
                            Button(action: {
                                selectedRecipe = recipe
                            }) {
                                VStack(alignment: .leading) {
                                    Text(recipe.title)
                                        .font(.headline)
                                    Text("Time to Cook: \(recipe.timeToCook, specifier: "%.1f") min")
                                        .font(.subheadline)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
            .toolbar {
                if selectedTab == 0 {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingAddRecipe = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .task {
                // Load both custom and suggested recipes when the view appears
                recipeService.fetchUserRecipes()
                inventoryViewModel.fetchSuggestedRecipes()
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView()
            }
            .sheet(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipe: recipe, inventoryViewModel: inventoryViewModel)
            }
        }
    }
}
