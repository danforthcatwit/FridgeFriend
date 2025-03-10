//
//  ProfileView.swift
//  FridgeFriend
//
//  Created by Colin James on 2/27/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
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
                        print("Delete Account")
                    } label: {
                        SettingRowView(imageName: "xmark.circle.fill",
                                       title: "Delete Account",
                                       tintColor: Color(.systemRed))
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
