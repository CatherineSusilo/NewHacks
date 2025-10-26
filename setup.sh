#!/bin/bash

# NewHacks Setup Script
echo "🚀 Setting up NewHacks..."

# Check if Config.plist already exists
if [ -f "NewHacks/Config.plist" ]; then
    echo "✅ Config.plist already exists"
else
    echo "📋 Creating Config.plist from example..."
    cp NewHacks/Config.example.plist NewHacks/Config.plist
    echo "✅ Config.plist created"
fi

echo ""
echo "🔑 Next steps:"
echo "1. Get a YouTube Data API v3 key from https://console.cloud.google.com/"
echo "2. Open NewHacks/Config.plist in Xcode"
echo "3. Replace 'YOUR_YOUTUBE_API_KEY_HERE' with your actual API key"
echo "4. Build and run the project!"
echo ""
echo "⚠️  Important: Never commit Config.plist to version control"
echo "   (it's already in .gitignore for your safety)"
