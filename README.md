# 🎬 Movie Universe - Dual Experience Discovery App
[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Authentication-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![TMDB](https://img.shields.io/badge/TMDb-API-01d277?style=for-the-badge&logo=themoviedatabase&logoColor=white)](https://www.themoviedb.org)

**Movie Universe** is a premium mobile application that offers a dual-universe experience for cinema enthusiasts and TV series fans. Built with Flutter and powered by the TMDb API, it provides a seamless and immersive way to discover, track, and explore the vast world of entertainment.

---

## 🌌 Core Features (The Dual Universe)

*   **🎨 Personalized Profiles**: Features a modern **Avatar Picker** using the artistic **Lorelei** style from DiceBear. Users can choose from a curated set of professional avatars that are synchronized across devices via Firebase Auth.
*   **🔗 Smart Streaming Integration**: Dynamic "Watch Now" buttons that intelligently link to **Netflix** for movies and **WeTV** for dramas/TV shows, ensuring users always find the right platform.
*   **⚡ Universe Switching**: Seamlessly toggle between **Movie Universe** and **Drama Universe**. The entire app interface and recommendation engine adapt instantly to your selected mode.
*   **🔐 Secure Authentication**: Integrated with **Firebase Authentication** and **Firestore**, providing a robust and personalized experience with real-time user profiles and cloud-synced favorites/history.
*   **🌟 Premium Star Profiles**: Explore in-depth actor biographies with HD visuals, birth details, and global popularity rankings.
*   **✅ Verified Filmography**: A sophisticated ID-matching system ensures that filmographies are 100% accurate, allowing users to discover every verified project of their favorite stars.
*   **🔍 Global Cross-Search**: A powerful, debounced search engine that fetches results locally from your favorites and globally from the entire TMDb database simultaneously.
*   **🚀 Performance Optimized**: Features **Infinite Scrolling (Lazy Loading)** across all lists and searches to ensure a smooth, high-speed experience even with thousands of titles.
*   **📁 Smart Organization**: Completely separate history logs and favorite collections for Movies and TV Series, keeping your profile clean and organized.

---

## 🎨 Design Philosophy
*   **Premium Dark UI**: A modern *Deep Navy* aesthetic designed for cinematic immersion.
*   **Glassmorphism**: Elegant translucent UI elements with frosted glass effects for a high-end feel.
*   **Adaptive Layout**: Fully responsive design that maintains its integrity across various screen sizes and resolutions.

---

## 🛠️ Tech Stack
- **Framework**: Flutter (Dart)
- **Backend**: Firebase Authentication
- **State Management**: Provider (ChangeNotifier with ProxyProvider)
- **Data Source**: The Movie Database (TMDb) API
- **Image Handling**: Cached Network Image & Flutter SVG
- **Local Storage**: Shared Preferences (Offline Persistence)

---

## ⚙️ Installation & Setup

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/GusthiPangestu1906/Movie_Recommendations-app.git
    ```
2.  **Configure Firebase**
    - Install the Firebase CLI and FlutterFire CLI.
    - Run `flutterfire configure` to sync your local environment with your Firebase project.
3.  **Install Dependencies**
    ```bash
    flutter pub get
    ```
4.  **Run the Application**
    ```bash
    flutter run --release
    ```

---

## 📦 Release
To generate a production-ready APK, use:
```bash
flutter build apk --release
```

---

## 👤 Lead Developer
**Gusthi Pangestu**  
*Full-stack Flutter Developer passionate about high-performance mobile experiences.*

---
© 2026 Movie Universe. All rights reserved.
