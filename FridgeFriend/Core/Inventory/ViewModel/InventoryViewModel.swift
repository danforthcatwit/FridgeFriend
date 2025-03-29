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
                        return try document.data(as: InventoryItem.self)
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
}
