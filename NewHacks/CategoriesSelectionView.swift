//
//  CategoriesSelectionView.swift
//  NewHacks
//

import SwiftUI

struct CategoriesSelectionView: View {
    @ObservedObject var userDataManager: UserDataManager
    @State private var selectedCategories: Set<String> = []
    @State private var showSuccessMessage = false
    @Environment(\.presentationMode) var presentationMode
    
    let availableCategories = [
        "Funny", "Dance", "Comedy", "Gaming", "Music", "Art",
        "Cooking", "Sports", "Travel", "Animals", "Education",
        "Beauty", "Fashion", "DIY", "Science", "Technology"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Choose Your Interests")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Select categories to personalize your Shorts feed")
                            .foregroundColor(.secondary)
                    }
                    
                    // Categories Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(availableCategories, id: \.self) { category in
                            CategoryChip(
                                title: category,
                                isSelected: selectedCategories.contains(category),
                                onTap: {
                                    toggleCategory(category)
                                }
                            )
                        }
                    }
                    
                    // Continue Button
                    Button(action: saveCategories) {
                        HStack {
                            Text("Complete Registration")
                                .fontWeight(.semibold)
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedCategories.isEmpty ? Color.gray : Color.green)
                        .cornerRadius(12)
                    }
                    .disabled(selectedCategories.isEmpty)
                    .padding(.top, 20)
                    
                    Text("Select at least 3 categories for better recommendations")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .padding()
            }
            .navigationBarTitle("Interests", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                // Cancel registration and go back to auth
                userDataManager.logout()
                presentationMode.wrappedValue.dismiss()
            })
            .overlay(
                Group {
                    if showSuccessMessage {
                        SuccessOverlay(message: "Registration Complete!\nPlease sign in to continue.")
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    showSuccessMessage = false
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                    }
                }
            )
        }
    }
    
    private func toggleCategory(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
    
    private func saveCategories() {
        let categories = Array(selectedCategories)
        userDataManager.updateUserCategories(categories)
        
        // Show success message and then redirect to login
        withAnimation {
            showSuccessMessage = true
        }
        
        // Logout after saving categories to force login
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            userDataManager.logout()
        }
    }
}

struct SuccessOverlay: View {
    let message: String
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text(message)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .padding(40)
        }
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .fontWeight(.medium)
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                }
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                isSelected ? Color.blue : Color(.systemGray6)
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
