import SwiftUI

struct ManualIngredientInputView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var inventoryViewModel: InventoryViewModel
    @State private var ingredients: [IngredientInput] = [IngredientInput()]
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    struct IngredientInput: Identifiable {
        let id = UUID()
        var name: String = ""
        var quantity: Int = 1
        var expirationDate: Date = Date().addingTimeInterval(86400 * 7)
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach($ingredients) { $ingredient in
                        VStack(spacing: 12) {
                            TextField("Ingredient Name", text: $ingredient.name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            HStack {
                                Text("Quantity:")
                                Spacer()
                                Stepper("\(ingredient.quantity)", value: $ingredient.quantity, in: 1...999)
                            }
                            
                            DatePicker("Expires:", selection: $ingredient.expirationDate, displayedComponents: .date)
                        }
                        .padding(.vertical, 8)
                    }
                    .onDelete { indexSet in
                        ingredients.remove(atOffsets: indexSet)
                    }
                } header: {
                    Text("Ingredients")
                } footer: {
                    Text("Add ingredients to your inventory")
                }
            }
            .navigationTitle("Manual Input")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add to Inventory") {
                        addIngredientsToInventory()
                    }
                    .disabled(ingredients.isEmpty || ingredients.allSatisfy { $0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        ingredients.append(IngredientInput())
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .alert("Success", isPresented: $showingSuccessAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text("Ingredients added to inventory successfully")
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func addIngredientsToInventory() {
        // Filter out empty ingredients
        let validIngredients = ingredients.filter { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        // Add each ingredient to inventory
        for ingredient in validIngredients {
            let item = InventoryItem(
                name: ingredient.name,
                quantity: ingredient.quantity,
                expirationDate: ingredient.expirationDate
            )
            inventoryViewModel.addItem(item)
        }
        
        // Show success alert
        showingSuccessAlert = true
    }
} 