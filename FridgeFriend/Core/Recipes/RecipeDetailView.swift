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
            VStack(alignment: .leading, spacing: 10) {
                if let imageURL = recipe.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .cornerRadius(10)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                Text(recipe.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Time to Cook: \(recipe.timeToCook, specifier: "%.1f") min")
                    .font(.headline)

                Text("Ingredients")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(recipe.ingredients.joined(separator: ", "))
                    .font(.body)

                Text("Instructions")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(recipe.instructions)
                    .font(.body)

                // Use Recipe Button
                Button(action: {
                    inventoryViewModel.useRecipe(recipe)
                    if inventoryViewModel.outOfStockIngredients.isEmpty {
                        confirmationMessage = "Successfully used recipe. Ingredients updated."
                        showingConfirmation = true
                    } else {
                        showingAlert = true
                    }
                }) {
                    Text("Use Recipe")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                .alert(isPresented: $showingUseRecipeError) {
                    Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
                }
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("Out of Stock"),
                        message: Text("You're missing: \(inventoryViewModel.outOfStockIngredients.joined(separator: ", "))"),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .alert(isPresented: $showingConfirmation) {
                    Alert(
                        title: Text("Recipe Used"),
                        message: Text(confirmationMessage ?? "Ingredients updated."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Recipe Details")
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
