import SwiftUI

struct InventoryUpdateView: View {
    @ObservedObject var viewModel: InventoryViewModel
    let itemToEdit: InventoryItem? //track item being edited
    @State private var itemName: String
    @State private var quantity: Int
    @State private var expirationDate: Date
    @State private var isVisible = true // Add state for animation
    
    //initializer handles editing existing items
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
                //title for editing
                Text("Edit Item")
                    .font(.headline)
                Spacer()
                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isVisible = false
                        // Small delay to allow animation to complete
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            viewModel.showingEditForm = false
                            viewModel.itemToEdit = nil
                        }
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            // Input fields
            VStack(spacing: 12) {
                TextField("Item Name", text: $itemName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
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
                    withAnimation(.easeOut(duration: 0.3)) {
                        isVisible = false
                        // Small delay to allow animation to complete
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            viewModel.updateItem(updatedItem)
                            viewModel.itemToEdit = nil
                        }
                    }
                }
            }) {
                Text("Update Item")
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
        .opacity(isVisible ? 1 : 0)
        .scaleEffect(isVisible ? 1 : 0.95)
        .animation(.easeIn(duration: 0.3), value: isVisible)
    }
}
