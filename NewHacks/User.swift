//
//  User.swift
//  NewHacks
//

import Foundation

struct User: Codable {
    let id: UUID
    let name: String
    let age: Int
    let email: String
    let password: String
    let fixedTimeThreshold: TimeInterval
    let preferredCategories: [String]
    let createdAt: Date
    
    init(name: String, age: Int, email: String, password: String, fixedTimeThreshold: TimeInterval, preferredCategories: [String]) {
        self.id = UUID()
        self.name = name
        self.age = age
        self.email = email
        self.password = password
        self.fixedTimeThreshold = fixedTimeThreshold
        self.preferredCategories = preferredCategories
        self.createdAt = Date()
    }
}

class UserDataManager: ObservableObject {
    @Published var currentUser: User?
    @Published var users: [User] = []
    
    private let usersKey = "storedUsers"
    private let currentUserKey = "currentUser"
    
    init() {
        loadUsers()
        loadCurrentUser()
    }
    
    func registerUser(_ user: User) -> Bool {
        // Check if email already exists
        if users.contains(where: { $0.email.lowercased() == user.email.lowercased() }) {
            return false
        }
        
        users.append(user)
        saveUsers()
        return true
    }
    func clearAllData() {
        UserDefaults.standard.removeObject(forKey: usersKey)
        UserDefaults.standard.removeObject(forKey: currentUserKey)
        UserDefaults.standard.removeObject(forKey: "TimeHistory")
        UserDefaults.standard.removeObject(forKey: "CurrentDayWatchTime")
        UserDefaults.standard.removeObject(forKey: "LastResetDate")
        
        users = []
        currentUser = nil
        print("🧹 All app data cleared")
    }
    
    func login(email: String, password: String) -> Bool {
        if let user = users.first(where: {
            $0.email.lowercased() == email.lowercased() && $0.password == password
        }) {
            currentUser = user
            saveCurrentUser()
            return true
        }
        return false
    }
    
    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: currentUserKey)
    }
    
    func updateUserCategories(_ categories: [String]) {
        guard let user = currentUser else { return }
        
        // Create updated user
        let updatedUser = User(
            name: user.name,
            age: user.age,
            email: user.email,
            password: user.password,
            fixedTimeThreshold: user.fixedTimeThreshold,
            preferredCategories: categories
        )
        
        // Update in users array
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = updatedUser
        }
        
        currentUser = updatedUser
        saveUsers()
        saveCurrentUser()
    }
    
    private func loadUsers() {
        if let data = UserDefaults.standard.data(forKey: usersKey),
           let decodedUsers = try? JSONDecoder().decode([User].self, from: data) {
            users = decodedUsers
        }
    }
    
    public func saveUsers() {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
    }
    
    private func loadCurrentUser() {
        if let data = UserDefaults.standard.data(forKey: currentUserKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
        }
    }
    
    public func saveCurrentUser() {
        if let user = currentUser,
           let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: currentUserKey)
        }
    }
}
