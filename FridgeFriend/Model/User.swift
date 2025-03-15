//
//  User.swift
//  FridgeFriend
//
//  Created by Colin James on 3/9/25.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: name) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        } else {
            return ""
        }
    }
}

//Mock User

extension User {
    static var MOCK_USER = User(id: NSUUID().uuidString, name: "John Doe", email: "johndoe@example.com")
}
