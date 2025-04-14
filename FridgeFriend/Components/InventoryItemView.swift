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
            // Item Name
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





