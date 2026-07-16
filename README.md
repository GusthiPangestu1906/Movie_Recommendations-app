# My Movies - Movie & Drama Discovery App

A modern, high-performance Flutter application for discovering movies, dramas, and actors. This app features a clean UI, smooth animations, and is optimized for both Mobile and Web platforms.

## ✨ Latest Updates

- **🚀 Flutter Web Support**: Now fully compatible with browsers, including a responsive "Mobile Mockup" view when accessed from a laptop or tablet.
- **📱 PWA Ready**: Can be installed on mobile devices (Add to Home Screen) for a native app experience.
- **❤️ New Favorite System**: Enhanced favorite buttons with scale animations and consistent heart icons across Movies, Dramas, and Actors.
- **🔍 Accurate Search**: Optimized search logic in `MovieProvider` with support for `originCountry` filters, specifically for the Drama Universe.
- **📐 Enhanced UI**: Improved `MovieCard` dimensions with a consistent radius of 4.
- **🍃 Lottie-Free**: Optimized performance by removing Lottie dependency in favor of native Flutter animations.
- **🔐 Firebase Integration**: Secure authentication and multi-platform initialization.

## 🛠️ Tech Stack

- **Framework**: Flutter (Mobile & Web)
- **State Management**: Provider
- **Backend**: Firebase (Auth, Firestore)
- **API**: TMDB API
- **Animations**: `flutter_animate` & Native Flutter Animations

## 🚀 Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/GusthiPangestu1906/Movie_Recommendations-app.git
   ```
2. **Setup Environment**:
   Create a `.env` file in the root directory and add your TMDB API Key:
   ```env
   TMDB_API_KEY=your_api_key_here
   ```
3. **Install dependencies**:
   ```bash
   flutter pub get
   ```
4. **Run the app**:
   - For Mobile: `flutter run`
   - For Web: `flutter run -d chrome`

## 🌐 Web Deployment

To deploy to Firebase Hosting:
```bash
flutter build web --release
firebase deploy --only hosting
```
