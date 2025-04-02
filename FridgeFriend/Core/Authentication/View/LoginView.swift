//
//  LoginView.swift
//  FridgeFriend
//
//  Created by Colin James on 3/9/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showResetPassword = false
    @State private var errorMessage: String?//hold error message
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                //image TODO
                Image("image")
                    .resizable()
                    .scaledToFit( )
                    .frame(width:100, height:120)
                    .padding()
                //form fields
                VStack(spacing: 24) {
                    InputView(text: $email,
                              title: "Email Address",
                              placeholder: "Please enter your email address")
                    .autocapitalization(.none)
                    
                    InputView(text: $password,
                              title: "Password",
                              placeholder: "Enter your password",
                              isSecureField: true)
                    HStack {
                        Spacer()
                        Button {
                            showResetPassword = true
                        } label: {
                            Text("Forgot Password?")
                                .font(.system(size: 13))
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                .sheet(isPresented: $showResetPassword) {
                    ResetPasswordView().environmentObject(viewModel)
                }
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.system(size:14))
                        .fontWeight(.semibold)
                        .padding(.top, 8)
                        .transition(.opacity)
                }
                
                // sign in button
                Button {
                    Task {
                        do {
                            try await viewModel.signIn(withEmail: email,
                                                       password: password)
                            errorMessage = nil
                        } catch {
                            errorMessage = "Invalid email or password. Please try again."
                        }
                        
                    }
                } label: {
                    HStack {
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                        
                    }
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(.systemBlue))
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1 : 0.5)
                .cornerRadius(10)
                .padding(.top, 24)
                
                Spacer()
                
                //sign up button
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                        Text("Sign Up")
                            .fontWeight(.semibold)
                    }
                    .font(.system(size:14))
                }
                
            }
        }
    }
}

extension LoginView: AuthenticationFormValidation {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains( "@" )
        && !password.isEmpty
        && password.count >= 5
        
    }
}
#Preview {
    LoginView()
}
