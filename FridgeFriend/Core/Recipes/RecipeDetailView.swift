//
//  RecipeDetailView.swift
//  FridgeFriend
//
//  Created by Denis Le on 3/27/25.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if let imageURL = recipe.imageURL, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .cornerRadius(10)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                Text(recipe.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Time to Cook: \(recipe.timeToCook, specifier: "%.1f") min")
                    .font(.headline)

                Text("Ingredients")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(recipe.ingredients.joined(separator: ", "))
                    .font(.body)

                Text("Instructions")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(recipe.instructions)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Recipe Details")
    }
}
