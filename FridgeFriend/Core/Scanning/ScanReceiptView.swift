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
    @State private var showManualInput: Bool = false
    
    var body: some View {
        NavigationView {
            if showAccessError {
                VStack(spacing: 24) {
                    Image(systemName: "lock.trianglebadge.exclamationmark.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(.red)
                        .padding(.top, 40)
                    
                    VStack(spacing: 16) {
                        Text("Camera Access Required")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("This app needs access to the camera for it to function properly.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                        
                        Text("You can update this at:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("Settings > Privacy and Security > Camera")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
                .navigationTitle("Scan Receipt")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                VStack(spacing: 0) {
                    if hasPhoto {
                        ImageView(showCamera: $showCamera, imageData: $imageData, hasPhoto: $hasPhoto, onTextRecognized: { ingredients in
                            extractedIngredients = ingredients
                            showIngredientConfirmation = true
                        })
                    } else {
                        Spacer()
                        
                        VStack(spacing: 32) {
                            Image(systemName: "doc.text.viewfinder")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .foregroundStyle(.blue)
                                .opacity(0.8)
                            
                            VStack(spacing: 16) {
                                Text("Add to Inventory")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("Scan your receipt or manually add items to your inventory")
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 32)
                            }
                            
                            VStack(spacing: 16) {
                                Button(action: { showCamera = true }) {
                                    HStack {
                                        Image(systemName: "camera.fill")
                                        Text("Scan Receipt")
                                    }
                                    .frame(minWidth: 200)
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.large)
                                
                                Button(action: { showManualInput = true }) {
                                    HStack {
                                        Image(systemName: "square.and.pencil")
                                        Text("Manual Input")
                                    }
                                    .frame(minWidth: 200)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.large)
                            }
                            .padding(.top, 16)
                        }
                        .padding(.bottom, 40)
                        
                        Spacer()
                    }
                }
                .navigationTitle("Add to Inventory")
                .navigationBarTitleDisplayMode(.inline)
                .fullScreenCover(isPresented: $showCamera) {
                    CameraUI(showCamera: $showCamera, showAccessError: $showAccessError, hasPhoto: $hasPhoto, imageData: $imageData)
                }
                .onChange(of: showCamera) { newValue in
                    // If camera is dismissed and we have a photo, keep showing the image view
                    // Otherwise, reset the state
                    if !newValue && !hasPhoto {
                        imageData = nil
                    }
                }
                .sheet(isPresented: $showManualInput) {
                    ManualIngredientInputView(inventoryViewModel: inventoryViewModel)
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
                Section {
                    ForEach(ingredients, id: \.self) { ingredient in
                        Button(action: {
                            if selectedIngredients.contains(ingredient) {
                                selectedIngredients.remove(ingredient)
                            } else {
                                selectedIngredients.insert(ingredient)
                            }
                        }) {
                            HStack {
                                Text(ingredient)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedIngredients.contains(ingredient) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.blue)
                                        .imageScale(.large)
                                }
                            }
                        }
                        .contentShape(Rectangle())
                    }
                } header: {
                    Text("Detected Ingredients")
                        .textCase(nil)
                        .font(.headline)
                        .foregroundStyle(.primary)
                } footer: {
                    Text("Tap ingredients to select which ones to add to your inventory")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
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
