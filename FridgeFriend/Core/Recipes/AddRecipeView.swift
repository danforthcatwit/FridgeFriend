//
//  AddRecipeView.swift
//  FridgeFriend
//
//  Created by Denis Le on 3/26/25.
//

import SwiftUI
import FirebaseAuth

struct AddRecipeView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var recipeService = RecipeService()
    @State private var title = ""
    @State private var ingredients = ""
    @State private var instructions = ""
    @State private var timeToCook: Double = 0.0

    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $title)
                TextField("Ingredients (comma-separated)", text: $ingredients)
                TextField("Instructions", text: $instructions)
                Stepper(value: $timeToCook, in: 0...240, step: 1) {
                    Text("Time to Cook: \(timeToCook, specifier: "%.0f") min")
                }
                
                Button("Add Recipe") {
                    guard let userId = Auth.auth().currentUser?.uid else {
                        print("Error: User not logged in")
                        return
                    }

                    let recipe = Recipe(
                        userId: userId,
                        title: title,
                        ingredients: ingredients.components(separatedBy: ", "),
                        instructions: instructions,
                        timeToCook: timeToCook
                    )

                    recipeService.addRecipe(recipe) { error in
                        if let error = error {
                            print("Error adding recipe: \(error.localizedDescription)")
                        } else {
                            presentationMode.wrappedValue.dismiss() // Close sheet
                        }
                    }
                }
            }
            .navigationTitle("Add Recipe")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
