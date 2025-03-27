//
//  InventoryAutocompleteViewModel.swift
//  FridgeFriend
//
//  Created by Colin James on 3/26/25.
//

//View model for autocomplete text in InventoryView through FatSecret API

import Foundation

class InventoryAutocompleteViewModel: ObservableObject {
    @Published var autocompleteItems: [String] = []
    
    func fetchAutocompleteItems(searchTerm: String) {
        
    }
    
    func ifUpdated() {
        
    }
    
}
