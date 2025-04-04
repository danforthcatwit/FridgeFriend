/*
See the LICENSE.txt file for this sample's licensing information.

Abstract:
Presents the initial view and button to capture an image.
*/

import AVFoundation
import SwiftUI

struct ScanReceiptView: View {
    @State private var showCamera: Bool = false
    @State private var hasPhoto: Bool = false
    @State private var imageData: Data? = nil
    @State private var showAccessError: Bool = false
    @State private var showIngredientConfirmation: Bool = false
    @State private var extractedIngredients: [String] = []
    @StateObject private var inventoryViewModel = InventoryViewModel()

    var body: some View {
        if showAccessError {
            VStack {
                Image(systemName: "lock.trianglebadge.exclamationmark.fill")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.gray)

                Text("This app needs access to the camera for it to function properly. You can update this at:")
                Text("Settings > Privacy and Security > Camera")
            }
        } else {
            VStack {
                if hasPhoto {
                    ImageView(showCamera: $showCamera, imageData: $imageData, onTextRecognized: { ingredients in
                        extractedIngredients = ingredients
                        showIngredientConfirmation = true
                    })
                } else {
                    Spacer()

                    Image(systemName: "text.aligncenter")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.gray)
                        .opacity(0.50)
                        .frame(width: 150, height: 150)

                    Spacer()

                    Button("Take a Photo") {
                        showCamera = true
                    }
                    .padding()
                    .font(.title2)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())

                    Spacer()
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraUI(showCamera: $showCamera, showAccessError: $showAccessError, hasPhoto: $hasPhoto, imageData: $imageData)
            }
            .sheet(isPresented: $showIngredientConfirmation) {
                IngredientConfirmationView(
                    ingredients: extractedIngredients,
                    inventoryViewModel: inventoryViewModel
                )
            }
        }
    }
}

struct IngredientConfirmationView: View {
    let ingredients: [String]
    @ObservedObject var inventoryViewModel: InventoryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIngredients: Set<String> = []
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Detected Ingredients")) {
                    ForEach(ingredients, id: \.self) { ingredient in
                        HStack {
                            Text(ingredient)
                                .font(.body)
                            Spacer()
                            if selectedIngredients.contains(ingredient) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedIngredients.contains(ingredient) {
                                selectedIngredients.remove(ingredient)
                            } else {
                                selectedIngredients.insert(ingredient)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Confirm Ingredients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add to Inventory") {
                        addSelectedIngredientsToInventory()
                    }
                    .disabled(selectedIngredients.isEmpty)
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
    
    private func addSelectedIngredientsToInventory() {
        let selectedIngredientsList = Array(selectedIngredients)
        
        // Create inventory items with default expiration date (7 days from now)
        let expirationDate = Date().addingTimeInterval(86400 * 7)
        let items = selectedIngredientsList.map { name in
            InventoryItem(
                name: name,
                quantity: 1,
                expirationDate: expirationDate
            )
        }
        
        // Add each item to inventory
        for item in items {
            inventoryViewModel.addItem(item)
        }
        
        // Show success alert
        showingSuccessAlert = true
    }
}
