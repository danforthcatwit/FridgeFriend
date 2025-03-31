//
//  HomeViewModel.swift
//  FridgeFriend
//
//  Created by Colin James on 3/27/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class HomeViewModel: ObservableObject {
    @Published var expiringItems: [InventoryItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var userID: String?
    
    init() {
        if let currentUser = Auth.auth().currentUser {
            self.userID = currentUser.uid
            fetchExpiringItems()
        } else {
            errorMessage = "No user logged in"
        }
    }
    
    deinit {
        listenerRegistration?.remove()
    }
    
    func fetchExpiringItems() {
        guard let userID = userID else {
            errorMessage = "User ID not available"
            return
        }
        
        isLoading = true
        let inventoryRef = db.collection("users").document(userID).collection("inventoryItems")
        
        // Get items ordered by expiration date
        listenerRegistration = inventoryRef
            .order(by: "expirationDate")
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Failed to fetch items: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    return
                }
                
                // Process all items
                let items = documents.compactMap { document -> InventoryItem? in
                    do {
                        return try document.data(as: InventoryItem.self)
                    } catch {
                        print("Error decoding item: \(error)")
                        return nil
                    }
                }
                
                // Filter items that are expiring soon but not expired
                let currentDate = Date()
                let expiringItems = items.filter { item in
                    // Calculate days until expiration
                    let daysUntilExpiration = Calendar.current.dateComponents([.day], from: currentDate, to: item.expirationDate).day ?? 0
                    
                    // Keep items that expire in the next 7 days but haven't expired yet
                    return daysUntilExpiration >= 0 && daysUntilExpiration <= 7
                }
                
                // Sort by expiration date (soonest first) and limit to first 4
                self.expiringItems = Array(expiringItems.sorted {
                    $0.expirationDate < $1.expirationDate
                }.prefix(4))
            }
    }
    
    // Calculate days until expiration for display
    func daysUntilExpiration(for item: InventoryItem) -> Int {
        let currentDate = Date()
        return Calendar.current.dateComponents([.day], from: currentDate, to: item.expirationDate).day ?? 0
    }
    
    // Format the expiration time remaining string
    func expirationTimeString(for item: InventoryItem) -> String {
        let days = daysUntilExpiration(for: item)
        
        if days == 0 {
            return "today!"
        } else if days == 1 {
            return "tomorrow"
        } else {
            return "in \(days) days"
        }
    }
}
