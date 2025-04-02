//
//  ResetPasswordView.swift
//  FridgeFriend
//
//  Created by Colin James on 4/1/25.
//
import SwiftUI

struct ResetPasswordView: View {
    @State private var email = ""
    @State private var resetSent = false
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Reset Password")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                InputView(text: $email,
                          title: "Email Address",
                          placeholder: "Please enter your email address")
                .autocapitalization(.none)
                .padding(.horizontal)
                
                Button {
                    Task {
                        // This assumes you'll add a resetPassword method to your AuthViewModel
                        if let error = try? await viewModel.resetPassword(withEmail: email) {
                            print("Error: \(error)")
                        } else {
                            resetSent = true
                        }
                    }
                } label: {
                    HStack {
                        Text("SEND RESET LINK")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(.systemBlue))
                .disabled(!isValidEmail)
                .opacity(isValidEmail ? 1 : 0.5)
                .cornerRadius(10)
                .padding(.top, 12)
                
                Spacer()
            }
            .overlay(
                Group {
                    if resetSent {
                        VStack {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.green)
                                .padding()
                            
                            Text("Reset link sent!")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("Please check your email for instructions to reset your password.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Button {
                                dismiss()
                            } label: {
                                Text("Return to Login")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 44)
                                    .background(Color(.systemBlue))
                                    .cornerRadius(10)
                            }
                            .padding(.top)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding()
                    }
                }
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    var isValidEmail: Bool {
        return !email.isEmpty && email.contains("@")
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
