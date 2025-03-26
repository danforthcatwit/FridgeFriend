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
    var userId: String
    var title: String
    var ingredients: [String]
    var instructions: String
    var timeToCook: Double
    var imageURL: String? // Keep this field for storing image links
}
