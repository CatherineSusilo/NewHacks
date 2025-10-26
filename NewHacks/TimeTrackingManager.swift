//
//  TimeTrackingManager.swift
//  NewHacks
//
//  Created by Hassan Ibrahim on 2025-10-25.
//

import Foundation
import SwiftUI

// Data model for daily time tracking
struct DailyTimeEntry: Codable, Identifiable {
    let id = UUID()
    let date: Date
    var totalWatchTime: TimeInterval
    
    init(date: Date = Date(), totalWatchTime: TimeInterval = 0) {
        self.date = Calendar.current.startOfDay(for: date)
        self.totalWatchTime = totalWatchTime
    }
}

// Observable class to manage time tracking
class TimeTrackingManager: ObservableObject {
    @Published var currentDayWatchTime: TimeInterval = 0
    @Published var timeHistory: [DailyTimeEntry] = []
    @Published var isActive = false
    
    private let userDefaults = UserDefaults.standard
    private let timeHistoryKey = "TimeHistory"
    private let currentDayKey = "CurrentDayWatchTime"
    private let lastResetDateKey = "LastResetDate"
    
    private var timer: Timer?
    private var sessionStartTime: Date?
    private var baseWatchTime: TimeInterval = 0
    
    init() {
        loadTimeHistory()
        checkForDayReset()
        loadCurrentDayTime()
    }
    
    // MARK: - Public Methods
    
    func startTracking() {
        guard !isActive else {
            print("⏱️ Tracking already active")
            return
        }
        
        guard sessionStartTime == nil else {
            print("⏱️ Session already started")
            return
        }
        
        print("▶️ Starting time tracking")
        sessionStartTime = Date()
        baseWatchTime = currentDayWatchTime
        isActive = true
        startTimer()
    }
    
    func stopTracking() {
        guard let startTime = sessionStartTime else { return }
        
        let sessionDuration = Date().timeIntervalSince(startTime)
        currentDayWatchTime = baseWatchTime + sessionDuration
        
        sessionStartTime = nil
        stopTimer()
        isActive = false
        saveCurrentDayTime()
        updateTimeHistory()
    }
    
    func pauseTracking() {
        guard let startTime = sessionStartTime else {
            print("⏸️ No active session to pause")
            return
        }
        
        print("⏸️ Pausing time tracking")
        let sessionDuration = Date().timeIntervalSince(startTime)
        currentDayWatchTime = baseWatchTime + sessionDuration
        
        sessionStartTime = nil
        stopTimer()
        isActive = false
        
        saveCurrentDayTime()
        updateTimeHistory()
    }
    
    func resumeTracking() {
        guard sessionStartTime == nil else {
            print("▶️ Session already running")
            return
        }
        
        print("▶️ Resuming time tracking")
        sessionStartTime = Date()
        baseWatchTime = currentDayWatchTime
        isActive = true
        startTimer()
    }
    
    // MARK: - Private Methods
    
    private func startTimer() {
        // Use a more efficient timer approach
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateCurrentTime()
        }
        print("⏱️ Timer started")
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        print("⏱️ Timer stopped")
    }
    
    private func updateCurrentTime() {
        guard let startTime = sessionStartTime else { return }
        
        let sessionDuration = Date().timeIntervalSince(startTime)
        let totalTime = baseWatchTime + sessionDuration
        
        // Update the published property to trigger UI updates
        currentDayWatchTime = totalTime
    }
    
    private func checkForDayReset() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastResetDate = userDefaults.object(forKey: lastResetDateKey) as? Date ?? Date.distantPast
        let lastResetDay = Calendar.current.startOfDay(for: lastResetDate)
        
        if today > lastResetDay {
            // New day - reset current day time
            currentDayWatchTime = 0
            saveCurrentDayTime()
            userDefaults.set(today, forKey: lastResetDateKey)
        }
    }
    
    private func loadTimeHistory() {
        if let data = userDefaults.data(forKey: timeHistoryKey),
           let history = try? JSONDecoder().decode([DailyTimeEntry].self, from: data) {
            timeHistory = history
        }
    }
    
    private func saveTimeHistory() {
        if let data = try? JSONEncoder().encode(timeHistory) {
            userDefaults.set(data, forKey: timeHistoryKey)
        }
    }
    
    private func loadCurrentDayTime() {
        currentDayWatchTime = userDefaults.double(forKey: currentDayKey)
    }
    
    private func saveCurrentDayTime() {
        userDefaults.set(currentDayWatchTime, forKey: currentDayKey)
    }
    
    private func updateTimeHistory() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Find existing entry for today
        if let index = timeHistory.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            timeHistory[index].totalWatchTime = currentDayWatchTime
        } else {
            // Create new entry for today
            let newEntry = DailyTimeEntry(date: today, totalWatchTime: currentDayWatchTime)
            timeHistory.append(newEntry)
        }
        
        saveTimeHistory()
    }
    
    // MARK: - Computed Properties
    
    var formattedCurrentTime: String {
        let totalSeconds = Int(currentDayWatchTime)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    var isCurrentlyTracking: Bool {
        return sessionStartTime != nil && isActive
    }
}
