//
//  NewHacksApp.swift
//  NewHacks
//
//  Created by Hassan Ibrahim on 2025-10-25.
//

import SwiftUI

@main
struct NewHacksApp: App {
    @StateObject private var userDataManager = UserDataManager()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let user = userDataManager.currentUser, !user.preferredCategories.isEmpty {
                    ContentView()
                        .environmentObject(userDataManager)
                } else {
                    AuthView()
                        .environmentObject(userDataManager)
                }
            }
        }
    }
}
