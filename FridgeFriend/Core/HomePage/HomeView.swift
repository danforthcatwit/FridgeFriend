//
//  HomeView.swift
//  FridgeFriend
//
//  Created by Denis Le on 3/7/25.
//

import SwiftUI
import Charts

struct HomeView: View {
    let foodWasteData: [(category: String, weight: Double)] = [
        ("Fruits", 1.2),
        ("Vegetables", 0.8),
        ("Meat", 2.5),
        ("Dairy", 1.1)
    ]
    
    var totalWaste: Double {
        foodWasteData.reduce(0) { $0 + $1.weight }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Logo at Top
                HStack {
                    Spacer()
                    Image("image")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                    Spacer()
                }

                // Expiring Items
                VStack(alignment: .leading) {
                    Text("Items Expiring Soon")
                        .font(.title2)
                        .bold()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("• Apple 🍏")
                        Text("• Ground Beef 🥩")
                        Text("• Chicken 🍗")
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.red, lineWidth: 2)
                    )
                    
                }
                

                // Suggest Recipe Button
                HStack {
                    Spacer()
                    Button(action: {}) {
                        Text("Suggest Recipes")
                            .padding()
                            .frame(width: 180)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                    Spacer()
                }

                // Food Waste Summary
                VStack(alignment: .leading, spacing: 10) {
                    Text("Food Waste Summary")
                        .font(.title2)
                        .bold()
                    
                    // Pie Chart
                    Chart(foodWasteData, id: \.category) { data in
                        SectorMark(
                            angle: .value("Weight", data.weight),
                            innerRadius: .ratio(0.5),
                            angularInset: 2.0
                        )
                        .foregroundStyle(by: .value("Category", data.category))
                    }
                    .frame(height: 200)
                    .padding()
                    
                    // Total Waste
                    Text("Total Waste: \(String(format: "%.2f", totalWaste)) kg")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray, lineWidth: 1)
                )

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    HomeView()
}
