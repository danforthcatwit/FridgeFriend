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
    
    /// User check
    private var userID: String?
    
    init() {
        // Checks user id for personal inventory
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
    
    /// Sets up a Firestore listener to track inventory changes
    func setupFirestoreListener() {
        // Checks for user ID before proceeding
        guard let userID = userID else {
            errorMessage = "User ID not available"
            return
        }
        
        isLoading = true
        // Path ref change to specific user and a new collection of inventory items
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
                
                // First get all items
                let allItems = documents.compactMap { document -> InventoryItem? in
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
                
                // Filter out archived items in memory
                self.inventoryItems = allItems.filter { !$0.isArchived }
                
                // Schedule grouped notifications
                let expiringItems = allItems.filter { $0.expiringSoon && !$0.isExpired && !$0.isArchived }
                let expiredItems = allItems.filter { $0.isExpired && !$0.isArchived }
                
                // Schedule notifications for expiring items
                if !expiringItems.isEmpty {
                    NotificationManager.shared.scheduleExpiringSoonNotification(for: expiringItems)
                }
                
                // Schedule notifications for expired items
                if !expiredItems.isEmpty {
                    NotificationManager.shared.scheduleExpiredNotification(for: expiredItems)
                }
            }
    }
    
    /// Adds a new item to the inventory or updates quantity if item exists
    /// - Parameter item: The item to add or update
    func addItem(_ item: InventoryItem) {
        // Checks for user ID before proceeding
        guard let userID = userID else {
            errorMessage = "User ID not available"
            return
        }
        
        // Check if item with same name AND expiration date exists
        let inventoryRef = db.collection("users").document(userID).collection("inventoryItems")
        
        // First, get all items with the same name
        inventoryRef.whereField("name", isEqualTo: item.name)
            .whereField("isArchived", isEqualTo: false)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "Failed to check for existing items: \(error.localizedDescription)"
                    return
                }
                
                // Find matching item by comparing dates
                if let documents = querySnapshot?.documents {
                    let matchingDocument = documents.first { document in
                        do {
                            let existingItem = try document.data(as: InventoryItem.self)
                            // Compare dates by converting to the same timezone and stripping time components
                            let calendar = Calendar.current
                            let existingDate = calendar.startOfDay(for: existingItem.expirationDate)
                            let newDate = calendar.startOfDay(for: item.expirationDate)
                            return existingDate == newDate
                        } catch {
                            return false
                        }
                    }
                    
                    if let matchingDocument = matchingDocument {
                        do {
                            var existingItem = try matchingDocument.data(as: InventoryItem.self)
                            existingItem.quantity += item.quantity
                            
                            // Update the item in Firestore
                            try inventoryRef.document(matchingDocument.documentID).setData(from: existingItem)
                            self.showingAddForm = false
                        } catch {
                            self.errorMessage = "Failed to update existing item: \(error.localizedDescription)"
                        }
                    } else {
                        // No matching item exists, add as new item
                        do {
                            _ = try inventoryRef.addDocument(from: item)
                            self.showingAddForm = false
                        } catch {
                            self.errorMessage = "Failed to add item: \(error.localizedDescription)"
                        }
                    }
                }
            }
    }
    
    /// Updates an existing item in the inventory
    /// - Parameter item: The item to update
    func updateItem(_ item: InventoryItem) {
        // Checks for user ID before proceeding
        guard let userID = userID else {
            errorMessage = "User ID not available"
            return
        }
        // Checks for valid item ID
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
    
    /// Deletes an item from the inventory or archives it if marked as wasted
    /// - Parameters:
    ///   - indexSet: The indices of items to delete
    ///   - isWasted: Whether the item was wasted
    func deleteItem(at indexSet: IndexSet, isWasted: Bool = false) {
        // Checks for user ID before proceeding
        guard let userID = userID else {
            errorMessage = "User ID not available"
            return
        }
        
        for index in indexSet {
            guard let id = inventoryItems[index].id else { continue }
            let itemRef = db.collection("users").document(userID).collection("inventoryItems").document(id)
            
            if isWasted {
                // Archive the item instead of deleting it
                var item = inventoryItems[index]
                item.isArchived = true
                item.isWasted = true
                item.archivedDate = Date()
                
                do {
                    try itemRef.setData(from: item, merge: true)
                } catch {
                    errorMessage = "Failed to archive item: \(error.localizedDescription)"
                }
            } else {
                // Delete the item
                itemRef.delete { [weak self] error in
                    if let error = error {
                        self?.errorMessage = "Failed to delete item: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    /// Uses ingredients from a recipe and updates inventory quantities
    /// - Parameter recipe: The recipe to use
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

    /// Fetches suggested recipes based on available ingredients
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
                            // Create recipe without storing in Firebase
                            let newRecipe = Recipe(from: recipe)
                            uniqueRecipes.append(newRecipe)
                            seenIds.insert(recipe.id)
                        }
                    }
                    
                    // Then, add recipes that require additional ingredients
                    for recipe in spoonacularRecipes {
                        if recipe.missedIngredientCount > 0 && !seenIds.contains(recipe.id) {
                            // Create recipe without storing in Firebase
                            let newRecipe = Recipe(from: recipe)
                            uniqueRecipes.append(newRecipe)
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
