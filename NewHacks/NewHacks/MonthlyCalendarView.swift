//
//  MonthlyCalendarView.swift
//  NewHacks
//
//  Created by Hassan Ibrahim on 2025-10-25.
//

import SwiftUI

struct MonthlyCalendarView: View {
    @ObservedObject var timeTrackingManager: TimeTrackingManager
    @State private var currentMonth = Date()
    @State private var monthlyData: [DailyTimeEntry] = []
    
    private let goalHours: Double = 5.0 // 5 hours goal
    private let goalSeconds: TimeInterval = 5 * 3600 // 5 hours in seconds
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Monthly Progress")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Goal: Under \(Int(goalHours)) hours daily")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Month Navigation
                HStack {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text(monthYearFormatter.string(from: currentMonth))
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
            }
            
            // Calendar Grid
            VStack(spacing: 8) {
                // Day headers
                HStack {
                    ForEach(dayHeaders, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal)
                
                // Calendar days
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(calendarDays, id: \.self) { day in
                        CalendarDayView(
                            day: day,
                            isCurrentMonth: isCurrentMonth(day),
                            isToday: isToday(day),
                            hasGoalMet: hasGoalMet(for: day),
                            hasData: hasData(for: day)
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Legend
            HStack(spacing: 20) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Goal Met")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                    Text("Goal Missed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                    Text("No Data")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top)
            
            Spacer()
        }
        .padding()
        .onAppear {
            generateMonthlyData()
        }
        .onChange(of: currentMonth) { _ in
            generateMonthlyData()
        }
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    private var dayHeaders: [String] {
        ["S", "M", "T", "W", "T", "F", "S"]
    }
    
    private var calendarDays: [Date] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let endOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.end ?? currentMonth
        
        // Get the first day of the week for the month
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let startDate = calendar.date(byAdding: .day, value: -(firstWeekday - 1), to: startOfMonth) ?? startOfMonth
        
        var days: [Date] = []
        var currentDate = startDate
        
        // Generate 42 days (6 weeks) to fill the calendar
        for _ in 0..<42 {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
    
    private func isCurrentMonth(_ date: Date) -> Bool {
        Calendar.current.isDate(date, equalTo: currentMonth, toGranularity: .month)
    }
    
    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private func hasGoalMet(for date: Date) -> Bool {
        guard let entry = monthlyData.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) else {
            return false
        }
        return entry.totalWatchTime <= goalSeconds
    }
    
    private func hasData(for date: Date) -> Bool {
        return monthlyData.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private func previousMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    private func nextMonth() {
        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
    
    private func generateMonthlyData() {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let endOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.end ?? currentMonth
        let today = Date()
        
        var data: [DailyTimeEntry] = []
        var currentDate = startOfMonth
        
        while currentDate < endOfMonth {
            // Only generate data for dates up to and including today
            if currentDate <= today {
                // Generate realistic watch time data
                let dayOfWeek = calendar.component(.weekday, from: currentDate)
                var watchTime: TimeInterval = 0
                
                // More activity on weekends
                if dayOfWeek == 1 || dayOfWeek == 7 { // Sunday or Saturday
                    watchTime = Double.random(in: 0...21600) // 0 to 6 hours
                } else {
                    watchTime = Double.random(in: 0...18000) // 0 to 5 hours
                }
                
                // Add some randomness - some days with no activity
                if Double.random(in: 0...1) < 0.15 { // 15% chance of no activity
                    watchTime = 0
                }
                
                // Ensure some days meet the goal (under 5 hours) and some don't
                if Double.random(in: 0...1) < 0.3 { // 30% chance of exceeding goal
                    watchTime = Double.random(in: goalSeconds...28800) // 5-8 hours
                } else {
                    watchTime = Double.random(in: 0...goalSeconds) // 0-5 hours
                }
                
                let entry = DailyTimeEntry(date: currentDate, totalWatchTime: watchTime)
                data.append(entry)
            }
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        monthlyData = data
    }
}

struct CalendarDayView: View {
    let day: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let hasGoalMet: Bool
    let hasData: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: day))")
                .font(.title3)
                .fontWeight(isToday ? .bold : .medium)
                .foregroundColor(textColor)
            
            if hasData {
                Image(systemName: hasGoalMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(hasGoalMet ? .green : .red)
            } else {
                Image(systemName: "circle")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 40, height: 40)
        .background(backgroundColor)
        .cornerRadius(8)
        .opacity(isCurrentMonth ? 1.0 : 0.3)
    }
    
    private var textColor: Color {
        if isToday {
            return .white
        } else if isCurrentMonth {
            return .primary
        } else {
            return .secondary
        }
    }
    
    private var backgroundColor: Color {
        if isToday {
            return .blue
        } else {
            return .clear
        }
    }
}

#Preview {
    MonthlyCalendarView(timeTrackingManager: TimeTrackingManager())
}
