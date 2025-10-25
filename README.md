# NewHacks

**Break the scroll addiction with progressive resistance**

Reel Cage is an innovative iOS app that fights infinite scrolling addiction by using psychological reverse-engineering. Instead of blunt app blocking, it brings TikTok/Instagram-style content into a controlled environment where we reshape your scrolling habits through smart interventions.

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
- Select your interests during onboarding (gaming, comedy, cooking, etc.)
- Get a curated feed of trending content in those categories
- All within our compliant wrapper app

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

## Features

### Core Functionality
- Interest-based content curation
- Smart daily time limits
- Progressive lag injection
- Streak-based motivation
- Usage analytics dashboard

### User Experience  
- Clean, intuitive SwiftUI interface
- Real-time usage tracking
- Personalized intervention timing
- Achievement system
- Native iOS feel

### Wellness Tools
- Time saved statistics
- Breathing exercises on exit
- Activity suggestions
- Smart notifications
- Weekly progress reports

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
│   ├── ReelPlayerView.swift
│   ├── OnboardingView.swift
│   ├── InterventionView.swift
│   └── StatsView.swift
├── ViewModels/
│   ├── ReelManager.swift
│   └── UserManager.swift
└── Utilities/
    ├── LagManager.swift
    └── MockData.swift
