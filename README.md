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

-The goal or motivation behind the project
-total development time to current

# Functional Requirements:
### 1. User Authentication:


### 2. User Password Reset:


### 3. Receipt Scanning:


### 4. Manually Input Receipt:


### 5. Food Inventory Management:


### 6. Custom Recipe Saving:


### 7. Recipe Suggestions:


### 8. Recipe Usage:


### 9. Expiration Date Notifications:


### 10. Food Waste Tracking:


# Tech Stack:
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

# Getting Started:
-Instructions to set up project locally

# Usage:
How to run application
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

# Contributors:

