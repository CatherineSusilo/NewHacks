//
//  ContentView.swift
//  NewHacks
//
//  Created by Hassan Ibrahim on 2025-10-25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @StateObject private var timeTrackingManager = TimeTrackingManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Videos Tab
            ReelsContainerView(timeTrackingManager: timeTrackingManager)
                .environmentObject(userDataManager)
                .tabItem {
                    Image(systemName: "play.rectangle.fill")
                    Text("Videos")
                }
                .tag(0)
            
            // Profile Tab
            ProfileView(timeTrackingManager: timeTrackingManager)
                .environmentObject(userDataManager)
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Profile")
                }
                .tag(1)
        }
        .onChange(of: selectedTab) { newTab in
            // Pause timer when switching away from videos tab
            if newTab != 0 {
                timeTrackingManager.pauseTracking()
                // Note: Video pausing is handled by ReelsContainerView's onDisappear
            } else {
                // Resume timer when switching back to videos tab
                timeTrackingManager.resumeTracking()
            }
        }
    }
}

#Preview {
    ContentView()
}
