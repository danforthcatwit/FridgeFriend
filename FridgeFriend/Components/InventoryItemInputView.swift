//
//  InventoryItemInputView.swift
//  FridgeFriend
//
//  Created by Colin James on 3/19/25.
//
import SwiftUI
import Combine

struct InventoryItemInputView: View {
    @ObservedObject var viewModel: InventoryViewModel
    var itemToEdit: InventoryItem? //track item being edited
    @State private var itemName = String()
    @State private var quantity = Int()
    @State private var expirationDate = Date() // One week from now
    
    //For autocomplete functionality
    @State private var suggestions: [String] = []
    @State private var isShowingSuggestions = false
    @State private var debounceTimer: Timer?
    
    //FatSecret Service
    private let fatSecretService = FatSecretService(
        apiKey:"5c0ad605b4bd4639ac767946a121332a",
        apiSecret: "68a192dc5d6b472585692e37d109fc63",
        baseURL: "https://platform.fatsecret.com/rest",
        oauthURL: "https://oauth.fatsecret.com/connect/token"
    )
    
    //Adds cancellable for Combine
    @State private var searchCancellable: AnyCancellable?
    
    //initializer handles both new items and editing existing items
    init(viewModel: InventoryViewModel, itemToEdit: InventoryItem? = nil){
        self.viewModel = viewModel
        self.itemToEdit = itemToEdit
        
        //initializes state of existing/modified or default values
        _itemName = State(initialValue: itemToEdit?.name ?? "")
        _quantity = State(initialValue: itemToEdit?.quantity ?? 1)
        _expirationDate = State(initialValue: itemToEdit?.expirationDate ?? Date().addingTimeInterval(86400 * 7))
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                //dynamic title for adding or deleting
                Text(itemToEdit == nil ? "Add New Item" : "Edit Item")
                    .font(.headline)
                Spacer()
                Button(action: {
                    //close button functionality for edit
                    if itemToEdit != nil {
                        viewModel.showingEditForm = false
                    } else {
                        viewModel.showingAddForm = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            // Input fields
            VStack(spacing: 12) {
                VStack(alignment: .leading) {
                    TextField("Item Name", text: $itemName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: itemName) { newValue in
                            // Trigger autocomplete when text changes
                            handleTextChange(newValue)
                        }
                    
                    // Suggestions dropdown
                    if isShowingSuggestions && !suggestions.isEmpty {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(suggestions, id: \.self) { suggestion in
                                    Button(action: {//when selecting item it autofils
                                        // Update input field and hide suggestions
                                        withAnimation {
                                            itemName = suggestion
                                            isShowingSuggestions = false
                                        }
                                    }) {
                                        Text(suggestion)
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 8)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color(.systemBackground))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .shadow(radius: 2)
                        .zIndex(1) // Ensure suggestions appear above other content
                    }
                }
                
                HStack {
                    Text("Quantity:")
                    Spacer()
                    Stepper("\(quantity)", value: $quantity, in: 1...999)
                }
                
                DatePicker("Expires:", selection: $expirationDate, displayedComponents: .date)
            }
            
            // Button
            Button(action: {
                //handle both creation and edit of existing item
                if let existingItem = itemToEdit {
                    let updatedItem = InventoryItem(
                        id: existingItem.id,
                        name: itemName,
                        quantity: quantity,
                        expirationDate: expirationDate
                    )
                    viewModel.updateItem(updatedItem)
                    // Reset fields and close form
                    viewModel.showingEditForm = false
                } else {
                    let newItem = InventoryItem(
                        name: itemName,
                        quantity: quantity,
                        expirationDate: expirationDate
                    )
                    viewModel.addItem(newItem)
                    // Reset fields and close form
                    itemName = ""
                    quantity = 1
                    expirationDate = Date().addingTimeInterval(86400 * 7)
                    viewModel.showingAddForm = false
                }
            }) {
                //dynamic button 1 add, 2 edit
                Text(itemToEdit == nil ? "Save Item" : "Update Item")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.top, 8)
        // Dismiss suggestions when tapping outside
        .onTapGesture {
            isShowingSuggestions = false
        }
    }
    
    // Handle text changes with debouncing
    private func handleTextChange(_ newValue: String) {
        // Cancel existing timer and search
        debounceTimer?.invalidate()
        searchCancellable?.cancel()
        
        // Only search if we have at least 2 characters
        if newValue.count >= 2 {
            // Debounce for 0.5 seconds to avoid too many API calls
            debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                fetchSuggestions(query: newValue)
            }
        } else {
            // Clear suggestions if text is too short
            suggestions = []
            isShowingSuggestions = false
        }
    }
    
    // Fetch suggestions from API
    private func fetchSuggestions(query: String) {
        print("Fetching suggestions for query: \(query)") // Debug log
        searchCancellable = fatSecretService.searchFoods(query: query)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error fetching suggestions: \(error)")
                    }
                },
                receiveValue: { suggestions in
                    print("Received suggestions: \(suggestions)") // Debug log
                    self.suggestions = suggestions
                    self.isShowingSuggestions = !suggestions.isEmpty
                    print("isShowingSuggestions: \(self.isShowingSuggestions)") // Debug log
                }
            )
    }
}
