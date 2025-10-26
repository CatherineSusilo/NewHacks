//
//  LeaderboardView.swift
//  NewHacks
//
//  Created by Hassan Ibrahim on 2025-10-25.
//

import SwiftUI

// Data structure to track user screen times for leaderboard
struct UserScreenTime: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let userName: String
    let totalScreenTime: TimeInterval
    let lastUpdated: Date
    
    init(userId: UUID, userName: String, totalScreenTime: TimeInterval) {
        self.id = UUID()
        self.userId = userId
        self.userName = userName
        self.totalScreenTime = totalScreenTime
        self.lastUpdated = Date()
    }
}

// Manager to handle global leaderboard data
class LeaderboardManager: ObservableObject {
    @Published var userScreenTimes: [UserScreenTime] = []
    
    private let leaderboardKey = "LeaderboardData"
    
    init() {
        loadLeaderboardData()
    }
    
    func updateUserScreenTime(userId: UUID, userName: String, screenTime: TimeInterval) {
        if let index = userScreenTimes.firstIndex(where: { $0.userId == userId }) {
            userScreenTimes[index] = UserScreenTime(userId: userId, userName: userName, totalScreenTime: screenTime)
        } else {
            userScreenTimes.append(UserScreenTime(userId: userId, userName: userName, totalScreenTime: screenTime))
        }
        saveLeaderboardData()
    }
    
    func getTopUsers(limit: Int = 100) -> [UserScreenTime] {
        return userScreenTimes
            .sorted { $0.totalScreenTime < $1.totalScreenTime }
            .prefix(limit)
            .map { $0 }
    }
    
    private func loadLeaderboardData() {
        if let data = UserDefaults.standard.data(forKey: leaderboardKey),
           let decoded = try? JSONDecoder().decode([UserScreenTime].self, from: data) {
            userScreenTimes = decoded
        }
    }
    
    private func saveLeaderboardData() {
        if let data = try? JSONEncoder().encode(userScreenTimes) {
            UserDefaults.standard.set(data, forKey: leaderboardKey)
        }
    }
}

struct LeaderboardView: View {
    @EnvironmentObject var userDataManager: UserDataManager
    @StateObject private var leaderboardManager = LeaderboardManager()
    @ObservedObject var timeTrackingManager: TimeTrackingManager
    @State private var selectedUser: UserScreenTime?
    @State private var showingUserProfile = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                VStack(spacing: 8) {
                    Text("🏆 Leaderboard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Top 100 Users with Least Screen Time")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Leaderboard List
                List {
                    ForEach(Array(leaderboardManager.getTopUsers().enumerated()), id: \.element.id) { index, user in
                        LeaderboardRowView(
                            rank: index + 1,
                            user: user,
                            isCurrentUser: user.userId == userDataManager.currentUser?.id
                        )
                        .onTapGesture {
                            selectedUser = user
                            showingUserProfile = true
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingUserProfile) {
                if let user = selectedUser {
                    UserProfileDetailView(user: user)
                }
            }
            .onAppear {
                updateCurrentUserScreenTime()
                setupTimeTrackingCallback()
            }
        }
    }
    
    private func updateCurrentUserScreenTime() {
        guard let currentUser = userDataManager.currentUser else { return }
        
        // Calculate total screen time from time history
        let totalScreenTime = timeTrackingManager.totalScreenTime
        
        leaderboardManager.updateUserScreenTime(
            userId: currentUser.id,
            userName: currentUser.name,
            screenTime: totalScreenTime
        )
    }
    
    private func setupTimeTrackingCallback() {
        timeTrackingManager.onScreenTimeUpdate = { [weak leaderboardManager] totalScreenTime in
            guard let currentUser = userDataManager.currentUser else { return }
            leaderboardManager?.updateUserScreenTime(
                userId: currentUser.id,
                userName: currentUser.name,
                screenTime: totalScreenTime
            )
        }
    }
}

struct LeaderboardRowView: View {
    let rank: Int
    let user: UserScreenTime
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            // Rank
            ZStack {
                Circle()
                    .fill(rankColor)
                    .frame(width: 40, height: 40)
                
                Text("\(rank)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(user.userName)
                        .font(.headline)
                        .fontWeight(isCurrentUser ? .bold : .medium)
                    
                    if isCurrentUser {
                        Text("(You)")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                    }
                }
                
                Text("Screen Time: \(formattedTime(user.totalScreenTime))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Trophy icon for top 3
            if rank <= 3 {
                Image(systemName: trophyIcon)
                    .font(.title2)
                    .foregroundColor(trophyColor)
            }
        }
        .padding(.vertical, 8)
        .background(isCurrentUser ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .blue
        }
    }
    
    private var trophyIcon: String {
        switch rank {
        case 1: return "crown.fill"
        case 2: return "medal.fill"
        case 3: return "medal.fill"
        default: return ""
        }
    }
    
    private var trophyColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .clear
        }
    }
    
    private func formattedTime(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
}

struct UserProfileDetailView: View {
    let user: UserScreenTime
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 12) {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(String(user.userName.prefix(1)).uppercased())
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        )
                    
                    Text(user.userName)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top)
                
                // Stats Cards
                VStack(spacing: 16) {
                    StatCard(
                        title: "Total Screen Time",
                        value: formattedTime(user.totalScreenTime),
                        icon: "clock.fill",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Last Updated",
                        value: DateFormatter.shortDate.string(from: user.lastUpdated),
                        icon: "calendar",
                        color: .green
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func formattedTime(_ timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d hours %d minutes", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%d minutes %d seconds", minutes, seconds)
        } else {
            return String(format: "%d seconds", seconds)
        }
    }
}


extension DateFormatter {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    LeaderboardView(timeTrackingManager: TimeTrackingManager())
        .environmentObject(UserDataManager())
}
