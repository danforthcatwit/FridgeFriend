//
//  AddRecipeView.swift
//  FridgeFriend
//
//  Created by Denis Le on 3/26/25.
//

import SwiftUI
import FirebaseAuth

struct IngredientInput: Identifiable {
    let id = UUID()
    var name: String
    var quantity: String
}

struct AddRecipeView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @StateObject private var recipeService = RecipeService()
    
    // Form inputs
    @State private var title = ""
    @State private var ingredientInputs: [IngredientInput] = [IngredientInput(name: "", quantity: "")]
    @State private var instructions = ""
    @State private var timeToCook: Double = 0.0
    
    // UI States
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) { // Increased spacing between sections
                    // Title Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recipe Title")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter recipe title", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44) // Minimum touch target
                    }
                    .padding(.horizontal)
                    
                    // Ingredients Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Ingredients")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button(action: {
                                ingredientInputs.append(IngredientInput(name: "", quantity: ""))
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add")
                                }
                                .foregroundColor(.blue)
                            }
                            .frame(height: 44) // Minimum touch target
                        }
                        
                        ForEach($ingredientInputs) { $ingredient in
                            HStack(spacing: 12) {
                                TextField("Ingredient name", text: $ingredient.name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(height: 44)
                                
                                TextField("Amount", text: $ingredient.quantity)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 100, height: 44)
                                    .keyboardType(.decimalPad)
                                
                                Button(action: {
                                    if let index = ingredientInputs.firstIndex(where: { $0.id == ingredient.id }) {
                                        ingredientInputs.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                        .frame(width: 44, height: 44) // Minimum touch target
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Instructions Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructions")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $instructions)
                            .frame(minHeight: 150)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .font(.body)
                    }
                    .padding(.horizontal)
                    
                    // Cooking Time Section

                    
                    // Save Button
                    Button(action: saveRecipe) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Save Recipe")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50) // Larger touch target for primary action
                    .background(title.isEmpty ? Color.blue.opacity(0.5) : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(title.isEmpty || isLoading)
                }
                .padding(.vertical)
            }
            .navigationTitle("Add Recipe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .frame(width: 44, height: 44)
                }
            }
            .alert("Recipe Status", isPresented: $showingAlert) {
                Button("OK") {
                    if !alertMessage.contains("Error") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveRecipe() {
        guard let userId = Auth.auth().currentUser?.uid else {
            alertMessage = "Error: User not logged in"
            showingAlert = true
            return
        }
        
        guard !title.isEmpty else {
            alertMessage = "Please enter a recipe title"
            showingAlert = true
            return
        }
        
        isLoading = true
        
        let formattedIngredients = ingredientInputs
            .filter { !$0.name.isEmpty }
            .map { "\($0.name) - \($0.quantity)" }
        
        let recipe = Recipe(
            userId: userId,
            title: title,
            ingredients: formattedIngredients,
            instructions: instructions,
            timeToCook: timeToCook
        )
        
        recipeService.addRecipe(recipe) { error in
            isLoading = false
            if let error = error {
                alertMessage = "Error adding recipe: \(error.localizedDescription)"
            } else {
                alertMessage = "Recipe saved successfully!"
            }
            showingAlert = true
        }
    }
}
