# 🎬 My Movies - Dual Universe App
### Projek UAS Workshop Pemrograman Perangkat Bergerak

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![TMDb](https://img.shields.io/badge/TMDb-API-01d277?style=for-the-badge&logo=themoviedatabase&logoColor=white)

**My Movies** (FilmKu) kini hadir dengan konsep **Dual Universe**, memisahkan secara total pengalaman menonton Film dan Drama/Serial TV dalam satu aplikasi yang elegan dan profesional.

---

## 🌌 Fitur Unggulan (Dual Universe)

*   **⚡ Navigation Drawer (Hamburger Menu)**: Sistem navigasi "Garis Tiga" untuk berpindah secara mulus antara **Movie Universe** dan **Drama Universe**. Seluruh aplikasi akan beradaptasi mengikuti mode yang dipilih.
*   **🌟 Premium Actor Profiles**: Jelajahi biografi lengkap aktor/aktris idola Anda. Menampilkan informasi detail seperti tanggal lahir, tempat lahir, dan riwayat hidup dengan fitur *Read More*.
*   **✅ Strict Verified Filmography**: Daftar karya aktor yang 100% akurat. Sistem melakukan verifikasi ID ganda untuk memastikan aktor tersebut memang terdaftar resmi di setiap poster film/drama yang ditampilkan.
*   **🎭 Integrated Favorite Stars**: Simpan aktor dan aktris favorit Anda dalam galeri khusus yang dapat diakses dari Sidebar. Berlaku global baik dari konten Film maupun Drama.
*   **🔍 Context-Aware Search**: Mesin pencari cerdas yang otomatis menyesuaikan target pencarian (Film vs Drama) berdasarkan Universe yang sedang aktif.
*   **🚀 Optimized Lazy Loading**: Profil aktor memuat data biografi secara instan, sementara verifikasi riwayat filmografi berjalan cepat di latar belakang untuk pengalaman pengguna yang mulus.
*   **📁 Proper History & Favorite Separation**: Riwayat tontonan dan daftar favorit kini terkelompok rapi secara terpisah antara kategori Movie dan Drama.

---

## 🚀 Fitur Standar Utama

*   **Smart Search Suggestions**: Hasil pencarian muncul seketika (*Autocomplete*) dengan optimasi *debounce*.
*   **Advanced Filters**: Filter film berdasarkan genre dan filter drama berdasarkan negara asal (K-Drama, J-Drama, dll).
*   **Manual Watch Journal**: Catat riwayat tontonan dengan tanggal spesifik melalui kalender digital.
*   **Netflix & YouTube Integration**: Link langsung ke aplikasi Netflix dan pemutar trailer YouTube resmi.
*   **Premium Dark UI**: Antarmuka bertema *Deep Navy* yang modern dengan navigasi intuitif.

---

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider (dengan `ChangeNotifierProxyProvider`)
- **Penyimpanan Lokal**: Shared Preferences (Favorit & Riwayat)
- **API**: The Movie Database (TMDb)
- **Keamanan & Optimasi**: ProGuard & Parallel Asynchronous Processing

---

## 📂 Struktur Proyek

```text
lib/
├── models/         # Model data (Movie, Cast)
├── providers/      # Logic & State (MovieProvider, HistoryProvider)
├── services/       # Komunikasi API, Caching, & Verification (ApiService)
├── pages/          # UI: Home, Search, History, Favorite, Actor Detail, Stars Galaxy
└── main.dart       # Entry point
```

---

## ⚙️ Cara Menjalankan Proyek

1. **Clone Repositori**
   ```bash
   git clone https://github.com/GusthiPangestu1906/Movie_Recommendations-app.git
   ```
2. **Install Dependensi & Jalankan**
   ```bash
   flutter pub get
   flutter run --release
   ```

---

## 🔑 Kredensial Akses
- **Username**: `admin` | **Password**: `admin`
- *(Tersedia tombol **Login as Guest** untuk akses cepat)*

---

## 👤 Developer
**Gusthi Pangestu**  
Mahasiswa Workshop Pemrograman Perangkat Bergerak

---
*Proyek ini merupakan hasil akhir (UAS) yang mendemonstrasikan integrasi API kompleks, manajemen state tingkat lanjut, dan desain antarmuka pengguna yang profesional.*
