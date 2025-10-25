import SwiftUI

struct StreakView: View {
    @ObservedObject var viewModel: ContentViewModel
    @State private var showingAchievements = false
    @State private var showingFreezeInfo = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Current Streak Card
                    VStack(spacing: 16) {
                        Text("Current Streak")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack(alignment: .bottom, spacing: 8) {
                            Text("\(viewModel.streakManager.currentStreak)")
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .foregroundColor(streakColor)
                            
                            Text("days")
                                .font(.title2)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 8)
                        }
                        
                        if viewModel.streakManager.currentStreak > 0 {
                            Text("Keep going! You're on fire! 🔥")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        } else {
                            Text("Start your focus journey today!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    
                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(title: "Longest Streak", value: "\(viewModel.streakManager.longestStreak) days", icon: "trophy")
                        StatCard(title: "Total Tracked", value: "\(viewModel.streakManager.totalDaysTracked) days", icon: "calendar")
                        StatCard(title: "Success Rate", value: "\(Int(viewModel.streakManager.successRate * 100))%", icon: "chart.line.uptrend.xyaxis")
                        StatCard(title: "Freezes", value: "\(viewModel.streakManager.streakFreezes)", icon: "snowflake")
                    }
                    
                    // Next Milestone
                    if let nextMilestone = viewModel.streakManager.nextMilestone, viewModel.streakManager.currentStreak < nextMilestone.rawValue {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("Next Milestone")
                                    .font(.headline)
                                Spacer()
                                Text("\(viewModel.streakManager.daysUntilNextMilestone) days")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(nextMilestone.title)
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text(nextMilestone.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            ProgressView(value: Double(viewModel.streakManager.currentStreak), total: Double(nextMilestone.rawValue))
                                .progressViewStyle(LinearProgressViewStyle())
                                .tint(streakColor)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    }
                    
                    // Freeze Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "snowflake")
                                .foregroundColor(.blue)
                            Text("Streak Freezes")
                                .font(.headline)
                            Spacer()
                            
                            Button(action: { showingFreezeInfo = true }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        Text("Protect your streak on days you go over your limit")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text("Available: \(viewModel.streakManager.streakFreezes)")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            if let lastFreeze = viewModel.streakManager.lastFreezeUsed {
                                Text("Last used: \(formatDate(lastFreeze))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    
                    // Achievements Preview
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "medal.fill")
                                .foregroundColor(.orange)
                            Text("Recent Achievements")
                                .font(.headline)
                            Spacer()
                            
                            Button("View All") {
                                showingAchievements = true
                            }
                            .font(.subheadline)
                        }
                        
                        let recentAchievements = Array(viewModel.streakManager.achievements.prefix(3))
                        
                        if recentAchievements.isEmpty {
                            Text("Complete streaks to unlock achievements!")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(recentAchievements, id: \.self) { achievement in
                                    AchievementBadge(achievement: achievement)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                    
                    // Streak History (Simplified)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.green)
                            Text("Streak History")
                                .font(.headline)
                            Spacer()
                        }
                        
                        HStack {
                            ForEach(0..<7) { day in
                                let streakDay = Calendar.current.date(byAdding: .day, value: -day, to: Date())!
                                let hasStreak = viewModel.streakManager.streakHistory.contains { 
                                    Calendar.current.isDate($0, inSameDayAs: streakDay)
                                }
                                
                                VStack(spacing: 4) {
                                    Text(day == 0 ? "Today" : weekdayAbbreviation(for: streakDay))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    
                                    Circle()
                                        .fill(hasStreak ? streakColor : Color.gray.opacity(0.3))
                                        .frame(width: 24, height: 24)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                }
                .padding()
            }
            .navigationTitle("Focus Streak")
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showingAchievements) {
                AchievementsView(streakManager: viewModel.streakManager)
            }
            .sheet(isPresented: $showingFreezeInfo) {
                FreezeInfoView()
            }
        }
    }
    
    private var streakColor: Color {
        switch viewModel.streakManager.currentStreak {
        case 0: return .gray
        case 1...6: return .green
        case 7...29: return .blue
        case 30...99: return .purple
        default: return .orange
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    private func weekdayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct AchievementBadge: View {
    let achievement: StreakAchievement
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: achievement.iconName)
                .font(.title3)
                .foregroundColor(.orange)
            
            Text(achievement.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

struct AchievementsView: View {
    let streakManager: StreakViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(StreakAchievement.allCases, id: \.self) { achievement in
                    HStack {
                        Image(systemName: achievement.iconName)
                            .font(.title2)
                            .foregroundColor(.orange)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(achievement.rawValue)
                                .font(.headline)
                            Text(achievement.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if streakManager.achievements.contains(achievement) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "lock.circle")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FreezeInfoView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(spacing: 12) {
                        Image(systemName: "snowflake")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)
                        
                        Text("Streak Freezes")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(icon: "shield.checkered", title: "What are streak freezes?", description: "Freezes protect your streak when you accidentally go over your daily scrolling limit.")
                        
                        InfoRow(icon: "plus.circle", title: "How to get more", description: "Earn freezes by maintaining streaks and reaching milestones.")
                        
                        InfoRow(icon: "exclamationmark.triangle", title: "Important", description: "Freezes are automatically used when needed. You can have up to 3 at a time.")
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Dismiss
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    StreakView(viewModel: ContentViewModel())
}
