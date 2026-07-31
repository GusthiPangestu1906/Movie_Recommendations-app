## 🛡️ Security Checklist
- [ ] **No Hardcoded Secrets**: Saya sudah memastikan tidak ada API Key atau Token yang tertulis langsung di kode (semua menggunakan `.env` atau `--dart-define`).
- [ ] **Environment Audit**: Saya sudah memeriksa bahwa file `.env` tidak masuk dalam daftar file yang akan di-commit.
- [ ] **Debug Logs**: Saya sudah menghapus perintah `print()` atau log debug yang berisi data sensitif user.
- [ ] **Firebase Rules**: Jika ada perubahan database, saya sudah memastikan Security Rules tidak dibuat menjadi `allow read, write: if true;`.

## 🚀 Quality Checklist
- [ ] **Formatting**: Saya sudah menjalankan `dart format .` agar kode rapi.
- [ ] **Static Analysis**: `flutter analyze` tidak menunjukkan error atau warning.
- [ ] **Testing**: Semua unit test (jika ada) berhasil dijalankan.

## 📝 Deskripsi Perubahan
*Tuliskan secara singkat apa yang Anda ubah atau tambahkan di sini.*

## 📸 Screenshots (Jika ada perubahan UI)
*Tempelkan screenshot di sini.*
