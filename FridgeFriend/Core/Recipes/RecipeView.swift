//
//  RecipeView.swift
//  FridgeFriend
//
//  Created by Colin James on 2/27/25.
//

import SwiftUI

struct RecipeView: View {
    @StateObject private var recipeService = RecipeService()
    @State private var showingAddRecipe = false
    @State private var selectedRecipe: Recipe?
    @StateObject private var inventoryViewModel = InventoryViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(recipeService.recipes) { recipe in
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
            .navigationTitle("Recipes")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddRecipe = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                recipeService.fetchUserRecipes()
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
