//
//  AuthViewModel.swift
//  FridgeFriend
//
//  Created by Colin James on 3/9/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol AuthenticationFormValidation {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        self.userSession = Auth.auth().currentUser
        //Checks for userData, with fetched user data login screen will not prompt on launch
        Task {
            await fetchUserData()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUserData()
        }
        catch {
            print("DEBUG: Failed to login with error \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, name: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, name: name, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
        }
        catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription)")
        }
    }
    

    
    func signOut() {
        do {
            try Auth.auth().signOut() // signs out user on backend
            self.userSession = nil // wipes out user session -> sends back to login screen
            self.currentUser = nil // wipes current user data model
        } catch {
            print("DEBUG: Failed to sign out with error\(error.localizedDescription)")
        }
    }
    
    //TODO 
    func deleteUser() {
        
    }
    //fetches cached user data in Firestore
    func fetchUserData() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
        self.currentUser = try? snapshot.data(as: User.self)
        
    }
}
