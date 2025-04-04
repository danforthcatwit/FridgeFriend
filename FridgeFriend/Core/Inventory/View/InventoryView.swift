import SwiftUI

struct InventoryView: View {
    @StateObject var viewModel = InventoryViewModel()
    @State private var itemToEdit: InventoryItem? = nil
    @State private var isPressed: Bool = false
    @State private var itemToDelete: InventoryItem? = nil
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    // Conditionally show the add/edit form at the top
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
                                VStack {
                                    InventoryItemView(
                                        itemName: item.name,
                                        quantity: item.quantity,
                                        expirationDate: item.expirationDate
                                    )
                                               
                                    
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                                    .contextMenu {
                                        Button(action: {
                                            startEditing(item)
                                        }) {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        
                                        Button(role: .destructive, action: {
                                            deleteItem(item)
                                        }) {
                                            Label("Delete", systemImage: "trash.fill")
                                        }
                                    }
                                    .background(Color.clear)
                                    .onTapGesture {
                                        startEditing(item)
                                    }
                                    
                                    // Conditionally show update view for the current item
                                    if itemToEdit?.id == item.id {
                                        InventoryUpdateView(viewModel: viewModel, itemToEdit: item)
                                            .transition(.move(edge: .bottom).combined(with: .opacity))
                                    }
                                }
                            }
                            .onDelete { indexSet in
                                if let index = indexSet.first {
                                    deleteItem(viewModel.inventoryItems[index])
                                }
                            }
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
                            if itemToEdit != nil {
                                itemToEdit = nil
                                viewModel.showingEditForm = false
                            } else {
                                viewModel.showingAddForm.toggle()
                            }
                        }
                    }) {
                        if itemToEdit != nil {
                            Label("Cancel Edit", systemImage: "xmark")
                        } else {
                            Label(
                                viewModel.showingAddForm ? "Hide Form" : "Add Item",
                                systemImage: viewModel.showingAddForm ? "minus" : "plus"
                            )
                        }
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
            .overlay {
                if showingDeleteConfirmation, let item = itemToDelete {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay {
                            FoodWasteConfirmationView(
                                itemName: item.name,
                                onConfirm: {
                                    if let index = viewModel.inventoryItems.firstIndex(where: { $0.id == item.id }) {
                                        viewModel.deleteItem(at: IndexSet(integer: index), isWasted: true)
                                    }
                                    showingDeleteConfirmation = false
                                    itemToDelete = nil
                                },
                                onCancel: {
                                    if let index = viewModel.inventoryItems.firstIndex(where: { $0.id == item.id }) {
                                        viewModel.deleteItem(at: IndexSet(integer: index), isWasted: false)
                                    }
                                    showingDeleteConfirmation = false
                                    itemToDelete = nil
                                }
                            )
                            .padding()
                        }
                }
            }
        }
    }

    
    //Helper function to start editing mode
    private func startEditing(_ item: InventoryItem) {
        withAnimation {
            // If tapping the same item, set itemToEdit to nil
            itemToEdit = itemToEdit?.id == item.id ? nil : item
            // Exit add mode if active
            viewModel.showingAddForm = false
            viewModel.showingEditForm = true
        }
    }
    
    //Helper function for delete functionality
    private func deleteItem(_ item: InventoryItem) {
        itemToDelete = item
        showingDeleteConfirmation = true
    }
}

#Preview {
    InventoryView()
}
