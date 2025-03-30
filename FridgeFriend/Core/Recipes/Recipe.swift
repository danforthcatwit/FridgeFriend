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
    var instructions: String?
    var timeToCook: Double
    var imageURL: String?
    var usedIngredientCount: Int?
    var missedIngredientCount: Int?
    var missedIngredients: [String]?
    var spoonacularId: Int?
    
    // Custom initializer for Spoonacular API response
    init(from spoonacularRecipe: SpoonacularRecipe) {
        self.id = nil
        self.userId = nil
        self.title = spoonacularRecipe.title
        self.ingredients = spoonacularRecipe.usedIngredients.map { $0.name }
        self.instructions = nil
        self.timeToCook = 0.0 // Default value since Spoonacular doesn't provide this in search results
        self.imageURL = spoonacularRecipe.image
        self.usedIngredientCount = spoonacularRecipe.usedIngredientCount
        self.missedIngredientCount = spoonacularRecipe.missedIngredientCount
        self.missedIngredients = spoonacularRecipe.missedIngredients.map { $0.name }
        self.spoonacularId = spoonacularRecipe.id
    }
    
    // Regular initializer for custom recipes
    init(userId: String, title: String, ingredients: [String], instructions: String, timeToCook: Double) {
        self.id = nil
        self.userId = userId
        self.title = title
        self.ingredients = ingredients
        self.instructions = instructions
        self.timeToCook = timeToCook
        self.imageURL = nil
        self.usedIngredientCount = nil
        self.missedIngredientCount = nil
        self.missedIngredients = nil
        self.spoonacularId = nil
    }
}

// Spoonacular API response models
struct SpoonacularRecipe: Codable {
    let id: Int
    let title: String
    let image: String
    let usedIngredientCount: Int
    let missedIngredientCount: Int
    let usedIngredients: [SpoonacularIngredient]
    let missedIngredients: [SpoonacularIngredient]
}

struct SpoonacularIngredient: Codable {
    let id: Int
    let name: String
    let amount: Double
    let unit: String
    let unitLong: String
    let unitShort: String
    let aisle: String
    let original: String
    let originalName: String
    let meta: [String]
    let image: String?
}
