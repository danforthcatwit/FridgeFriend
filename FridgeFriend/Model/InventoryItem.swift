//
//  InventoryItem.swift
//  FridgeFriend
//
//  Created by Colin James on 3/19/25.
//

import Foundation
import FirebaseFirestore


struct InventoryItem: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var quantity: Int
    var expirationDate: Date
    
    // Add an initializer that makes the id parameter optional with a default value of nil
    init(id: String? = nil, name: String, quantity: Int, expirationDate: Date) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.expirationDate = expirationDate
    }
    // Equatable
    static func == (lhs: InventoryItem, rhs: InventoryItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.quantity == rhs.quantity &&
               lhs.expirationDate == rhs.expirationDate
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case quantity
        case expirationDate
    }
}
