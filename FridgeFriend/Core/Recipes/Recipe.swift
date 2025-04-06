//
//  Recipe.swift
//  FridgeFriend
//
//  Created by Denis Le on 3/26/25.
//

import Foundation
import FirebaseFirestore

struct Recipe: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String?
    var title: String
    var ingredients: [String]
    var ingredientQuantities: [String: Double]?
    var instructions: String?
    var timeToCook: Double
    var imageURL: String?
    var usedIngredientCount: Int?
    var missedIngredientCount: Int?
    var missedIngredients: [String]?
    var spoonacularId: Int?
    
    // Custom initializer for Spoonacular API response
    init(from spoonacularRecipe: SpoonacularRecipe) {
        self.id = nil  // No Firebase ID for Spoonacular recipes
        self.userId = nil
        self.title = spoonacularRecipe.title
        self.ingredients = spoonacularRecipe.usedIngredients.map { $0.name }
        
        // Store ingredient quantities in a dictionary
        var quantities: [String: Double] = [:]
        for ingredient in spoonacularRecipe.usedIngredients {
            var intQuantity = ceil(ingredient.amount)
            quantities[ingredient.name] = intQuantity//lets see if we gfet the right numbers
        }
        self.ingredientQuantities = quantities
        
        self.instructions = nil
        self.timeToCook = 0.0 // Default value since Spoonacular doesn't provide this in search results
        self.imageURL = spoonacularRecipe.image
        self.usedIngredientCount = spoonacularRecipe.usedIngredientCount
        self.missedIngredientCount = spoonacularRecipe.missedIngredientCount
        self.missedIngredients = spoonacularRecipe.missedIngredients.map { $0.name }
        self.spoonacularId = spoonacularRecipe.id  // Store the Spoonacular ID for reference
    }
    
    // Regular initializer for custom recipes
    init(userId: String, title: String, ingredients: [String], instructions: String, timeToCook: Double) {
        self.id = nil  // Let Firestore manage the document ID
        self.userId = userId
        self.title = title
        self.ingredients = ingredients
        self.ingredientQuantities = nil // Custom recipes don't need this as quantities are in the ingredient strings
        self.instructions = instructions
        self.timeToCook = timeToCook
        self.imageURL = nil
        self.usedIngredientCount = nil
        self.missedIngredientCount = nil
        self.missedIngredients = nil
        self.spoonacularId = nil  // Custom recipes don't have a Spoonacular ID
    }
    
    // Helper property to determine if this is a Spoonacular recipe
    var isSpoonacularRecipe: Bool {
        return spoonacularId != nil
    }
    
    // Computed property to provide a consistent identifier for both custom and Spoonacular recipes
    var uniqueIdentifier: String {
        if let firebaseId = id {
            return "custom-\(firebaseId)"
        } else if let spoonId = spoonacularId {
            return "spoon-\(spoonId)"
        } else {
            // Fallback to a UUID if somehow both are nil
            return UUID().uuidString
        }
    }
}

// Spoonacular API response models
struct SpoonacularRecipe: Codable {
    let id: Int
    let title: String
    let image: String?
    let usedIngredientCount: Int
    let missedIngredientCount: Int
    let usedIngredients: [SpoonacularIngredient]
    let missedIngredients: [SpoonacularIngredient]
}

struct SpoonacularIngredient: Codable {
    let id: Int
    let name: String
    let amount: Double
    let unit: String?
    let unitLong: String?
    let unitShort: String?
    let aisle: String?
    let original: String?
    let originalName: String?
    let meta: [String]?
    let image: String?
}
