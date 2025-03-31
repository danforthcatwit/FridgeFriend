//
//  InventoryItemView.swift
//  FridgeFriend
//
//  Created by Colin James on 3/19/25.
//

import SwiftUI

struct InventoryItemView: View {
    let itemName: String
    let quantity: Int
    let expirationDate: Date
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 12) {
            // Item Name (takes up more space)
            Text(itemName)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Quantity with label
            HStack(spacing: 4) {
                Image(systemName: "number")
                    .foregroundColor(.secondary)
                Text("\(quantity)")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .frame(width: 60)
            
            // Expiration Date
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                Text(dateFormatter.string(from: expirationDate))
                    .font(.subheadline)
                    .foregroundColor(isExpiringSoon ? .red : .primary)
                    .lineLimit(1)
            }
            .frame(width: 120)
        }
        .padding()
        .background(isExpired ? .red : Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    private var isExpiringSoon: Bool {
        let calendar = Calendar.current
        let weekFromNow = calendar.date(byAdding: .day, value: 7, to: Date())!
        return expirationDate <= weekFromNow
    }
    
    private var isExpired: Bool {
        return expirationDate < Date()
        
    }
}

// Preview provider for SwiftUI canvas
struct InventoryItemView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            InventoryItemView(
                itemName: "Apples",
                quantity: 5,
                expirationDate: Date().addingTimeInterval(86400 * 3) // 3 days from now
            )
            
            InventoryItemView(
                itemName: "Milk",
                quantity: 1,
                expirationDate: Date().addingTimeInterval(86400 * 10) // 10 days from now
            )
            
            InventoryItemView(
                itemName: "Very Long Product Name That Might Get Cut Off",
                quantity: 12,
                expirationDate: Date().addingTimeInterval(86400 * 2) // 2 days from now
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}


