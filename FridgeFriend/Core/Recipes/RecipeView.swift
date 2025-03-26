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
    
    var body: some View {
        NavigationView {
            List(recipeService.recipes) { recipe in
                VStack(alignment: .leading) {
                    Text(recipe.title).font(.headline)
                    Text("Time to Cook: \(recipe.timeToCook, specifier: "%.1f") min")
                        .font(.subheadline)
                    Text("Ingredients: \(recipe.ingredients.joined(separator: ", "))")
                        .font(.subheadline)
                }
            }
            .navigationTitle("Recipes")
            .toolbar {
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
        }
    }
}

#Preview {
    RecipeView()
}
