# 🎬 My Movies - FilmKu App
### Projek UAS Workshop Pemrograman Perangkat Bergerak

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![TMDb](https://img.shields.io/badge/TMDb-API-01d277?style=for-the-badge&logo=themoviedatabase&logoColor=white)

**My Movies** (FilmKu) adalah aplikasi katalog film modern yang dibangun menggunakan Flutter. Aplikasi ini dirancang untuk memberikan pengalaman eksplorasi film yang intuitif dengan integrasi langsung ke database TMDb, sistem rekomendasi cerdas, dan manajemen riwayat tontonan pribadi yang dioptimalkan untuk performa tinggi.

---

## 🚀 Fitur Utama

*   **⚡ High Performance & API Caching**: Implementasi sistem *in-memory caching* untuk mempercepat waktu loading data dan mengurangi beban jaringan secara signifikan.
*   **Smart Search Suggestions (Auto-Guess)**: Sistem pencarian cerdas yang menampilkan hasil secara *real-time* saat pengguna mengetik (Autocomplete) dengan optimasi *debounce* untuk efisiensi API.
*   **Manual Watch History Journal**: Pengguna dapat mencatat riwayat tontonan secara manual dengan memilih tanggal menonton melalui *Date Picker* (Kalender).
*   **Smart Recommendation (For You)**: Sistem rekomendasi yang dipersonalisasi berdasarkan daftar **Favorit** dan **Riwayat Tontonan** pengguna.
*   **Watch Status Indicator**: Label visual **"WATCHED"** pada film yang sudah pernah ditonton untuk memudahkan identifikasi dan mencegah input ganda.
*   **Advanced Multi-Genre Filter**: Mencari film dengan kombinasi berbagai genre (misal: Action + Sci-Fi) untuk hasil yang lebih spesifik.
*   **Netflix & Trailer Integration**: Akses cepat untuk menonton film di Netflix dan memutar trailer YouTube langsung dari aplikasi.
*   **Premium Dark UI**: Antarmuka modern bertema *Deep Navy* yang elegan dengan navigasi *Bottom Navigation Bar* yang intuitif.

---

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Bahasa**: Dart
- **State Management**: Provider (dengan `ChangeNotifierProxyProvider` untuk sinkronisasi antar-data)
- **Penyimpanan Lokal**: Shared Preferences (untuk persistensi Favorit dan Riwayat)
- **API**: The Movie Database (TMDb)
- **Keamanan Build**: ProGuard & R8 (untuk optimasi dan keamanan file APK Release)

---

## 📂 Struktur Proyek

```text
lib/
├── models/         # Model data (Movie, Cast)
├── providers/      # State management (MovieProvider, HistoryProvider)
├── services/       # Komunikasi API & Caching (ApiService)
├── pages/          # UI Pages (Home, Detail, Login, Search, History, Favorite)
└── main.dart       # Entry point & Provider Setup
```

---

## ⚙️ Cara Menjalankan Proyek

1. **Clone Repositori**
   ```bash
   git clone https://github.com/GusthiPangestu1906/Movie_Recommendations-app.git
   ```

2. **Masuk ke Direktori**
   ```bash
   cd Movie_Recommendations-app
   ```

3. **Install Dependensi**
   ```bash
   flutter pub get
   ```

4. **Jalankan Aplikasi**
   ```bash
   flutter run
   ```

---

## 🔑 Kredensial Akses
- **Username**: `admin`
- **Password**: `admin`
- *(Atau gunakan fitur **Login as Guest** untuk akses instan)*

---

## 👤 Developer
**Gusthi Pangestu**  
Mahasiswa Workshop Pemrograman Perangkat Bergerak

---
*Proyek ini dibuat untuk memenuhi tugas akhir (UAS) mata kuliah Workshop Pemrograman Perangkat Bergerak.*
