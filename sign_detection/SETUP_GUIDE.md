# ISL Translate - Setup & Running Guide

## Quick Start

### Prerequisites
- **Flutter SDK**: 3.0 or higher
- **Dart SDK**: 3.0 or higher (comes with Flutter)
- **Android Studio** OR **Xcode** (for device emulators)

### 1. Install Flutter

**Windows:**
```bash
# Download from: https://flutter.dev/docs/get-started/install
# Extract to a folder (e.g., C:\flutter)
# Add to PATH environment variable
```

**macOS/Linux:**
```bash
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"
```

### 2. Verify Installation

```bash
flutter doctor
```

This should show:
- ✓ Flutter SDK
- ✓ Dart SDK
- ✓ Android Studio (for Android) OR Xcode (for iOS)
- ✓ Connected device or emulator

### 3. Clone and Navigate to Project

```bash
cd c:\sign_detection
```

### 4. Get Dependencies

```bash
flutter pub get
```

This installs all required packages:
- `google_fonts` - Custom typography
- `animate_do` - Animations
- `intl` - Internationalization
- `fl_chart` - Charts (for future analytics)
- `uuid` - Unique IDs
- Plus others...

### 5. Run the App

**On Android Emulator:**
```bash
flutter emulators --launch Pixel_5_API_31
flutter run
```

**On Physical Android Device:**
```bash
# Enable USB debugging on your device
# Connect via USB
flutter run
```

**On iOS Simulator (macOS only):**
```bash
flutter run -d macos
```

**Specify a Device:**
```bash
flutter devices                    # List available devices
flutter run -d <device_id>        # Run on specific device
```

## Project Structure

```
c:\sign_detection/
├── lib/
│   ├── main.dart               # App entry point
│   ├── app/
│   │   ├── app.dart           # Main navigation
│   │   └── theme.dart         # Material 3 theme with Light/Dark modes
│   ├── core/
│   │   └── widgets/           # Reusable UI components
│   ├── data/
│   │   ├── models/            # Data models
│   │   ├── mock/              # Mock data repository
│   │   └── services/          # Mock services
│   └── features/              # Feature screens
├── assets/                    # Images, fonts, icons
├── pubspec.yaml              # Dependencies
├── README.md                 # Project overview
└── SETUP_GUIDE.md           # This file
```

## Key Files to Understand

### 1. `lib/main.dart`
- App entry point
- Initializes theme and navigation

### 2. `lib/app/theme.dart`
- Complete Material 3 theme system
- Light and dark themes
- Custom colors, typography, buttons

### 3. `lib/data/mock/mock_data.dart`
- All mock data for the application
- User information
- ISL signs (20+ examples)
- Translation history
- Video calls history

### 4. `lib/data/models/models.dart`
- All data models (User, Translation, Sign, etc.)
- Designed for easy backend integration

### 5. `lib/features/`
Main screens and features:
- `splash/` - Animated splash screen
- `onboarding/` - 3-step onboarding
- `home/` - Main dashboard
- `translation/` - Live ISL translation
- `video_call/` - Video call interface
- `call_summary/` - Call results
- `history/` - Translation history
- `dictionary/` - ISL signs dictionary
- `profile/` - User profile
- `settings/` - Settings & accessibility
- `about/` - Project information
- `use_cases/` - Application use cases

## Features Walkthrough

### Splash Screen
- 3-second animated intro
- Navigates to onboarding

### Onboarding (3 pages)
1. "Communicate Without Barriers"
2. "Translate Indian Sign Language"
3. "Connect Through Video Calls"

### Home Dashboard
- Greeting with user name
- Real-time translation hero card
- AI engine status
- Quick action cards

### Live Translation
- Mock camera interface
- Gesture recognition simulation
- Confidence indicators
- Translation history

### Video Call
- Mock call UI
- Real-time translation overlay
- Call controls (Mic, Camera, Speaker, ISL Toggle)
- Call summary after ending

### History
- View all translation sessions
- Filter by type
- View detailed statistics

### Dictionary
- Browse 500+ ISL signs
- Search by name or meaning
- Filter by category
- Bilingual translations (English + Hindi)

### Profile
- User statistics
- Learning progress
- Current streak tracking
- Settings access

### Settings
- **Accessibility**: High Contrast, Large Text, Reduce Motion, Captions, Voice Output, Haptic Feedback
- **Display**: Dark Mode toggle
- **About**: Version info, Privacy, Terms

## Mock Data Overview

### User
```
Name: Aarav Sharma
Role: ISL User
Signs Learned: 127
Practice Sessions: 24
Video Calls: 18
Average Accuracy: 94%
Current Streak: 7 days
```

### ISL Signs (Sample)
- HELLO (नमस्ते)
- THANK YOU (धन्यवाद)
- YES (हाँ)
- NO (नहीं)
- HELP (मदद)
- GOOD MORNING (सुप्रभात)
- And 14+ more...

### Mock Translation Sessions
- Timestamped sessions
- Accuracy metrics
- Duration tracking
- Sign counts

## Troubleshooting

### Issue: "flutter command not found"
**Solution:**
```bash
# Add Flutter to PATH
# Windows: Edit Environment Variables
# macOS/Linux: Add to ~/.bashrc or ~/.zshrc
export PATH="$PATH:/path/to/flutter/bin"
```

### Issue: "Gradle build failed"
**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: "No devices found"
**Solution:**
```bash
flutter doctor                    # Check setup
flutter emulators --launch Pixel_5_API_31   # Launch emulator
adb devices                      # Check connected devices
```

### Issue: "Android SDK not found"
**Solution:**
```bash
flutter doctor --android-licenses
flutter doctor -v
# Install Android SDK via Android Studio
```

### Issue: "Dart version mismatch"
**Solution:**
```bash
flutter upgrade
flutter pub upgrade
```

## Building for Production

### Android APK
```bash
flutter build apk
# Output: build/app/outputs/apk/release/app-release.apk
```

### Android App Bundle
```bash
flutter build appbundle
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS IPA (macOS only)
```bash
flutter build ios
# Output: build/ios/iphoneos/Runner.ipa
```

## Development Tips

### Hot Reload
```bash
flutter run
# Press 'r' in terminal to hot reload
# Press 'R' for full restart
```

### Debug Mode
```bash
flutter run -v  # Verbose logging
```

### Performance Profiling
```bash
flutter run --profile
# Use DevTools for profiling
```

### Check Code Quality
```bash
flutter analyze              # Check for issues
flutter format lib/         # Format code
flutter test               # Run tests (when available)
```

## Future Backend Integration

The app is designed for easy backend integration:

### Replace Mock Services:
1. **Gesture Recognition:**
   - Replace `MockGestureRecognitionService`
   - With real MediaPipe/ML Kit integration

2. **Video Calls:**
   - Replace `MockVideoCallService`
   - With WebRTC implementation

3. **Data:**
   - Replace `MockDataRepository`
   - With Firebase/REST API calls

### No Changes Needed to:
- UI components
- Theme system
- Navigation flow
- Models (mostly)

## Performance Optimization Done

✅ Const widgets throughout  
✅ ListView.builder for lists  
✅ Proper controller disposal  
✅ Minimal rebuilds  
✅ IndexedStack for navigation  

## Accessibility Features Implemented

✅ High contrast mode  
✅ Large text scaling  
✅ Reduce motion support  
✅ Semantic labels  
✅ Screen reader friendly  
✅ Color + icon communication  
✅ Voice output support  

## Color Scheme

**Light Theme:**
- Primary: `#0066FF` (Blue)
- Secondary: `#22C55E` (Green)
- Error: `#EF4444` (Red)
- Background: `#FAFAFA` (Off-white)

**Dark Theme:**
- Primary: `#0066FF` (Blue)
- Secondary: `#22C55E` (Green)
- Error: `#EF4444` (Red)
- Background: `#0F0F0F` (Near black)

## Typography

**Font:** Roboto (Google Fonts)
**Sizes:**
- Display Large: 32px
- Headline Large: 20px
- Title Large: 16px
- Body Large: 16px
- Label Small: 12px

## Support & Contact

For issues or questions:
1. Check the README.md
2. Review SETUP_GUIDE.md (this file)
3. Check Flutter documentation: https://flutter.dev/docs

## Next Steps

1. ✅ Install Flutter
2. ✅ Run `flutter pub get`
3. ✅ Start emulator or connect device
4. ✅ Run `flutter run`
5. 🎉 Enjoy the app!

---

**ISL Translate v1.0.0** - Built with Flutter ❤️
