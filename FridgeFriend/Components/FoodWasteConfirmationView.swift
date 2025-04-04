 //
//  FoodWasteConfirmationView.swift
//  FridgeFriend
//
//  Created by Colin James on 4/2/25.
//

import SwiftUI

struct FoodWasteConfirmationView: View {
    let itemName: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Food Waste Confirmation")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Are you sure you want to remove \(itemName)?")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Was this food wasted?")
                .font(.headline)
                .padding(.top, 5)
            
            Text("This action cannot be undone.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                Button(action: onCancel) {
                    Text("No")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
                
                Button(action: onConfirm) {
                    Text("Yes")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}

#Preview {
    FoodWasteConfirmationView(
        itemName: "Milk",
        onConfirm: {},
        onCancel: {}
    )
    .padding()
    .background(Color.gray.opacity(0.2))
}
