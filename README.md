# Fridge Friend

## Table of Contents:
- [About the Project](#about-the-project)
- [Functional Requirements](#funtional-requirements)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Future Improvements](#future-improvements)
- [Contributors](#contributors)

# About the Project:
-What the Project Does

-The goal or motivation behind project
-total development time to current

# Functional Requirements:
1. ### User Authentication:


2. ### User Password Reset:


3. ### Receipt Scanning:


4. ### Manually Input Reciept:


5. ### Food Inventory Management:


6. ### Custom Recipe Saving:


7. ### Recipe Suggestions:


8. ### Recipe Usage:


9. ### Expiration Date Notifications:


10. ### Food Waste Tracking:

# Tech Stack:
- frameworks/librarys/tools used
- languages used
- APIS or Databases Used

# Getting Started:
-Instructions to set up project locally

# Usage:
How to run or ue application
-ex apple dev id 
-firebase access

# Project Structure:
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

# Future Improvements:
