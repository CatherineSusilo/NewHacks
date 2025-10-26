//
//  AuthView.swift
//  NewHacks
//
//  Created by Catherine Susilo on 25/10/25.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var isLoginMode = true
    @State private var name = ""
    @State private var age = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fixedTimeThreshold = 600.0 // Default 10 minutes
    @State private var showCategories = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text(isLoginMode ? "Welcome Back" : "Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(isLoginMode ? "Sign in to continue" : "Join us to get started")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // Form
                    VStack(spacing: 16) {
                        if !isLoginMode {
                            CustomTextField(icon: "person", placeholder: "Full Name", text: $name)
                            CustomTextField(icon: "calendar", placeholder: "Age", text: $age)
                                .keyboardType(.numberPad)
                        }
                        
                        CustomTextField(icon: "envelope", placeholder: "Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        CustomTextField(icon: "lock", placeholder: "Password", text: $password, isSecure: true)
                            .textContentType(.newPassword)
                            .autocapitalization(.none)
                            
                        
                        if !isLoginMode {
                            CustomTextField(icon: "lock.fill", placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
                                .textContentType(.newPassword)
                                .autocapitalization(.none)
                            
                            // Fixed Time Threshold Picker
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Break Time Threshold")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Set when you want breaks to start appearing")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Picker("Time Threshold", selection: $fixedTimeThreshold) {
                                    Text("30 min").tag(1800.0)
                                    Text("60 min").tag(3600.0)
                                    Text("90 min").tag(5400.0)
                                    Text("120 min").tag(7200.0)
                                    Text("150 min").tag(9000.0)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                
                                Text("Selected: \(formatTimeThreshold(fixedTimeThreshold))")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Error Message
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    // Action Button
                    Button(action: handleAuth) {
                        HStack {
                            Text(isLoginMode ? "Sign In" : "Create Account")
                                .fontWeight(.semibold)
                            Image(systemName: isLoginMode ? "arrow.right" : "person.badge.plus")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .disabled(!isFormValid)
                    .opacity(isFormValid ? 1.0 : 0.6)
                    
                    // Switch Mode
                    Button(action: {
                        isLoginMode.toggle()
                        errorMessage = ""
                        clearForm()
                    }) {
                        HStack {
                            Text(isLoginMode ? "Don't have an account?" : "Already have an account?")
                            Text(isLoginMode ? "Sign Up" : "Sign In")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .background(
                NavigationLink(
                    destination: CategoriesSelectionView(userDataManager: userDataManager),
                    isActive: $showCategories
                ) { EmptyView() }
            )
        }
    }
    
    private var isFormValid: Bool {
        if isLoginMode {
            return !email.isEmpty && !password.isEmpty
        } else {
            return !name.isEmpty &&
                   !age.isEmpty &&
                   !email.isEmpty &&
                   !password.isEmpty &&
                   !confirmPassword.isEmpty &&
                   password == confirmPassword &&
                   Int(age) != nil
        }
    }
    
    private func handleAuth() {
        if isLoginMode {
            if userDataManager.login(email: email, password: password) {
                // Successfully logged in - go to main app
                showCategories = false
            } else {
                errorMessage = "Invalid email or password"
            }
        } else {
            guard let ageInt = Int(age) else { return }
            
            let newUser = User(
                name: name,
                age: ageInt,
                email: email,
                password: password,
                fixedTimeThreshold: fixedTimeThreshold,
                preferredCategories: [] // Will be set in categories screen
            )
            
            if userDataManager.registerUser(newUser) {
                userDataManager.currentUser = newUser
                showCategories = true
            } else {
                errorMessage = "Email already exists"
            }
        }
    }
    
    private func clearForm() {
        name = ""
        age = ""
        email = ""
        password = ""
        confirmPassword = ""
    }
    
    private func formatTimeThreshold(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        if minutes < 90 {
            return "\(minutes) minutes"
        } else {
            let hours = minutes / 60
            return "\(hours) hour\(hours > 1 ? "s" : "")"
        }
    }
}

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
