# LockedIn

**Break the scroll addiction with progressive resistance**
LockedIn - A mindful YouTube Shorts viewer that breaks autopilot scrolling through behavioral psychology. Using loss aversion streaks, progressive difficulty, and mindful interruptions, it transforms passive consumption into intentional engagement while celebrating your progress toward healthier digital habits.

![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)
![Platform](https://img.shields.io/badge/Platform-iOS-lightgrey.svg)

## The Problem

Infinite scroll platforms like TikTok and Instagram Reels are designed to be addictive, using perfected algorithms that keep users mindlessly swiping for hours. This leads to:
- Decreased productivity
- Reduced attention spans  
- Wasted time
- Digital guilt

## Our Solution
Reel Cage fights fire with fire. We use the same addictive mechanics against these platforms by creating a controlled environment where we can:
- **Reward stopping** instead of endless scrolling
- **Break the rhythm** with progressive resistance
- **Gamify self-control** with streak-based motivation
- **Provide insights** into your digital habits

## Features:
- 🔄 Smart Break System: Automatic breaks based on your personalized time thresholds
- 🧠 AI Insights: Gemini AI analyzes your scrolling habits and provides personalized recommendations
- 🎯 Personalized Content: Category-based YouTube Shorts feed tailored to your preferences
- 📊 Progress Tracking: Visual analytics and time tracking with weekly insights
- 🔐 User Profiles: Secure local authentication with customizable preferences

## How It Works
1. Set Preferences: Choose your break threshold (30-150 minutes) and preferred content categories
2. Watch Mindfully: Enjoy personalized YouTube Shorts with AI-curated content
3. Take Breaks: Automatic breaks trigger at 60% of your set threshold to prevent endless scrolling
4. Get Insights: Receive weekly AI-powered analysis of your scrolling habits

## Tech Stack
- SwiftUI - Modern iOS interface
- YouTube Data API - Shorts content fetching
- UserDefaults - Local data persistence

## Pages
- Auth Screen - Login/Signup with vermillion-themed design
- Categories Selection - Personalized content preferences
- Shorts Viewer - Infinite scroll with smart breaks
- Profile & Analytics - AI insights and time tracking data

### Architecture
```swift
ScrollJail/
├── ScrollJail/
│   ├── Models/
│   │   ├── User.swift
│   │   ├── Reel.swift
│   │   ├── Streak.swift
│   │   └── AppSettings.swift
│   ├── ViewModels/
│   │   ├── ContentViewModel.swift
│   │   ├── StreakViewModel.swift
│   │   └── LagManager.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── VideoPlayerView.swift
│   │   ├── StreakView.swift
│   │   ├── OnboardingView.swift
│   │   └── SettingsView.swift
│   ├── Services/
│   │   ├── ContentService.swift
│   │   ├── TimeTracker.swift
│   │   └── MascotManager.swift
│   └── Utilities/
│       ├── LagEngine.swift
│       └── Constants.swift
├── Assets/
│   ├── Mascot/
│   │   ├── mascot_normal.png
│   │   ├── mascot_warning.png
│   │   └── mascot_sad.png
│   └── AppIcon.appiconset
└── Preview Content/
    └── MockData.swift
```
License
MIT License - feel free to use this project for learning and development!
