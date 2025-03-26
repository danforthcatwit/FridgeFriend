//
//  RecipeService.swift
//  FridgeFriend
//
//  Created by Denis Le on 3/26/25.
//

import FirebaseFirestore
import FirebaseAuth

class RecipeService: ObservableObject {
    private let db = Firestore.firestore()
    private let collection = "recipes"
    
    @Published var recipes: [Recipe] = []
    
    private var userId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    func addRecipe(_ recipe: Recipe, completion: @escaping (Error?) -> Void) {
        guard let userId = userId else { return }
        
        var newRecipe = recipe
        newRecipe.userId = userId  // Ensure recipe is linked to the user
        
        do {
            let _ = try db.collection(collection).addDocument(from: newRecipe, completion: completion)
        } catch {
            completion(error)
        }
    }
    
    func fetchUserRecipes() {
        guard let userId = userId else { return }
        
        db.collection(collection)
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching recipes: \(error.localizedDescription)")
                    return
                }
                
                self.recipes = snapshot?.documents.compactMap { document in
                    try? document.data(as: Recipe.self)
                } ?? []
            }
    }
}
