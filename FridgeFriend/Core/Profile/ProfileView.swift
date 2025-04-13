//
//  ProfileView.swift
//  FridgeFriend
//
//  Created by Colin James on 2/27/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showingDeleteAlert = false
    @State private var deleteError: String?
    
    var body: some View {
        if let user = viewModel.currentUser {
            List {
                Section {
                    HStack {
                        Text(user.initials)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(.systemGray3))
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            Text(user.email)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
                Section("Account") {
                    Button {
                        viewModel.signOut()
                    } label: {
                        SettingRowView(imageName: "arrow.left.circle.fill",
                                       title: "Sign Out",
                                       tintColor: Color(.systemRed))
                    }
                    
                    Button {
                        showingDeleteAlert = true
                    } label: {
                        SettingRowView(imageName: "xmark.circle.fill",
                                       title: "Delete Account",
                                       tintColor: Color(.systemRed))
                    }
                }
            }
            .alert("Delete Account", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteUser()
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.")
            }
        }
    }
}

#Preview {
    ProfileView()
}
