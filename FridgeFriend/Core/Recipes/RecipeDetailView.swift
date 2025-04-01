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
    @State private var showingAlert = false
    @State private var showingConfirmation = false
    @State private var confirmationMessage: String?

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
                
                Button(action: {
                    inventoryViewModel.useRecipe(recipe)
                    if inventoryViewModel.outOfStockIngredients.isEmpty {
                        confirmationMessage = "Successfully used recipe. Ingredients updated."
                        showingConfirmation = true
                    } else {
                        showingAlert = true
                    }
                }) {
                    HStack {
                        Image(systemName: "cart.fill")
                        Text("Use Recipe")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.accentColor)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
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
        .alert("Out of Stock", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You're missing: \(inventoryViewModel.outOfStockIngredients.joined(separator: ", "))")
        }
        .alert("Recipe Used", isPresented: $showingConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(confirmationMessage ?? "Ingredients updated.")
        }
    }

    // Function to update inventory
    func useRecipe() {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "User not logged in"
            showingUseRecipeError = true
            return
        }

        let inventoryRef = Firestore.firestore().collection("users").document(userID).collection("inventoryItems")

        var usedIngredients: [String] = []

        for ingredient in recipe.ingredients {
            inventoryRef.whereField("name", isEqualTo: ingredient).getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching inventory item: \(error)")
                    return
                }

                guard let document = snapshot?.documents.first else {
                    print("Ingredient \(ingredient) not found in inventory")
                    return
                }

                let item = try? document.data(as: InventoryItem.self)
                if var item = item, item.quantity > 0 {
                    item.quantity -= 1 // Reduce quantity by 1
                    usedIngredients.append("\(ingredient) (-1)")
                    do {
                        try inventoryRef.document(document.documentID).setData(from: item)
                    } catch {
                        print("Error updating ingredient: \(error)")
                    }
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Ensure updates reflect in UI
            confirmationMessage = "Used: \(usedIngredients.joined(separator: ", "))"
            showingConfirmation = true
        }
    }
}
