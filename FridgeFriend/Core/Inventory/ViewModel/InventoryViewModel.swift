//
//  InventoryViewModel.swift
//  FridgeFriend
//
//  Created by Colin James on 3/19/25.
//

import Foundation
import FirebaseFirestore

class InventoryViewModel: ObservableObject {
    @Published var inventoryItems: [InventoryItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAddForm = false
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        setupFirestoreListener()
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    func setupFirestoreListener() {
        isLoading = true
        
        listenerRegistration = db.collection("inventoryItems")
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
        do {
            _ = try db.collection("inventoryItems").addDocument(from: item)
            showingAddForm = false // Hide the form after successfully adding
        } catch {
            errorMessage = "Failed to add item: \(error.localizedDescription)"
        }
    }
    
    func updateItem(_ item: InventoryItem) {
        guard let id = item.id else {
            errorMessage = "Cannot update item without an ID"
            return
        }
        
        do {
            try db.collection("inventoryItems").document(id).setData(from: item)
        } catch {
            errorMessage = "Failed to update item: \(error.localizedDescription)"
        }
    }
    
    func deleteItem(at indexSet: IndexSet) {
        for index in indexSet {
            guard let id = inventoryItems[index].id else { continue }
            
            db.collection("inventoryItems").document(id).delete { [weak self] error in
                if let error = error {
                    self?.errorMessage = "Failed to delete item: \(error.localizedDescription)"
                }
            }
        }
    }
}
