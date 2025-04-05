//
//  RecipeDetailView.swift
//  FridgeFriend
//
//  Created by Denis Le on 3/27/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct RecipeDetailView: View {
    let recipe: Recipe
    @ObservedObject var inventoryViewModel: InventoryViewModel
    @State private var showingUseRecipeError = false
    @State private var errorMessage: String?
    @State private var showingConfirmation = false
    @State private var confirmationMessage: String?
    @State private var hasCheckedIngredients = false
    @State private var canUseRecipe = false
    @State private var isProcessingRecipe = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let imageURL = recipe.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: 250)
                                .clipped()
                                .cornerRadius(12)
                        case .failure:
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .frame(maxWidth: .infinity, maxHeight: 250)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(recipe.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.secondary)
                        Text("\(recipe.timeToCook, specifier: "%.0f") minutes")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Ingredients")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    if !recipe.ingredients.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            if let usedCount = recipe.usedIngredientCount {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("From Your Inventory (\(usedCount))")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                                .padding(.bottom, 4)
                            }
                            
                            ForEach(recipe.ingredients, id: \.self) { ingredient in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 6))
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                    Text(ingredient)
                                        .font(.body)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(minHeight: 44)
                            }
                        }
                        .padding(16)
                        .background(Color(.systemGreen).opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    } else {
                        Text("No ingredients listed")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    
                    if let missedCount = recipe.missedIngredientCount,
                       let missedIngredients = recipe.missedIngredients,
                       !missedIngredients.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("Missing Ingredients (\(missedCount))")
                                    .font(.headline)
                                    .foregroundColor(.red)
                            }
                            .padding(.bottom, 4)
                            
                            ForEach(missedIngredients, id: \.self) { ingredient in
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 6))
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                    Text(ingredient)
                                        .font(.body)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(minHeight: 44)
                            }
                        }
                        .padding(16)
                        .background(Color(.systemRed).opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Instructions")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if let instructions = recipe.instructions {
                        Text(instructions)
                            .font(.body)
                            .lineSpacing(4)
                    } else {
                        Text("Instructions not available for this recipe. Please visit Spoonacular for full recipe details.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                VStack(spacing: 12) {
                    // Check Ingredients Button
                    Button(action: {
                        guard !isProcessingRecipe else { return }
                        isProcessingRecipe = true
                        inventoryViewModel.checkRecipeIngredients(recipe)
                        hasCheckedIngredients = true
                        canUseRecipe = inventoryViewModel.outOfStockIngredients.isEmpty
                        isProcessingRecipe = false
                    }) {
                        HStack {
                            Image(systemName: "checklist")
                            Text("Check Ingredients")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .disabled(isProcessingRecipe)
                    
                    // Use Recipe Button
                    Button(action: {
                        guard !isProcessingRecipe else { return }
                        isProcessingRecipe = true
                        inventoryViewModel.useRecipe(recipe)
                        confirmationMessage = "Successfully used recipe. Ingredients updated."
                        showingConfirmation = true
                        isProcessingRecipe = false
                    }) {
                        HStack {
                            Image(systemName: "cart.fill")
                            Text("Use Recipe")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(canUseRecipe ? Color.accentColor : Color.gray)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .disabled(!canUseRecipe || isProcessingRecipe)
                    
                    if hasCheckedIngredients {
                        if canUseRecipe {
                            Text("✅ You have all required ingredients!")
                                .foregroundColor(.green)
                                .font(.subheadline)
                                .padding(.horizontal)
                        } else {
                            Text("❌ Missing some ingredients")
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, 20)
            }
            .padding(.vertical, 20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $showingUseRecipeError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
        .alert("Missing Ingredients", isPresented: $inventoryViewModel.showingMissingIngredientsAlert) {
            Button("Add to Inventory", role: .none) {
                inventoryViewModel.addMissingIngredientsToInventory()
                // Update canUseRecipe based on current state
                canUseRecipe = inventoryViewModel.outOfStockIngredients.isEmpty
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(missingIngredientsMessage)
        }
        .alert("Recipe Used", isPresented: $showingConfirmation) {
            Button("OK", role: .cancel) {
                // Reset states after successful use
                hasCheckedIngredients = false
                canUseRecipe = false
            }
        } message: {
            Text(confirmationMessage ?? "Ingredients updated.")
        }
    }

    private var missingIngredientsMessage: String {
        let missingItems = inventoryViewModel.outOfStockIngredients.map { ingredient in
            let missing = ingredient.required - ingredient.available
            return "\(ingredient.name): need \(missing) more (have \(ingredient.available))"
        }
        return "You're missing these ingredients:\n\n" + missingItems.joined(separator: "\n")
    }
}
