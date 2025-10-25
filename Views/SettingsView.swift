import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: ContentViewModel
    @State private var showingResetConfirmation = false
    @State private var showingTimeLimitPicker = false
    @State private var temporarySettings = AppSettings.default
    
    var body: some View {
        NavigationView {
            Form {
                // MARK: - Time Limits Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Daily Time Limit")
                            Spacer()
                            Text("\(Int(viewModel.settings.dailyTimeLimit / 60)) min")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: Binding(
                                get: { viewModel.settings.dailyTimeLimit / 60 },
                                set: { viewModel.settings.dailyTimeLimit = $0 * 60 }
                            ),
                            in: 5...120,
                            step: 5
                        )
                    }
                    .padding(.vertical, 4)
                    
                    Toggle("Auto Reset Daily", isOn: $viewModel.settings.autoResetDaily)
                    Toggle("Show Time Saved", isOn: $viewModel.settings.showTimeSaved)
                } header: {
                    Text("Time Management")
                } footer: {
                    Text("Set how much time you want to allow for scrolling each day")
                }

                // MARK: - Lag Settings Section
                Section {
                    Toggle("Enable Lag System", isOn: $viewModel.settings.isLagEnabled)
                    
                    if viewModel.settings.isLagEnabled {
                        Picker("Lag Intensity", selection: $viewModel.settings.lagIntensity) {
                            ForEach(LagIntensity.allCases, id: \.self) { intensity in
                                Text(intensity.rawValue).tag(intensity)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Toggle("Progressive Lag", isOn: $viewModel.settings.progressiveLag)
                        
                        if viewModel.settings.lagIntensity == .custom {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Minimum Lag: \(Int(viewModel.settings.minimumLagDuration))s")
                                Slider(value: $viewModel.settings.minimumLagDuration, in: 0.5...3.0, step: 0.5)
                                
                                Text("Maximum Lag: \(Int(viewModel.settings.maximumLagDuration))s")
                                Slider(value: $viewModel.settings.maximumLagDuration, in: 3.0...10.0, step: 0.5)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    Text("Lag Intervention")
                } footer: {
                    Text("Lag system helps break infinite scrolling by adding delays between videos")
                }

                // MARK: - Notifications Section
                Section {
                    Toggle("Smart Warnings", isOn: $viewModel.settings.smartWarnings)
                    Toggle("Haptic Feedback", isOn: $viewModel.settings.hapticFeedback)
                    
                    Picker("Notification Style", selection: $viewModel.settings.notificationStyle) {
                        ForEach(NotificationStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    
                    if viewModel.settings.smartWarnings {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Warning Thresholds")
                                .font(.headline)
                            
                            ForEach(viewModel.settings.warningThresholds.indices, id: \.self) { index in
                                HStack {
                                    Text("\(Int(viewModel.settings.warningThresholds[index] * 100))%")
                                    Spacer()
                                    Slider(
                                        value: Binding(
                                            get: { viewModel.settings.warningThresholds[index] },
                                            set: { viewModel.settings.warningThresholds[index] = $0 }
                                        ),
                                        in: 0.1...0.95,
                                        step: 0.05
                                    )
                                    .frame(width: 150)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Notifications & Feedback")
                }

                // MARK: - Mascot Section
                Section {
                    Toggle("Enable Mascot", isOn: $viewModel.settings.mascotEnabled)
                    
                    if viewModel.settings.mascotEnabled {
                        Picker("Mascot", selection: $viewModel.settings.selectedMascot) {
                            ForEach(MascotType.allCases, id: \.self) { mascot in
                                HStack {
                                    Image(systemName: mascotIcon(mascot))
                                    Text(mascot.rawValue)
                                }
                                .tag(mascot)
                            }
                        }
                        
                        Picker("Appearance Frequency", selection: $viewModel.settings.mascotFrequency) {
                            ForEach(MascotFrequency.allCases, id: \.self) { frequency in
                                Text(frequency.rawValue).tag(frequency)
                            }
                        }
                        
                        Toggle("Animations", isOn: $viewModel.settings.mascotAnimations)
                    }
                } header: {
                    Text("Mascot")
                } footer: {
                    Text("Your mascot companion provides encouragement and reminders")
                }

                // MARK: - Content Section
                Section {
                    Picker("Default Platform", selection: $viewModel.settings.defaultPlatform) {
                        ForEach(Platform.allCases, id: \.self) { platform in
                            Text(platform.rawValue).tag(platform)
                        }
                    }
                    
                    NavigationLink {
                        ContentCategoriesView(selectedCategories: $viewModel.settings.contentCategories)
                    } label: {
                        HStack {
                            Text("Content Categories")
                            Spacer()
                            Text("\(viewModel.settings.contentCategories.count) selected")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    
                    Picker("Video Quality", selection: $viewModel.settings.contentQuality) {
                        ForEach(ContentQuality.allCases, id: \.self) { quality in
                            Text(quality.rawValue).tag(quality)
                        }
                    }
                    
                    Toggle("Auto-play Videos", isOn: $viewModel.settings.autoPlay)
                    Toggle("Safe Mode", isOn: $viewModel.settings.safeMode)
                } header: {
                    Text("Content Preferences")
                }

                // MARK: - Streak Section
                Section {
                    Toggle("Streak Reminders", isOn: $viewModel.settings.streakReminders)
                    Toggle("Streak Freezes", isOn: $viewModel.settings.streakFreezeEnabled)
                    Toggle("Achievement Notifications", isOn: $viewModel.settings.achievementNotifications)
                    Toggle("Weekly Recap", isOn: $viewModel.settings.weeklyRecap)
                } header: {
                    Text("Streak Settings")
                }

                // MARK: - Privacy Section
                Section {
                    Toggle("Collect Analytics", isOn: $viewModel.settings.collectAnalytics)
                    Toggle("Crash Reporting", isOn: $viewModel.settings.crashReporting)
                    Toggle("Save Watch History", isOn: $viewModel.settings.saveWatchHistory)
                } header: {
                    Text("Privacy")
                } footer: {
                    Text("Analytics help us improve the app experience. No personal data is shared.")
                }

                // MARK: - Actions Section
                Section {
                    Button("Reset All Data") {
                        showingResetConfirmation = true
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    
                    Button("Restore Default Settings") {
                        viewModel.settings.resetToDefaults()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onChange(of: viewModel.settings) { _ in
                viewModel.settings.saveToUserDefaults()
            }
            .alert("Reset All Data", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will reset your streaks, settings, and all app data. This action cannot be undone.")
            }
        }
    }
    
    private func mascotIcon(_ mascot: MascotType) -> String {
        switch mascot {
        case .owl: return "bird"
        case .sloth: return "leaf"
        case .fox: return "pawprint"
        case .bear: return "pawprint.circle"
        case .rabbit: return "hare"
        }
    }
    
    private func resetAllData() {
        // Reset user data
        viewModel.user = User(
            selectedCategories: viewModel.user.selectedCategories,
            dailyTimeLimit: User.defaultTimeLimit,
            currentStreak: 0,
            totalTimeSaved: 0
        )
        
        // Reset streak
        viewModel.streakManager = StreakViewModel()
        
        // Reset time tracker
        viewModel.timeTracker.resetDailyTime()
        
        // Reset settings to default
        viewModel.settings.resetToDefaults()
    }
}

// MARK: - Supporting Views

struct ContentCategoriesView: View {
    @Binding var selectedCategories: [ContentCategory]
    
    var body: some View {
        List {
            Section {
                ForEach(ContentCategory.allCases, id: \.self) { category in
                    HStack {
                        Image(systemName: iconForCategory(category))
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        
                        Text(category.rawValue)
                        
                        Spacer()
                        
                        if selectedCategories.contains(category) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleCategory(category)
                    }
                }
            } header: {
                Text("Select categories for your feed")
            } footer: {
                Text("Select at least 3 categories for better personalization")
            }
        }
        .navigationTitle("Content Categories")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func toggleCategory(_ category: ContentCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.removeAll { $0 == category }
        } else {
            selectedCategories.append(category)
        }
    }
    
    private func iconForCategory(_ category: ContentCategory) -> String {
        switch category {
        case .gaming: return "gamecontroller"
        case .comedy: return "theatermasks"
        case .sports: return "sportscourt"
        case .cooking: return "fork.knife"
        case .tech: return "laptopcomputer"
        case .dance: return "music.note"
        case .education: return "book"
        case .animals: return "pawprint"
        }
    }
}

#Preview {
    SettingsView(viewModel: ContentViewModel())
}
