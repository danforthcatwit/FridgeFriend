//
//  InventoryItemInputView.swift
//  FridgeFriend
//
//  Created by Colin James on 3/19/25.
//

import SwiftUI

struct InventoryItemInputView: View {
    @ObservedObject var viewModel: InventoryViewModel
    @State private var itemName = ""
    @State private var quantity = 1
    @State private var expirationDate = Date().addingTimeInterval(86400 * 7) // One week from now
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Add New Item")
                    .font(.headline)
                Spacer()
                Button(action: {
                    viewModel.showingAddForm = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            // Input fields
            VStack(spacing: 12) {
                TextField("Item Name", text: $itemName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    Text("Quantity:")
                    Spacer()
                    Stepper("\(quantity)", value: $quantity, in: 1...999)
                }
                
                DatePicker("Expires:", selection: $expirationDate, displayedComponents: .date)
            }
            
            // Button
            Button(action: {
                let newItem = InventoryItem(
                    name: itemName,
                    quantity: quantity,
                    expirationDate: expirationDate
                )
                viewModel.addItem(newItem)
                
                // Reset fields
                itemName = ""
                quantity = 1
                expirationDate = Date().addingTimeInterval(86400 * 7)
            }) {
                Text("Save Item")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top, 8)
    }
}


