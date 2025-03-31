//
//  InventoryViewModel.swift
//  FridgeFriend
//
//  Created by Colin James on 3/19/25.
//
//add delete item/edit quantity/etc
//update product ID system with firebase and API
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

class InventoryViewModel: ObservableObject {
    @Published var inventoryItems: [InventoryItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAddForm = false
    @Published var showingEditForm = false
    @Published var outOfStockIngredients: [String] = []
    @Published var suggestedRecipes: [Recipe] = []
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    //user check
    private var userID: String?
    
    init() {
        //checks user id for personal inventory
        if let currentUser = Auth.auth().currentUser {
            self.userID = currentUser.uid
            setupFirestoreListener()
        } else {
            errorMessage = "No user logged in"
        }
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    func setupFirestoreListener() {
        //checks for user ID before proceeding
        guard let userID = userID else {
            errorMessage = "User ID not available"
            return
        }
        
        isLoading = true
        //path ref change to specific user and a new collection of inventory items
        let inventoryRef = db.collection("users").document(userID).collection("inventoryItems")
        
        listenerRegistration = inventoryRef
            .order(by: "expirationDate")
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Failed to fetch inventory: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    self.errorMessage = "No documents found"
                    return
                }
                
                self.inventoryItems = documents.compactMap { document -> InventoryItem? in
                    do {
                        var item = try document.data(as: InventoryItem.self)
                        
                        // Check expiration status
                        if Date() > item.expirationDate && !item.isExpired {
                            item.isExpired = true
                            
                            // Update in Firestore if newly expired
                            if let id = item.id {
                                do {
                                    try self.db.collection("users").document(userID).collection("inventoryItems").document(id).setData(from: item)
                                } catch {
                                    print("Error updating expired item: \(error)")
                                }
                            }
                        }
                        else {
                            item.isExpired = false
                        }
                        
                        // Check expiringSoon status
                        let currentDate = Date()
                        let daysUntilExpiration = Calendar.current.dateComponents([.day], from: currentDate, to: item.expirationDate).day ?? 0

                        // Item is expiring soon if it expires within the next 2 days but hasn't expired yet
                        let isExpiringSoon = daysUntilExpiration >= 0 && daysUntilExpiration <= 2

                        // Only update if the status has changed
                        if isExpiringSoon != item.expiringSoon {
                            item.expiringSoon = isExpiringSoon
                            
                            // Update in Firestore if status changed
                            if let id = item.id {
                                do {
                                    try self.db.collection("users").document(userID).collection("inventoryItems").document(id).setData(from: item)
                                } catch {
                                    print("Error updating expiring soon status: \(error)")
                                }
                            }
                        }
                        else {
                            item.expiringSoon = false
                        }
                        
                        return item
                    } catch {
                        print("Error decoding item: \(error)")
                        return nil
                    }
                }
            }
    }
    func addItem(_ item: InventoryItem) {
        //checks for user ID before proceeding
        guard let userID = userID else {
            errorMessage = "User ID not available"
            return
        }
        do {
            _ = try db.collection("users").document(userID).collection("inventoryItems").addDocument(from: item)
            showingAddForm = false // Hide the form after successfully adding
        } catch {
            errorMessage = "Failed to add item: \(error.localizedDescription)"
        }
    }
    
    func updateItem(_ item: InventoryItem) {
        //checks for user ID before proceeding
        guard let userID = userID else {
            errorMessage = "User ID not available"
            return
        }
        //checks for valid item ID
        guard let id = item.id else {
            errorMessage = "Cannot update item without an ID"
            return
        }
        
        do {
            _ = try db.collection("users").document(userID).collection("inventoryItems").document(id).setData(from: item)
            showingEditForm = false
        } catch {
            errorMessage = "Failed to update item: \(error.localizedDescription)"
        }
    }
    
    func deleteItem(at indexSet: IndexSet) {
        //checks for user ID before proceeding
        guard let userID = userID else {
            errorMessage = "User ID not available"
            return
        }
        
        for index in indexSet {
            guard let id = inventoryItems[index].id else { continue }
            
            db.collection("users").document(userID).collection("inventoryItems").document(id).delete { [weak self] error in
                if let error = error {
                    self?.errorMessage = "Failed to delete item: \(error.localizedDescription)"
                }
            }
        }
    }
        
    
    
    func useRecipe(_ recipe: Recipe) {
        guard let userID = userID else {
            errorMessage = "User ID not available"
            return
        }

        outOfStockIngredients.removeAll() // Reset list before checking

        let inventoryRef = db.collection("users").document(userID).collection("inventoryItems")

        for ingredientEntry in recipe.ingredients {
            let components = ingredientEntry.split(separator: "-").map { $0.trimmingCharacters(in: .whitespaces) }
            
            guard components.count == 2, let ingredientName = components.first, let requiredQuantity = Double(components.last ?? "0") else {
                print("Invalid ingredient format: \(ingredientEntry)")
                continue
            }

            inventoryRef.whereField("name", isEqualTo: ingredientName).getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching inventory item: \(error)")
                    return
                }

                guard let document = snapshot?.documents.first else {
                    DispatchQueue.main.async {
                        self.outOfStockIngredients.append(ingredientName) // Add missing ingredient
                    }
                    print("Ingredient \(ingredientName) not found in inventory")
                    return
                }

                do {
                    var item = try document.data(as: InventoryItem.self)

                    if item.quantity >= Int(requiredQuantity) {
                        item.quantity -= Int(requiredQuantity)
                        try inventoryRef.document(document.documentID).setData(from: item)
                    } else {
                        DispatchQueue.main.async {
                            self.outOfStockIngredients.append(ingredientName) // Track if out of stock
                        }
                        print("Not enough \(ingredientName). Required: \(requiredQuantity), Available: \(item.quantity)")
                    }
                } catch {
                    print("Error updating ingredient: \(error)")
                }
            }
        }
    }

    func fetchSuggestedRecipes() {
        guard let apiKey = SecretsManager.getAPIKey(for: "SpoonacularAPIKey") else {
            print("DEBUG: Missing Spoonacular API Key")
            errorMessage = "Missing Spoonacular API Key"
            return
        }

        guard !inventoryItems.isEmpty else {
            print("DEBUG: No inventory items available")
            suggestedRecipes = []
            return
        }

        // Get ingredients with quantity > 0
        let availableIngredients = inventoryItems
            .filter { $0.quantity > 0 }
            .map { $0.name }
            .joined(separator: ",")

        print("DEBUG: Available ingredients: \(availableIngredients)")

        guard !availableIngredients.isEmpty else {
            print("DEBUG: No available ingredients with quantity > 0")
            suggestedRecipes = []
            return
        }

        // First, get recipes that can be made with only our ingredients
        let urlString = "https://api.spoonacular.com/recipes/findByIngredients?ingredients=\(availableIngredients)&number=20&ranking=1&ignorePantry=true&apiKey=\(apiKey)"
        
        print("DEBUG: Making request to Spoonacular API")
        
        guard let url = URL(string: urlString) else {
            print("DEBUG: Invalid URL for Spoonacular API")
            errorMessage = "Invalid URL for Spoonacular API"
            return
        }

        isLoading = true
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("DEBUG: API request failed with error: \(error.localizedDescription)")
                    self?.errorMessage = "Failed to fetch recipes: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    print("DEBUG: No data received from Spoonacular API")
                    self?.errorMessage = "No data received from Spoonacular API"
                    return
                }

                do {
                    let spoonacularRecipes = try JSONDecoder().decode([SpoonacularRecipe].self, from: data)
                    print("DEBUG: Successfully decoded \(spoonacularRecipes.count) recipes")
                    
                    // Convert to our Recipe model and remove duplicates
                    var uniqueRecipes: [Recipe] = []
                    var seenIds = Set<Int>()
                    
                    // First, add recipes that can be made with only our ingredients (missedIngredientCount = 0)
                    for recipe in spoonacularRecipes {
                        if recipe.missedIngredientCount == 0 && !seenIds.contains(recipe.id) {
                            uniqueRecipes.append(Recipe(from: recipe))
                            seenIds.insert(recipe.id)
                        }
                    }
                    
                    // Then, add recipes that require additional ingredients
                    for recipe in spoonacularRecipes {
                        if recipe.missedIngredientCount > 0 && !seenIds.contains(recipe.id) {
                            uniqueRecipes.append(Recipe(from: recipe))
                            seenIds.insert(recipe.id)
                        }
                    }
                    
                    // Sort recipes by usedIngredientCount (descending) to show recipes that use more of our ingredients first
                    uniqueRecipes.sort { ($0.usedIngredientCount ?? 0) > ($1.usedIngredientCount ?? 0) }
                    
                    self?.suggestedRecipes = uniqueRecipes
                    print("DEBUG: Final unique recipes count: \(uniqueRecipes.count)")
                } catch {
                    print("DEBUG: Failed to decode recipes: \(error.localizedDescription)")
                    self?.errorMessage = "Failed to decode recipes: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
