//
//  FridgeFriendApp.swift
//  FridgeFriend
//
//  Created by Colin James on 2/22/25.
//

import SwiftUI
import Firebase
import UserNotifications

@main
struct FridgeFriendApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
        // Request notification permissions
        NotificationManager.shared.requestAuthorization()
    }
   
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}

