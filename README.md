# ScoreKeep

> The ultimate game score tracker for all your gaming sessions

A Flutter app for creating, managing, and tracking scores for your games. Works for cards, board games, party games - whatever you're playing. Keep score easily and check back on past sessions whenever you want.

---

## Screenshots

<p align="center">
  <img src="https://raw.githubusercontent.com/Modexanderson/scorekeep/master/assets/images/1.png" width="250" />
  <img src="https://raw.githubusercontent.com/Modexanderson/scorekeep/master/assets/images/2.png" width="250" />
  <img src="https://raw.githubusercontent.com/Modexanderson/scorekeep/master/assets/images/3.png" width="250" />
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/Modexanderson/scorekeep/master/assets/images/4.png" width="250" />
  <img src="https://raw.githubusercontent.com/Modexanderson/scorekeep/master/assets/images/5.png" width="250" />
</p>

---

## Features

- **Game History** - View and manage past game sessions with full details
- **Dark Mode** - Switch between light and dark themes instantly
- **Local Storage** - All sessions saved locally, no internet required
- **Undo Delete** - Accidentally deleted a game? Undo it right away
- **Smooth Animations** - Clean transitions and UI interactions
- **Pull to Refresh** - Easy list updates with a simple swipe
- **Haptic Feedback** - Tactile responses for better user experience
- **Firebase Analytics** - Track usage patterns and improve the app

---

## Tech Stack

- **Flutter** 3.x
- **Dart** 3.x
- **Firebase Analytics** - User analytics
- **Firebase Crashlytics** - Error tracking
- **Shared Preferences** - Local data storage
- **Upgrader** - Force update mechanism

---

## Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / VS Code
- Firebase project (for analytics)

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/modexanderson/scorekeep.git
cd scorekeep
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Setup Firebase**

- Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
- Add Android/iOS apps to your project
- Download `google-services.json` (Android) and place it in `android/app/`
- Download `GoogleService-Info.plist` (iOS) and place it in `ios/Runner/`

4. **Run the app**

```bash
flutter run
```

---

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── pages/
│   ├── home_page.dart       # Main screen with game list
│   ├── create_game_page.dart # Create new game session
│   └── game_session_page.dart # Active game scoring
├── services/
│   ├── storage_service.dart  # Local storage handling
│   └── firebase_service.dart # Analytics & crashlytics
├── theme/
│   └── app_theme.dart       # App theming
└── widgets/
    ├── game_card.dart       # Game list item
    └── player_card.dart     # Player score card
```

---

## Building for Release

### Android

1. **Create a keystore** (if you don't have one)

```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

2. **Create `android/key.properties`**

```properties
storePassword=<your-password>
keyPassword=<your-password>
keyAlias=key
storeFile=<path-to-your-keystore>
```

3. **Build the APK**

```bash
flutter build apk --release
```

4. **Build App Bundle** (for Play Store)

```bash
flutter build appbundle --release
```

### iOS

1. **Open Xcode**

```bash
open ios/Runner.xcworkspace
```

2. **Configure signing** in Xcode
3. **Build**

```bash
flutter build ios --release
```

---

## Configuration

### Firebase Setup

The app uses Firebase for analytics and crash reporting. Configuration files are already set up in:

- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

To use your own Firebase project, replace these files with your own.

### Theme Customization

Modify `lib/theme/app_theme.dart` to customize colors, fonts, and styles:

```dart
static final lightTheme = ThemeData(
  primaryColor: Colors.blue,
  // ... customize here
);
```

---

## Features in Development

- [ ] Cloud sync across devices
- [ ] Game templates
- [ ] Export game history to CSV
- [ ] Multiplayer scoring over network
- [ ] Timer integration for timed games
- [ ] Statistics and charts

---

## Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Contact

**Mordecai**

- GitHub: [@Modexanderson](https://github.com/Modexanderson)
- Project Link: [https://github.com/Modexanderson/scorekeep](https://github.com/Modexanderson/scorekeep)

---

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All contributors who help improve this project

---

Made with ❤️ using Flutter