# nyxdex - Cinematic Universe

A modern, high-performance Flutter application for discovering movies, dramas, and actors. This app features a clean UI, cinematic animations, and is optimized for both Mobile and Web platforms with a focus on security and best practices.

## ✨ Latest Features & Improvements

- **🎬 Cinematic Booting Page**: A premium "Android Booting" style progress bar that synchronizes with Firebase initialization for a smooth UX.
- **🛡️ DevSecOps Ready**: 
  - **Secret Scan**: Automatic detection of leaked API Keys using Gitleaks.
  - **Security Audits**: Continuous dependency vulnerability scanning via OSV-Scanner.
  - **Pre-commit Hooks**: Local guardrails to prevent accidental `.env` commits.
  - **Health Checks**: Automated asset integrity and production log verification.
- **🚀 Flutter Web 3.22+ Optimized**: Migrated to the new `flutter.loader.load()` API for faster and warning-free web initialization.
- **📱 PWA Ready**: Optimized manifest and service workers for "Add to Home Screen" support.
- **🏗️ Domain-Driven Refactor**: Migrated from a monolithic `MovieProvider` to specialized domain providers (`Movie`, `Tv`, `Search`, `Favorite`) for better maintainability.
- **🔐 Secure Architecture**: 
  - **Dual-Mode API**: Automatic switching between local `.env` (development) and Cloudflare Worker Proxy (production).
  - **API Masking**: TMDB API Key is hidden server-side using Cloudflare Workers as a secure shield.
  - **Secret Management**: Request validation using `X-App-Proxy-Secret` to prevent unauthorized proxy access.

## 🛠️ Tech Stack

- **Framework**: Flutter 3.22+ (Mobile & Web)
- **State Management**: Provider
- **Backend**: Firebase (Auth, Firestore, Hosting)
- **API**: TMDB API
- **Animations**: `flutter_animate`, `animations`, & Shimmer effect.
- **Security**: GitHub Actions, Gitleaks, OSV-Scanner.

## 🚀 Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/GusthiPangestu1906/Movie_Recommendations-app.git
   ```
2. **Setup Environment**:
   Create a `.env` file in the root directory:
   ```env
   TMDB_API_KEY=your_tmdb_key
   # Add other Firebase keys as needed
   ```
3. **Security Setup (Local)**:
   Activate the pre-commit hook to protect your secrets:
   ```bash
   # On Windows (Copy script to hooks)
   cp scripts/pre-commit-check.sh .git/hooks/pre-commit
   ```
4. **Install dependencies**:
   ```bash
   flutter pub get
   ```
5. **Run the app**:
   ```bash
   flutter run
   ```

## 🛡️ Security Workflows (CI/CD)

This project includes automated workflows to keep the code safe:
- `security-scan.yml`: Scans for hardcoded secrets and leaked files.
- `ci-quality-check.yml`: Runs linter, formatter, and unit tests.
- `dependency-security-audit.yml`: Weekly scan for package vulnerabilities.
- `secret-health-check.yml`: Verifies API connectivity.

## 🌐 Deployment

Deployment is automated via GitHub Actions to Firebase Hosting. Manual deploy:
```bash
flutter build web --release
firebase deploy --only hosting
```
