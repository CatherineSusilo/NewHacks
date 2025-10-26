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
    @State private var showingEditPreferences = false
    @State private var editedFixedTimeThreshold: TimeInterval = 600.0
    @State private var editedCategories: Set<String> = []
    
    let availableCategories = [
        "Funny", "Dance", "Comedy", "Gaming", "Music", "Art",
        "Cooking", "Sports", "Travel", "Animals", "Education",
        "Beauty", "Fashion", "DIY", "Science", "Technology"
    ]
    
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
                                
                                // Edit and Logout Buttons
                                HStack(spacing: 12) {
                                    // Edit Preferences Button
                                    Button(action: {
                                        editedFixedTimeThreshold = user.fixedTimeThreshold
                                        editedCategories = Set(user.preferredCategories)
                                        showingEditPreferences = true
                                    }) {
                                        Image(systemName: "gearshape.fill")
                                            .foregroundColor(.blue)
                                            .padding(8)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(8)
                                    }
                                    
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
                            }
                            
                            // User Preferences
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Preferences")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text("Tap gear to edit")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                
                                // Break Threshold
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Break Threshold")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text(formatTimeThreshold(user.fixedTimeThreshold))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(8)
                                }
                                
                                // Categories
                                if !user.preferredCategories.isEmpty {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Preferred Categories")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        FlowLayout(spacing: 8) {
                                            ForEach(user.preferredCategories, id: \.self) { category in
                                                Text(category)
                                                    .font(.caption)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(Color.green.opacity(0.1))
                                                    .cornerRadius(12)
                                            }
                                        }
                                    }
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
            .sheet(isPresented: $showingEditPreferences) {
                EditPreferencesView(
                    userDataManager: userDataManager,
                    fixedTimeThreshold: $editedFixedTimeThreshold,
                    selectedCategories: $editedCategories,
                    availableCategories: availableCategories,
                    isPresented: $showingEditPreferences
                )
            }
            .alert("Log Out", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    userDataManager.logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
        .onAppear {
            generateFakeData()
            // Pause tracking when profile appears
            print("⏸️ Pausing tracking - profile view appeared")
            timeTrackingManager.pauseTracking()
        }
        .onDisappear {
            // Only resume tracking if user is still logged in when leaving profile
            if userDataManager.currentUser != nil {
                print("▶️ Resuming tracking - profile view disappeared")
                timeTrackingManager.resumeTracking()
            }
        }
        .sheet(isPresented: $showingCalendar) {
            MonthlyCalendarView(timeTrackingManager: timeTrackingManager)
        }
    }
    private func logoutUser() {
        print("🚪 Logging out user")
        // Pause tracking before logging out
        timeTrackingManager.pauseTracking()
        timeTrackingManager.stopTracking() // Completely stop tracking
        userDataManager.logout()
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

// MARK: - Edit Preferences View
struct EditPreferencesView: View {
    @ObservedObject var userDataManager: UserDataManager
    @Binding var fixedTimeThreshold: TimeInterval
    @Binding var selectedCategories: Set<String>
    let availableCategories: [String]
    @Binding var isPresented: Bool
    @State private var showSuccessMessage = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Edit Preferences")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Update your break threshold and preferred categories")
                            .foregroundColor(.secondary)
                    }
                    
                    // Break Threshold Section
                    VStack(alignment: .leading, spacing: 12) {
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
                            .padding(.top, 4)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Categories Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Preferred Categories")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Select categories to personalize your Shorts feed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
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
                        
                        Text("Selected \(selectedCategories.count) categories")
                            .font(.caption)
                            .foregroundColor(selectedCategories.count >= 3 ? .green : .orange)
                            .padding(.top, 4)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Save Button
                    Button(action: savePreferences) {
                        HStack {
                            Text("Save Preferences")
                                .fontWeight(.semibold)
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedCategories.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(selectedCategories.isEmpty)
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitle("Edit Preferences", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    savePreferences()
                }
                .disabled(selectedCategories.isEmpty)
            )
            .overlay(
                Group {
                    if showSuccessMessage {
                        SuccessOverlay(message: "Preferences Updated!")
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    showSuccessMessage = false
                                    isPresented = false
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
    
    private func savePreferences() {
        let categories = Array(selectedCategories)
        userDataManager.updateUserCategories(categories)
        
        // Update fixed time threshold
        if let user = userDataManager.currentUser {
            let updatedUser = User(
                name: user.name,
                age: user.age,
                email: user.email,
                password: user.password,
                fixedTimeThreshold: fixedTimeThreshold,
                preferredCategories: categories
            )
            
            // Update in users array
            if let index = userDataManager.users.firstIndex(where: { $0.id == user.id }) {
                userDataManager.users[index] = updatedUser
            }
            
            userDataManager.currentUser = updatedUser
            userDataManager.saveUsers()
            userDataManager.saveCurrentUser()
        }
        
        withAnimation {
            showSuccessMessage = true
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
}

// MARK: - Flow Layout for Categories
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for size in sizes {
            if lineWidth + size.width + spacing > proposal.width ?? 0 {
                totalHeight += lineHeight + spacing
                totalWidth = max(totalWidth, lineWidth)
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
        }
        
        totalHeight += lineHeight
        totalWidth = max(totalWidth, lineWidth)
        
        return CGSize(width: totalWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var lineX = bounds.minX
        var lineY = bounds.minY
        var lineHeight: CGFloat = 0
        
        for index in subviews.indices {
            let size = sizes[index]
            
            if lineX + size.width > bounds.maxX {
                lineY += lineHeight + spacing
                lineHeight = 0
                lineX = bounds.minX
            }
            
            subviews[index].place(
                at: CGPoint(x: lineX, y: lineY),
                proposal: ProposedViewSize(size)
            )
            
            lineX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
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
