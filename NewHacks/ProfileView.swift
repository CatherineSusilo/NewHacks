//
//  ProfileView.swift
//  NewHacks
//
//  Created by Hassan Ibrahim on 2025-10-25.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var timeTrackingManager: TimeTrackingManager
    @EnvironmentObject var userDataManager: UserDataManager
    @State private var fakeTimeHistory: [DailyTimeEntry] = []
    @State private var showingCalendar = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // User Profile Header
                    if let user = userDataManager.currentUser {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(user.name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Age: \(user.age)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // Logout Button
                                Button(action: {
                                    showingLogoutAlert = true
                                }) {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundColor(.red)
                                        .padding(8)
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                            
                            // User Preferences
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Preferences")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Break Threshold: \(formatTimeThreshold(user.fixedTimeThreshold))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if !user.preferredCategories.isEmpty {
                                    Text("Categories: \(user.preferredCategories.joined(separator: ", "))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Time History")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Your video watching activity over the past week")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Bar Chart with Swipe to Calendar
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Daily Watch Time")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("Swipe right →")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .opacity(0.7)
                        }
                        .padding(.horizontal)
                        
                        if !fakeTimeHistory.isEmpty {
                            BarChartView(data: fakeTimeHistory)
                                .frame(height: 240)
                                .padding(.horizontal)
                                .gesture(
                                    DragGesture()
                                        .onEnded { value in
                                            if value.translation.width > 50 { // Swipe right
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    showingCalendar = true
                                                }
                                            }
                                        }
                                )
                        } else {
                            ProgressView("Loading time history...")
                                .frame(height: 240)
                        }
                    }
                    
                    // Statistics
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Statistics")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            StatCard(
                                title: "Total Time",
                                value: formatTotalTime(fakeTimeHistory),
                                icon: "clock.fill",
                                color: .blue
                            )
                            
                            StatCard(
                                title: "Average Daily",
                                value: formatAverageTime(fakeTimeHistory),
                                icon: "chart.bar.fill",
                                color: .green
                            )
                            
                            StatCard(
                                title: "Longest Session",
                                value: formatLongestSession(fakeTimeHistory),
                                icon: "star.fill",
                                color: .orange
                            )
                            
                            StatCard(
                                title: "Days Active",
                                value: "\(fakeTimeHistory.filter { $0.totalWatchTime > 0 }.count) days",
                                icon: "calendar",
                                color: .purple
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 100) // Space for tab bar
                }
            }
            .navigationBarHidden(true)
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    userDataManager.logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
        .sheet(isPresented: $showingCalendar) {
            MonthlyCalendarView(timeTrackingManager: timeTrackingManager)
        }
        .onAppear {
            generateFakeData()
        }
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
    
    private func generateFakeData() {
        let calendar = Calendar.current
        let today = Date()
        var history: [DailyTimeEntry] = []
        
        // Generate fake data for the past 7 days
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: today) ?? today
            let dayOfWeek = calendar.component(.weekday, from: date)
            
            // Generate realistic watch time based on day of week
            var watchTime: TimeInterval = 0
            
            // More activity on weekends
            if dayOfWeek == 1 || dayOfWeek == 7 { // Sunday or Saturday
                watchTime = Double.random(in: 0...7200) // 0 to 2 hours
            } else {
                watchTime = Double.random(in: 0...3600) // 0 to 1 hour
            }
            
            // Add some randomness - some days with no activity
            if Double.random(in: 0...1) < 0.2 { // 20% chance of no activity
                watchTime = 0
            }
            
            let entry = DailyTimeEntry(date: date, totalWatchTime: watchTime)
            history.append(entry)
        }
        
        // Sort by date (oldest first)
        fakeTimeHistory = history.sorted { $0.date < $1.date }
    }
    
    private func formatTotalTime(_ history: [DailyTimeEntry]) -> String {
        let totalSeconds = Int(history.reduce(0) { $0 + $1.totalWatchTime })
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func formatAverageTime(_ history: [DailyTimeEntry]) -> String {
        let activeDays = history.filter { $0.totalWatchTime > 0 }
        guard !activeDays.isEmpty else { return "0m" }
        
        let totalSeconds = Int(activeDays.reduce(0) { $0 + $1.totalWatchTime })
        let averageSeconds = totalSeconds / activeDays.count
        let hours = averageSeconds / 3600
        let minutes = (averageSeconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func formatLongestSession(_ history: [DailyTimeEntry]) -> String {
        let maxTime = history.map { $0.totalWatchTime }.max() ?? 0
        let hours = Int(maxTime) / 3600
        let minutes = (Int(maxTime) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct BarChartView: View {
    let data: [DailyTimeEntry]
    
    private var maxTime: TimeInterval {
        let maxValue = data.map { $0.totalWatchTime }.max() ?? 1
        return Swift.max(maxValue, 1) // Ensure we have at least 1 second for division
    }
    
    private var chartMaxTime: TimeInterval {
        // Cap the chart at 2 hours as per spec
        return min(maxTime, 7200) // 2 hours in seconds
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Chart bars
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data) { entry in
                    VStack(spacing: 8) {
                        // Bar
                        Rectangle()
                            .fill(barColor(for: entry.totalWatchTime))
                            .frame(width: 32)
                            .frame(height: max(4, CGFloat(entry.totalWatchTime / chartMaxTime) * 160))
                            .cornerRadius(6)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            
            // Day labels
            HStack(spacing: 8) {
                ForEach(data) { entry in
                    VStack(spacing: 4) {
                        Text(dayOfWeekLabel(for: entry.date))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text(dayNumberLabel(for: entry.date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 32)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func barColor(for time: TimeInterval) -> Color {
        if time == 0 {
            return Color.gray.opacity(0.3)
        } else if time < 1800 { // Less than 30 minutes
            return Color.green
        } else if time < 3600 { // Less than 1 hour
            return Color.yellow
        } else { // 1 hour or more
            return Color.red
        }
    }
    
    private func dayOfWeekLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    private func dayNumberLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ProfileView(timeTrackingManager: TimeTrackingManager())
}
