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
    @Published var wastedItems: [InventoryItem] = []
    @Published var totalWastedQuantity: Int = 0  // Property to track total quantity
    
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
                    self.expiringItems = []
                    self.wastedItems = []
                    self.totalWastedQuantity = 0
                    return
                }
                
                // Process all items
                let items = documents.compactMap { document -> InventoryItem? in
                    do {
                        var item = try document.data(as: InventoryItem.self)
                        
                        // If item is archived but not expired, set its expiration date to an expired date
                        if item.isArchived && !item.isExpired {
                            item.expirationDate = Date().addingTimeInterval(-86400) // Set to yesterday
                            item.isExpired = true
                            
                            // Update in Firestore
                            if let id = item.id {
                                do {
                                    try self.db.collection("users").document(userID).collection("inventoryItems").document(id).setData(from: item)
                                } catch {
                                    print("Error updating archived item: \(error)")
                                }
                            }
                        }
                        
                        return item
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
                    return daysUntilExpiration >= 0 && daysUntilExpiration <= 7 && !item.isExpired && !item.isArchived
                }
                
                // Sort by expiration date (soonest first) and limit to first 4
                self.expiringItems = Array(expiringItems.sorted {
                    $0.expirationDate < $1.expirationDate
                }.prefix(4))
                
                // Update wasted items
                let wastedItems = items.filter { $0.isArchived && $0.isWasted }
                
                // Calculate total wasted quantity before grouping
                self.totalWastedQuantity = wastedItems.reduce(0) { $0 + $1.quantity }
                
                // Group items by name and sum their quantities
                var groupedItems: [String: InventoryItem] = [:]
                
                for item in wastedItems {
                    if let existingItem = groupedItems[item.name] {
                        var updatedItem = existingItem
                        updatedItem.quantity += item.quantity
                        // Keep the most recent archived date
                        if let newDate = item.archivedDate,
                           let existingDate = existingItem.archivedDate,
                           newDate > existingDate {
                            updatedItem.archivedDate = newDate
                        }
                        groupedItems[item.name] = updatedItem
                    } else {
                        groupedItems[item.name] = item
                    }
                }
                
                // Convert back to array and sort by archived date
                self.wastedItems = Array(groupedItems.values).sorted { item1, item2 in
                    guard let date1 = item1.archivedDate, let date2 = item2.archivedDate else {
                        return false
                    }
                    return date1 > date2
                }
                
                // Debug print to check quantities
                print("Total wasted items count: \(self.wastedItems.count)")
                print("Total quantity of wasted items: \(self.totalWastedQuantity)")
                for item in self.wastedItems {
                    print("Item: \(item.name), Quantity: \(item.quantity), Date: \(item.archivedDate?.description ?? "no date")")
                }
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
