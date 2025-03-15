//
//  RegistrationView.swift
//  FridgeFriend
//
//  Created by Colin James on 3/9/25.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var name = ""
    @State private var confirmPassword = ""
    @State private var password = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        VStack {
            VStack(spacing: 24) {
                Image("image")
                    .resizable()
                    .scaledToFit( )
                    .frame(width:100, height:120)
                    .padding()
                
                InputView(text: $email,
                          title: "Email Address",
                          placeholder: "Enter your email address",
                          isSecureField: false)
                
                .autocapitalization(.none)
                
                InputView(text: $name,
                          title: "Full Name",
                          placeholder: "Enter your name",
                          isSecureField: false)
                
                InputView(text: $password,
                          title: "Password",
                          placeholder: "Enter your password",
                          isSecureField: true)
                
                ZStack(alignment: .trailing) {
                    InputView(text: $confirmPassword,
                              title: "Confirm Password",
                              placeholder: "Confirm your password",
                              isSecureField: true)
                    if !password.isEmpty && !confirmPassword.isEmpty {
        
                        if password == confirmPassword {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGreen))
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemRed))
                        }
                        
                    }
                }
            
            
            
                
                Button {
                    Task {
                        try await viewModel.createUser(withEmail: email,
                                                       password: password,
                                                       name: name)
                   
                    }
                } label: {
                    HStack {
                        Text("SIGN UP")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                        
                    }
                    
                    .foregroundColor(.white)
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1 : 0.5)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 48)
                }
                .background(Color(.systemBlue))
                .cornerRadius(10)
                .padding(.top, 24)
            }
            
            .padding(.horizontal)
            .padding(.top, 12)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                HStack(spacing: 3) {
                    Text("Already have an account?")
                    Text("Sign In")
                        .fontWeight(.semibold)
                }
                .font(.system(size:14))

            }
        }
        
    }
}
extension RegistrationView: AuthenticationFormValidation {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains( "@" )
        && !password.isEmpty
        && password.count >= 5
        && confirmPassword == password
        && !name.isEmpty
        
    }
}
#Preview {
    RegistrationView()
}
