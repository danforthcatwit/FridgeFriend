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
    @Binding var selectedTab: Int
    @Binding var isFromSuggestRecipes: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    headerSection
                    
                    // Expiring Items Section
                    expiringItemsSection
                    
                    // Suggest Recipes Button
                    suggestRecipesButton
                    
                    // Food Waste Summary Section
                    foodWasteSection
                }
                .padding()
            }
            .navigationTitle("FridgeFriend")
            .navigationBarTitleDisplayMode(.large)

        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image("image")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .shadow(radius: 5)
            
            Text("Welcome to FridgeFriend")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Your smart kitchen companion")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
    
    // MARK: - Expiring Items Section
    private var expiringItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Items Expiring Soon")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink(destination: InventoryView()) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                }
            }
            
            if viewModel.isLoading {
                ProgressView("Loading items...")
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if viewModel.expiringItems.isEmpty {
                emptyExpiringItemsView
            } else {
                expiringItemsList
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
    
    // MARK: - Suggest Recipes Button
    private var suggestRecipesButton: some View {
        Button(action: {
            isFromSuggestRecipes = true
            selectedTab = 3 // Switch to Recipes tab
        }) {
            HStack(spacing: 12) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                
                Text("Suggest Recipes")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [.blue, .blue.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    private var emptyExpiringItemsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(.green)
            
            Text("No items expiring soon")
                .font(.headline)
            
            Text("Your fridge is well managed!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var expiringItemsList: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.expiringItems) { item in
                HStack(spacing: 16) {
                    // Item icon
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundStyle(.red)
                        .frame(width: 44, height: 44)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                    
                    // Item details
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.headline)
                        
                        Text("Expires \(viewModel.expirationTimeString(for: item))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // Navigation arrow
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                if item.id != viewModel.expiringItems.last?.id {
                    Divider()
                }
            }
        }
    }
    
    private func quickActionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Food Waste Section
    private var foodWasteSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Food Waste History")
                .font(.title3)
                .fontWeight(.bold)
            
            if viewModel.wastedItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.green)
                    
                    Text("No wasted items")
                        .font(.headline)
                    
                    Text("Great job reducing food waste!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                VStack(spacing: 16) {
                    // Total Items Wasted
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Items Wasted")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Text("\(viewModel.totalWastedQuantity)")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(.red)
                            
                            Text("items")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // List of Wasted Items
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Wasted Items")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        ForEach(viewModel.wastedItems) { item in
                            HStack(spacing: 16) {
                                // Item icon
                                Image(systemName: "trash.fill")
                                    .font(.title2)
                                    .foregroundStyle(.red)
                                    .frame(width: 44, height: 44)
                                    .background(Color.red.opacity(0.1))
                                    .clipShape(Circle())
                                
                                // Item details
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name)
                                        .font(.headline)
                                    
                                    if let archivedDate = item.archivedDate {
                                        Text("Wasted on \(archivedDate.formatted(date: .abbreviated, time: .omitted))")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                // Quantity
                                Text("\(item.quantity) \(item.quantity == 1 ? "item" : "items")")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            if item.id != viewModel.wastedItems.last?.id {
                                Divider()
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
    }
}

#Preview {
    HomeView(selectedTab: .constant(0), isFromSuggestRecipes: .constant(false))
}
