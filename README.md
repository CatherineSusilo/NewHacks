# NewHacks

**Break the scroll addiction with progressive resistance**

A digital wellness app that helps you break free from endless scrolling on TikTok and Instagram Reels. Scroll Jail turns your destructive scrolling habit into a game where you earn points for closing the app.

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

## How It Works

### 1. Personalized Content
- Dual Feed Support TikTok & Instagram Integration: Access both platforms in one controlled environment
- Category-Based Content: Users select interests during onboarding (Gaming, Comedy, Sports, Cooking, Tech, etc.)
- Smart Content Curation: Personalized feed based on selected categories and engagement

### 2. Progressive Intervention System
Normal Mode → Warning (80%) → Minor Lag (100%) → Lag of Shame (100%+)

### 3. The "Lag of Shame" 
When you exceed your daily time limit:
- **Phase 1**: 1-second delay between reels
- **Phase 2**: 3-second forced pause with dimmed screen  
- **Phase 3**: 5-second intervention with streak protection choice

### 4. Focus Streak System 
- Duolingo-style consecutive day counter
- Save your streak by closing the app when prompted
- Break your streak if you choose to continue scrolling
- Visual progress tracking and achievements

## The Psychology Behind Scroll Jail
- Loss Aversion: Protect your streak from resetting to zero
- Progressive Difficulty: Gradually increasing barriers to excessive use
- Positive Reinforcement: Celebrate wins and progress
- Mindful Interruptions: Break autopilot scrolling behavior

## 🛠️ Technical Implementation

### Architecture
```swift
ReelCage/
├── ReelCageApp.swift
├── Models/
│   ├── Reel.swift
│   ├── UserProfile.swift
│   └── AppState.swift
├── Views/
│   ├── ContentView.swift
│   ├── VideoPlayerView.swift
│   ├── OnboardingView.swift
│   └── StatsView.swift
├── ViewModels/
│   ├── ContentViewModel.swift
│   └── StreakManager.swift
├── Managers/
│   ├── LagManager.swift
│   ├── TimeTracker.swift
│   └── ContentManager.swift
└── Utilities/
    └── Constants.swift
