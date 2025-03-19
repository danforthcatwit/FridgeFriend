//
//  InventoryView.swift
//  FridgeFriend
//
//  Created by Colin James on 2/27/25.
//

import SwiftUI

struct InventoryView: View {
    @StateObject var viewModel = InventoryViewModel()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    // Conditionally show the add form at the top
                    if viewModel.showingAddForm {
                        InventoryItemInputView(viewModel: viewModel)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    if viewModel.isLoading {
                        ProgressView("Loading inventory...")
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.inventoryItems.isEmpty {
                        VStack {
                            Text("No items in inventory")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.top, 40)
                            
                            if !viewModel.showingAddForm {
                                Button("Add your first item") {
                                    withAnimation {
                                        viewModel.showingAddForm = true
                                    }
                                }
                                .padding(.top)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(viewModel.inventoryItems) { item in
                                InventoryItemView(
                                    itemName: item.name,
                                    quantity: item.quantity,
                                    expirationDate: item.expirationDate
                                )
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                .contextMenu {
                                    Button(action: {
                                        // Edit functionality would go here
                                    }) {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    
                                    Button(role: .destructive, action: {
                                        if let index = viewModel.inventoryItems.firstIndex(where: { $0.id == item.id }) {
                                            viewModel.deleteItem(at: IndexSet(integer: index))
                                        }
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            .onDelete(perform: viewModel.deleteItem)
                        }
                        .listStyle(.plain)
                        .refreshable {
                            viewModel.setupFirestoreListener()
                        }
                    }
                }
            }
            .navigationTitle("Inventory")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            viewModel.showingAddForm.toggle()
                        }
                    }) {
                        Label(
                            viewModel.showingAddForm ? "Hide Form" : "Add Item",
                            systemImage: viewModel.showingAddForm ? "minus" : "plus"
                        )
                    }
                }
            }
            .alert("Error", isPresented: Binding<Bool>(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
}


#Preview {
    InventoryView()
}
