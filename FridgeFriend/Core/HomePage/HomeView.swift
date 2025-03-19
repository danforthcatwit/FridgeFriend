//
//  HomeView.swift
//  FridgeFriend
//
//  Created by Denis Le on 3/7/25.
//

import SwiftUI
import Charts

struct HomeView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 20.0) {
                
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
                VStack {
                    Text("Items Expiring Soon")
                        .font(.title2)
                        .bold()
                    
                    VStack(alignment: .leading) {
                        Text("• Apple")
                        Text("• Ground Beef")
                        Text("• Chicken")
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.black, lineWidth: 2)

                    )
                    
                    
                }
                .padding(.horizontal, 0)

                // Suggest Recipe Button
                HStack {
                    Spacer()
                    Button(action: {}) {
                        Text("Suggest Recipes")
                            .padding(10)
                            .foregroundStyle(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    Spacer()
                }

                // Food Waste Summary
                Text("Food Waste Summary")
                    .font(.title2)
                    .bold()
                
                Spacer()
            }
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
