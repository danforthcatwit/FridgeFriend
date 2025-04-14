# Fridge Friend <br/> <img src="FridgeFriend/Assets.xcassets/image.imageset/image.png">

## Table of Contents:
- 💡[About the Project](#about-the-project)
- 🚀[Features](#features)
- 🛠[Tech Stack](#tech-stack)
- 🔧[Getting Started](#getting-started)
- 📂[Project Structure](#project-structure)
- 🌟[Future Improvements](#future-improvements)
- 📖[Contributors](#contributors)

# 💡About the Project:

Fridge Friend is an iOS application designed to help users manage their food inventory, and get recipes suggestions to make use of the ingredients more efficiently. The project was developed in a team of 4 as a semester long project for a Software Engineering class. It focuses on creating a user-friendly user interface, while implementing features such as OCR scanning, recipe suggestions, and inventory management.

## Key Goals:
- Reduce food waste by tracking expiration dates
- Help users find new recipes based on their available ingredients
- Allow for easier tracking through receipt scanning or manually inputting

## Development Time:
- Current Version: 1.0
- Development Time: 4 months

# 🚀Features:
### 1. User Authentication: 🔑
  #### Workflow (Registration): <br/>
  1. User taps "Sign Up" on login view switching to registration view <br/>
  2. User enters email, full name, password, and confirm password <br/>
  3. User taps "Sign Up" returning to the login view <br/>
  #### Workflow (Login): <br/>
  1. User enters email and password and taps "Sign In" <br/>
  2. User is brought to the homepage view<br/>
  #### Related Files:<br/>
  • Main View model for all user authentication - [FridgeFriend/Core/Authentication/ViewModel/AuthViewModel.swift](./FridgeFriend/Core/Authentication/ViewModel/AuthViewModel.swift) <br/>
  • View folder for authentication - [FridgeFriend/Core/Authentication/View](./FridgeFriend/Core/Authentication/View)

### 2. User Password Reset: 🔒
  #### Workflow: <br/>
  1. User taps "Forgot Password" on login view switching to password reset view <br/>
  2. User enters email address and presses confirm <br/>
  3. The system displays a success message and sends the user an email to the email on file <br/>
  4. User enters a new password, and it's updated through Firebase <br/>
  #### Related Files:<br/>
  • Main View model for all user authentication - [FridgeFriend/Core/Authentication/ViewModel/AuthViewModel.swift](./FridgeFriend/Core/Authentication/ViewModel/AuthViewModel.swift) <br/>
  • View folder for authentication - [FridgeFriend/Core/Authentication/View/ResetPasswordView](./FridgeFriend/Core/Authentication/View/ResetPasswordView.swift)

### 3. Receipt Scanning: 📷
  #### Workflow:
  1. User taps "Scan Receipt" in the main interface
  2. Camera access is checked and requested if needed
  3. User captures a photo of the receipt
  4. OCR processes the image to detect text
  5. Detected test is filtered to identify ingredients
  6. User confirms which ingredients to add
  7. Selected ingredients are added to inventory
  
  #### Related Files:<br/>
  • Main Scanning Interface - [FridgeFriend/Core/Scanning/ScanReceiptView.swift](./FridgeFriend/Core/Scanning/ScanReceiptView.swift) <br/>
  • Camera Implementation - [FridgeFriend/Core/Scanning/Camera](./FridgeFriend/Core/Scanning/Camera/) <br/>
  • Text Recognition - [FridgeFriend/Core/Scanning/TextRecognition.swift](./FridgeFriend/Core/Scanning/TextRecognition.swift) | [FridgeFriend/Core/Scanning/ImageView.swift.swift](./FridgeFriend/Core/Scanning/ImageView.swift) <br/>

### 4. Manually Input Receipt: 🖊️
  #### Workflow: <br/>
  1. User taps "Scan" tab, switching to scan view <br/>
  2. User taps "Manual Input" switching to manual input view <br/>
  3. User adds ingredients manually specify name, quantity, and expiration date <br/>
  4. User confirms and taps "Add to Inventory" returning to main screen view <br/>
  5. The system updates the inventory within the user's account in Firebase <br/>
  #### Related Files:<br/>
  • Manually Input Receipt Alternative - [FridgeFriend/Core/Scanning/ManualIngredientInputView.swift](./FridgeFriend/Core/Scanning/ManualIngredientInputView.swift)

### 5. Food Inventory Management: 👨‍💼
  #### Workflow (Add Item): <br/>
  1. User taps "Add Item" when no items are in inventory or "+" when items are in inventory <br/>
  2. The system displays form for an item <br/>
  3. User enters name, quantity, expiration date <br/>
  4. User taps "Add" creating an inventory item and storing in Firebase <br/>
  #### Workflow (Update Item): <br/>
  1. User taps on an existing item in inventory <br/>
  2. The system displays update form <br/>
  3. User can update/change name, quantity, expiration date <br/>
  4. User taps "Update" updating selected item in Firebase <br/>
  #### Workflow (Remove Item): <br/>
  1. User holds down on an item and taps delete <br/>
  2. User swipes left on an item and taps delete/trash <br/>
  3. The system prompts the user asking if an item was "Wasted" or "Not Wasted" <br/>
  4. User selects "Wasted" the item is archived in Firebase and removed from inventory <br/>
  5. User taps "Not Wasted" item is removed from firebase/inventory <br/>
  #### Related Files: <br/>
  • Main Inventory Interface - [FridgeFriend/Core/Inventory/View/InventoryView.swift](./FridgeFriend/Core/Inventory/View/InventoryView.swift) <br/>
  • Inventory Data Management - [FridgeFriend/Core/Inventory/ViewModel/InventoryViewModel.swift](./FridgeFriend/Core/Inventory/ViewModel/InventoryViewModel.swift) <br/>
  • Item Input/Edit Interface - [FridgeFriend/Components/InventoryItemInputView.swift](./FridgeFriend/Components/InventoryItemInputView.swift) <br/>
  • Item Display Components - [FridgeFriend/Components/InventoryItemView.swift](./FridgeFriend/Components/InventoryItemView.swift) <br/>
  • Data Models - [FridgeFriend/Model/InventoryItem.swift](./FridgeFriend/Model/InventoryItem.swift)

### 6. Custom Recipe Saving: ⚙️
  #### Workflow: <br/>
  1. User taps "+" in the recipes view under "Custom Recipes" tab<br/>
  2. The system displays add recipe view <br/>
  3. User enters recipe title, ingredients/quantities, and instructions <br/>
  4. User taps "Save Recipe" updating with their profile through Firebase <br/>
  #### Related Files: <br/>
  • Viewing Recipes - [FridgeFriend/Core/Recipes/RecipeView.swift](./FridgeFriend/Core/Recipes/RecipeView.swift) <br/>
  • Adding Recipe - [FridgeFriend/Core/Recipes/AddRecipeView.swift](./FridgeFriend/Core/Recipes/AddRecipeView.swift) <br/>
  • Viewing Recipe Details - [FridgeFriend/Core/Recipes/RecipeDetailView.swift](./FridgeFriend/Core/Recipes/RecipeDetailView.swift) <br/>
  • Supporting Files - [FridgeFriend/Core/Inventory/ViewModel/InventoryViewModel.swift](./FridgeFriend/Core/Inventory/ViewModel/InventoryViewModel.swift) <br/>

### 7. Recipe Suggestions: 📝
  #### Workflow: <br/>
  1. User taps "Suggested Recipes" and taps desired recipe from a list of 20 recipes <br/>
  2. The system displays recipe ingredients/quantities and images of recipe <br/>
  #### Related Files: <br/>
  • Main Recipe Interface - [FridgeFriend/Core/Recipes/RecipeView.swift](./FridgeFriend/Core/Recipes/RecipeView.swift) <br/>
  • Recipe Creation - [FridgeFriend/Core/Recipes/AddRecipeView.swift](./FridgeFriend/Core/Recipes/AddRecipeView.swift) <br/>
  • Recipe Model - [FridgeFriend/Core/Recipes/Recipe.swift](./FridgeFriend/Core/Recipes/Recipe.swift) <br/>
  • Recipe Detail View - [FridgeFriend/Core/Recipes/RecipeDetailView.swift](./FridgeFriend/Core/Recipes/RecipeDetailView.swift) <br/>
  • Recipe Service - [FridgeFriend/Core/Recipes/RecipeService.swift](./FridgeFriend/Core/Recipes/RecipeService.swift) <br/>
  • Supporting Files - [FridgeFriend/Core/Inventory/ViewModel/InventoryViewModel.swift](./FridgeFriend/Core/Inventory/ViewModel/InventoryViewModel.swift) <br/>

### 8. Recipe Usage: 🎛️
  #### Workflow: <br/>
  1. User taps "Check Ingredients" either with custom or suggested recipes<br/>
  2. The system prompts the user to add missing ingredients, or all ingredients are in the inventory <br/>
  3. User taps "Use Recipe" <br/>
  4. The system updates the inventory by removing used items and updating with Firebase <br/>
  #### Related Files: <br/>
  • Using/Viewing Recipe | Checking Ingredients | Handling Missing Ingredients - [FridgeFriend/Core/Recipes/RecipeDetailView.swift](./FridgeFriend/Core/Recipes/RecipeDetailView.swift) | [FridgeFriend/Core/Inventory/ViewModel/InventoryViewModel.swift](./FridgeFriend/Core/Inventory/ViewModel/InventoryViewModel.swift) <br/>
  
### 9. Expiration Date Notifications: ⏳
  #### Workflow: <br/>
  1. The system uses local notifications and sends them out every day at 9 am <br/>
  2. system checks if an item is expiring soon, if it is, sends an expiring-soon notification <br/>
  3. The system checks for expired items in inventory; if there are, it sends an expired item notification <br/>
  #### Related Files: <br/>
  • Notification Manager (Permissions Handling and Notification Scheduling/Handling) - [FridgeFriend/Services/NotificationManager.swift](./FridgeFriend/Services/NotificationManager.swift) <br/>
  • Inventory Management (Expiration Tracking) - [FridgeFriend/Core/Inventory/ViewModel/InventoryViewModel.swift](./FridgeFriend/Core/Inventory/ViewModel/InventoryViewModel.swift) <br/>
### 10. Food Waste Tracking: 🗑️
  #### Workflow: <br/>
  1. When an item is expired, the user needs to delete the item from inventory <br/>
  2. The system confirms with the user that the item was wasted <br/>
  3. The user taps "Yes" deleting the item in the inventory <br/>
  4. The system archives the item with Firebase <br/>
  5. The system adds the number of items to the Food Waste Tracker and the kind of item that was deleted <br/>
  #### Related Files: <br/>
  • Item Deletion/Archive - [FridgeFriend/Core/Inventory/View/InventoryView.swift](./FridgeFriend/Core/Inventory/View/InventoryView.swift) | [FridgeFriend/Components/FoodWasteConfirmationView.swift](./FridgeFriend/Components/FoodWasteConfirmationView.swift) <br/>
  • Waste Recording - [FridgeFriend/Core/Inventory/ViewModel/InventoryViewModel.swift](./FridgeFriend/Core/Inventory/ViewModel/InventoryViewModel.swift) <br/>
  • Waste Display - [FridgeFriend/Core/HomePage/HomeView.swift](./FridgeFriend/Core/HomePage/HomeView.swift) <br/>
  • Data Management - [FridgeFriend/Core/HomePage/HomeViewModel.swift](./FridgeFriend/Core/HomePage/HomeViewModel.swift) <br/>
# 🛠Tech Stack:
### Frameworks/libraries/tools used in the project:
  ##### 1. Core iOS Frameworks:
    •SwiftUI (Apple framework)
    •UIKit (for some legacy components)
    •XCTest (Unit and UI Testing)
  ##### 2. Firebase Services:
    •FirebaseAuth (for user authentication)
    •FirebaseCore (core Firebase functionality)
    •FirebaseFirestore (for database operations)
  ##### 3. Food and Nutrition APIs:
    •FatSecret API (for food search and autocomplete)
    •Spoonacular API (for recipe suggestions and ingredient analysis)
  ##### 4. Apple Native APIs:
    •AVFoundation (for camera functionality)
    •Vision (for text-recognition/OCR)
    •UserNotifications (for local notifications)
    •URLSession (for network requests)
  ##### 4. Third-Party Libraries:
    •FatSecretSwift (wrapper for FatSecret API)
    •Firebase iOS SDK (for Firebase services)
  ##### 5. Development Tools:
    •Xcode (IDE)
    •Swift Package Manager (for dependency management)
  ##### 6. Project Structure:
    •MVVM (Model-View-ViewModel) architecture pattern
    •Storyboard (for launch screen)
    •Asset Catalog (managing app resources)

# 🔧Getting Started:

## Prerequisites
- Xcode 15.0 or later
- iOS 11.0 or later
- A Mac computer running macOS Ventura or later

## Installation Steps

1. **Clone the Repository**
  Clone through HTTPS or SSH:

  **HTTPS** (requires GitHub username and [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic)):
  ```bash
  git clone https://github.com/danforthcatwit/FridgeFriend.git
  ```

  **SSH** (requires [SSH setup](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)):
  ```
  git clone git@github.com:danforthcatwit/FridgeFriend.git
  ```

  Then navigate to project:
  ```bash
  cd FridgeFriend
  ```

2. **Open the Project**
   - Open `FridgeFriend.xcodeproj` in Xcode
   - Wait for Xcode to index the project

3. **Configure the Project**
   - The project is already configured with necessary API keys in the project
   - No additional setup is required for Firebase or other services

  **Note**:
  Make sure to update the Team and Bundle identifier if there are any code signing issues:
  1. Go to Project Settings in Xcode, shown at the very top of the project structure
  2. Click "Signing & Capabilities" tab
  3. Change the Team to personal Apple Developer account
  4. Update the Bundle identifier to "com.FridgeFriend" if needed

5. **Build and Run**
   - Select your target device (simulator or physical device)
   - Press ⌘R or click the Run button in Xcode

**Note**:
If recipes are not loading, the Spoonacular API key may have expired or hit a usage limit.

1. Open the file: `Info.plist`
2. Replace SpoonacularAPIKey with valid API key from Spoonacular account

Request a new key here:
https://spoonacular.com/food-api/console#Dashboard

## Development Notes
- The project uses SwiftUI
- All API keys are temporarily stored in the project for grading purposes
- The app is designed to work with iOS 11.0 or later

# 📂Project Structure:
<pre><code>
  FridgeFriend/ 
  ├─App/
  │  └FridgeFriendApp
  ├─Components/
  |  ├─FoodWasteConfirmationView.swift
  |  ├─InputView.swift
  |  ├─InventoryItemInputView.swift  
  |  ├─InventoryItemView.swift
  |  ├─InventoryUpdateView.swift
  |  ├─SettingRowView.swift
  ├─Core/
  |  ├─Authentication/
  |  |  ├─View/
  |  |  |  ├─LoginView.swift
  |  |  |  ├─RegistrationView.swift
  |  |  |  └─ResetPasswordView.swift
  |  |  ├─viewModel/
  |  |     └─AuthViewModel.swift
  |  ├─HomePage/
  |  |  ├─HomeView.swift
  |  |  └─HomeViewModel.swift
  |  ├─Inventory/
  |  |  ├─View/
  |  |  |  └─InventoryView.swift
  |  |  ├─ViewModel/
  |  |    └─InventoryViewModel.swift
  |  ├─Profile/
  |  |  └─ProfileView.swift
  |  ├─Recipes/
  |  |  ├─AddRecipeView.swift
  |  |  ├─Recipe.swift
  |  |  ├─RecipeDetailView.swift
  |  |  ├─RecipeService.swift
  |  |  └─RecipeView.swift
  |  ├─Root/
  |  |  └─ContentView.swift
  |  └─Scanning/
  |     ├─Camera/
  |     |  ├─Camera.swift
  |     |  ├─CameraPreview.swift
  |     |  └─CameraUI.swift
  |     ├─ImageView.swift
  |     ├─ManualIngredientInputView.swift
  |     ├─ScanReceiptView.swift
  |     ├─TextRecognition.swift
  |     └─TranscriptView.swift
  ├─Model/
  |  ├─InventoryItem.swift
  |  └─User.swift
  ├─Preview Content/
  ├─Services/
  |  ├─FatSecretService.swift
  |  ├─NotificationManager.swift
  |  ├─SecretsManager.swift
  |  └─XMLParserDelegate.swift
  ├─Assets
  ├─GoogleService-Info.plist
  └─Info.plist
</code></pre>

# 🌟Future Improvements:

#### Inventory: 
    Auto-Complete Feature:
      •Auto-complete works but is limited. Only works in the simulator, and for it to be used, your IP needs to be whitelisted with API.
      •The only way around that issue is to get a proxy server, but we couldn't find a free service with an IP range limter in time.
      •Would also rework the auto-complete feature to show options on users' keyboard instead of drop down scroll view
    Add images to inventory items
    Accurate Expiration Dates #Twinkies

#### Recipes:
    •When users see a recipe in the suggestions, they can save it for liked recipes. Currently, the suggested recipes are based on current 
    items in the inventory.
    •Suggested recipes when checking for ingredients and items are missing. Add them to the items-to-buy section in the inventory

#### Notifications:
    •Push notifications couldn't be made the way we originally planned, at least not for free. You need to be enrolled in the Apple 
    Developer program to properly set it up and enable this feature by pushing through a server with more accurate notifications.
    •Notifications are currently being sent as local notifications that are scheduled to push at 9 am every day when you have an 
    item expiring soon and or an expired item in inventory.

# 📖Contributors:
James Kourkoutas | Colin Danforth | Denis Le | Timmy Tran
