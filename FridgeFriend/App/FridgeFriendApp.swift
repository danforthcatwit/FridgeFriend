//
//  FridgeFriendApp.swift
//  FridgeFriend
//
//  Created by Colin James on 2/22/25.
//

import SwiftUI
import Firebase


@main
struct FridgeFriendApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
   
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}

