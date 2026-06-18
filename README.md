# 🎬 My Movies - FilmKu App
### Projek UAS Workshop Pemrograman Perangkat Bergerak

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![TMDb](https://img.shields.io/badge/TMDb-API-01d277?style=for-the-badge&logo=themoviedatabase&logoColor=white)

**My Movies** (FilmKu) adalah aplikasi katalog film modern yang dibangun menggunakan Flutter. Aplikasi ini dirancang untuk memberikan pengalaman eksplorasi film yang intuitif dengan integrasi langsung ke database TMDb, sistem rekomendasi cerdas, dan fitur streaming eksternal.

---

## 🚀 Fitur Utama

*   **Premium Dark UI**: Antarmuka modern dengan mode gelap (deep navy) yang elegan dan nyaman di mata.
*   **Smart Recommendation (For You)**: Sistem rekomendasi otomatis berdasarkan daftar film yang disukai (favorit) pengguna.
*   **Advanced Multi-Genre Filter**: Memungkinkan pengguna mencari film dengan mengombinasikan berbagai genre sekaligus (misal: Action + Sci-Fi).
*   **Infinite Scrolling**: Loading data yang mulus saat men-scroll daftar film (Pagination) untuk performa yang optimal.
*   **Netflix Integration**: Tombol khusus "Watch on Netflix" yang langsung mengarahkan pengguna ke aplikasi Netflix untuk menonton film terkait.
*   **Trailer Playback**: Integrasi YouTube untuk memutar trailer film secara langsung.
*   **Dynamic Age Rating**: Menampilkan klasifikasi usia film secara akurat (General, 13+, For 18+, dsb).
*   **Favorite Management**: Simpan film favorit Anda secara lokal menggunakan `shared_preferences`.

---

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Bahasa**: Dart
- **State Management**: Provider
- **Penyimpanan Lokal**: Shared Preferences
- **API**: The Movie Database (TMDb)
- **Library Utama**:
  - `http`: Untuk request data dari API.
  - `cached_network_image`: Untuk manajemen cache gambar poster film.
  - `url_launcher`: Untuk membuka link eksternal (YouTube & Netflix).
  - `intl`: Untuk manajemen format tanggal dan filter waktu.

---

## 📂 Struktur Proyek

```text
lib/
├── models/         # Model data (Movie, Cast)
├── providers/      # State management (MovieProvider)
├── services/       # Komunikasi API (ApiService)
├── pages/          # Tampilan antar muka (Home, Detail, Login, dsb)
└── main.dart       # Entry point aplikasi
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
Aplikasi dilengkapi dengan halaman login sederhana untuk demonstrasi:
- **Username**: `admin`
- **Password**: `admin`
- *(Atau gunakan fitur **Login as Guest** untuk akses instan)*

---

## 👤 Developer
**Gusthi Pangestu**  
Mahasiswa Workshop Pemrograman Perangkat Bergerak

---
*Proyek ini dibuat untuk memenuhi tugas akhir (UAS) mata kuliah Workshop Pemrograman Perangkat Bergerak.*
