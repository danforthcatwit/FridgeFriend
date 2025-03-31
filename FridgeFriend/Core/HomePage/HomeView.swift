//
//  HomeView.swift
//  FridgeFriend
//
//  Created by Denis Le on 3/7/25.
//

import SwiftUI
import Charts

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
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
                    
                    if viewModel.isLoading {
                        ProgressView("Loading items...")
                            .padding()
                    } else if viewModel.expiringItems.isEmpty {
                        Text("No items expiring soon")
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Color.green.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.black, lineWidth: 2)
                            )
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(viewModel.expiringItems) { item in
                                HStack {
                                    Text("• \(item.name)")
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    Text("Expires \(viewModel.expirationTimeString(for: item))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
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
        .onAppear {
            viewModel.fetchExpiringItems()
        }
    }
}

#Preview {
    HomeView()
}
