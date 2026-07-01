# Movie Recommendations App

A Flutter-based mobile application for discovering and getting recommendations for movies and TV shows. This app is built to demonstrate modern mobile development practices with Flutter.

## ✨ Features

- **Browse Movies & TV Shows**: Explore lists of popular, top-rated, and upcoming content.
- **Search**: Quickly find any movie or drama.
- **Country Filter for Dramas**: In the "Drama Universe", you can filter search results by country to easily find dramas from a specific region (e.g., Korea, Japan, China).
- **Detailed Information**: View details for each title, including synopsis, rating, and cast.
- **Watchlist**: Save movies and shows to your personal watchlist (requires login).
- **User Authentication**: Secure sign-up and login functionality using Firebase.

## 🛠️ Tech Stack

- **Framework**: Flutter
- **State Management**: Provider
- **API**: The Movie Database (TMDb) API
- **Backend**: Firebase (Authentication, Firestore for watchlist)
- **Dependencies**:
  - `http`: For making API calls.
  - `provider`: For state management.
  - `cached_network_image`: To cache network images.
  - `firebase_core`, `firebase_auth`, `cloud_firestore`: For backend services.

## 🚀 Getting Started

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/GusthiPangestu1906/Movie_Recommendations-app.git
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the app**:
    ```bash
    flutter run
    ```