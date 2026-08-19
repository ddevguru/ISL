# ISL Translate - Real-Time Indian Sign Language Translation for Video Calls

A professional Flutter mobile application for real-time Indian Sign Language (ISL) translation powered by AI.

## Features

### Core Features
- **Real-Time ISL Translation**: Convert hand gestures to text instantly
- **Video Call Integration**: Enable ISL translation during video calls
- **Text-to-Speech**: Automatic voice output for translated text
- **ISL Dictionary**: Browse 500+ supported Indian Sign Language signs
- **Practice Mode**: Learn and practice ISL signs
- **Translation History**: Track all past translation sessions
- **Accessibility First**: Built-in support for accessibility features

### User Flows
1. **Splash Screen** - Animated introduction
2. **Onboarding** - 3-step guide for new users
3. **Home Dashboard** - Main interface with quick actions
4. **Live Translation** - Real-time ISL recognition interface
5. **Video Calls** - Professional video call UI with ISL translation overlay
6. **History & Analytics** - View past sessions and statistics
7. **Dictionary** - Browse and search ISL signs by category
8. **Profile & Settings** - User preferences and accessibility options

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app/
│   ├── app.dart             # App navigation
│   └── theme.dart           # Material 3 theme system
├── core/
│   └── widgets/             # Reusable UI components
│       ├── buttons.dart
│       ├── cards.dart
│       └── utils.dart
├── data/
│   ├── models/
│   │   └── models.dart      # Data models
│   ├── mock/
│   │   └── mock_data.dart   # Mock data repository
│   └── services/            # Mock services
│       ├── mock_gesture_service.dart
│       └── mock_video_call_service.dart
└── features/
    ├── splash/
    ├── onboarding/
    ├── home/
    ├── translation/
    ├── video_call/
    ├── call_summary/
    ├── history/
    ├── dictionary/
    ├── profile/
    ├── settings/
    ├── about/
    └── use_cases/
```

## Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / Xcode (for emulators)

### Installation

1. **Clone/Navigate to project**
```bash
cd c:\sign_detection
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

### Build for Production

Android:
```bash
flutter build apk
```

iOS:
```bash
flutter build ios
```

## Architecture

### Design Pattern: Clean Architecture
- **Data Layer**: Mock data repositories and services
- **Domain Layer**: Models and entities
- **Presentation Layer**: UI screens and widgets

### Mock Services
The app uses mock services for simulation:
- `MockGestureRecognitionService`: Simulates AI gesture recognition
- `MockVideoCallService`: Simulates video call states
- `MockDataRepository`: Provides sample data

### Future Backend Integration
The architecture is designed for easy backend integration:
1. Replace `MockGestureRecognitionService` with `ApiGestureRecognitionService`
2. Replace `MockVideoCallService` with real WebRTC implementation
3. Replace `MockDataRepository` with `ApiDataRepository`

## UI/UX Highlights

### Design System
- **Colors**: Professional blue/navy primary with green accents
- **Typography**: Google Fonts (Roboto)
- **Components**: Glass-morphism cards, smooth animations
- **Dark Mode**: Full dark theme support
- **Accessibility**: High contrast options, large text, reduced motion

### Animations
- Page transitions with FadeInUp
- AI scanning animation
- Loading indicators
- Smooth button interactions
- Translation appearance animation

### Responsive Design
- Works on phones, tablets, and landscape
- Uses MediaQuery and LayoutBuilder
- No hardcoded sizes
- Proper SafeArea handling

## Mock Data

The app includes comprehensive mock data:

### Users
- Default user: Aarav Sharma (ISL User)
- Statistics: 127 signs learned, 94% accuracy, 7-day streak

### ISL Signs
- 20 common signs (Hello, Thank You, Help, etc.)
- Categories: Greetings, Common Words, Emergency, Education, Healthcare, Technology
- Bilingual translations (English + Hindi)

### Translation Sessions
- Mock history with timestamps
- Accuracy metrics
- Duration tracking

### Video Calls
- Mock call history
- Participant information
- Translation statistics

## Technology Stack

### Flutter & Dart
- Material 3 design
- Async/await for operations
- Stream builders for real-time updates

### Key Packages
- `google_fonts`: Custom typography
- `animate_do`: Page transitions and animations
- `intl`: Date/time formatting
- `fl_chart`: Charts for statistics (expandable)
- `uuid`: Unique ID generation

## Screens Overview

### 1. Splash Screen
- Animated logo with gradient
- 3-second delay before onboarding
- Professional branding

### 2. Onboarding (3 pages)
- Communication without barriers
- ISL translation process
- Video call connectivity
- Skip and Next functionality

### 3. Home Dashboard
- Greeting with user name
- Hero translation card
- AI engine status
- Quick action grid (4 cards)

### 4. Live Translation
- Mock camera preview
- Real-time gesture recognition simulation
- Translation display with confidence
- Hindi translation support
- Translation history panel

### 5. Video Call
- Professional call UI (inspired by Google Meet)
- Remote participant display
- Local participant preview
- Call controls: Mic, Camera, Speaker, Screen Share, ISL Translation
- Translation overlay during calls
- Call summary after ending

### 6. Translation History
- Chronological list of sessions
- Type badges (Video Call, Live Translation, Practice)
- Accuracy metrics
- Modal details view

### 7. ISL Dictionary
- Category filter
- Search functionality
- Grid view of signs
- Sign detail modal
- Bilingual translations

### 8. Profile
- User avatar with gradient
- Statistics cards
- Learning progress
- Streak tracking
- Settings access

### 9. Settings
- Accessibility: High Contrast, Large Text, Reduce Motion, Captions, Voice Output, Haptic Feedback
- Display: Dark Mode
- About: Version, Privacy, Terms

### 10. About Project
- Project overview
- Key features list
- Technology stack
- Target applications
- Project statistics

## Accessibility Features

Built-in accessibility support:
- ✅ High contrast mode
- ✅ Large text scaling (up to 2x)
- ✅ Reduce motion/animations
- ✅ Captions support
- ✅ Voice output
- ✅ Haptic feedback
- ✅ Semantic labels
- ✅ Screen reader friendly
- ✅ Color + icon communication (not color alone)

## Performance Optimization

- Const widgets throughout
- ListView.builder for long lists
- Proper controller disposal
- IndexedStack for tab navigation
- SingleChildScrollView with proper constraints

## Code Quality

- No hardcoded strings (theme colors used)
- Reusable components (buttons, cards, widgets)
- Consistent naming conventions
- Proper imports organization
- Error handling with SnackBars

## Testing

The app includes mock data ready for UI testing:
```dart
final mockData = MockDataRepository();
final signs = mockData.getAllSigns();
final history = mockData.getTranslationHistory();
```

## Future Enhancements

### Backend Integration
- Connect to real gesture recognition API
- Integrate WebRTC for video calls
- Database sync for history
- User authentication

### AI/ML Features
- Real MediaPipe integration
- CNN/LSTM/Transformer models
- Live camera feed processing
- Confidence scoring improvements

### Additional Features
- Favorites/bookmarks for signs
- User statistics dashboard
- Offline mode
- Multi-language support
- Community features
- Sign language tutorials

## Troubleshooting

### Dependencies Issues
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Build Issues
```bash
flutter doctor
flutter doctor -v
```

### Run on Specific Device
```bash
flutter devices
flutter run -d <device_id>
```

## Contributing

This is a B.E. final-year project. All code is modular and ready for team collaboration.

## License

Educational Project - ISL Translate

## Contact & Support

For issues or questions about this Flutter frontend, refer to the project documentation.

---

**Built with Flutter** ✨  
**ISL Translate v1.0.0**
