#!/bin/bash

# --- SCRIPT KEAMANAN LOKAL (PRE-COMMIT) ---
# Memastikan tidak ada data sensitif yang masuk ke commit

echo "🔍 Menjalankan pemeriksaan keamanan pra-commit..."

# 1. Cek apakah ada file .env yang masuk ke staging area
STAGED_ENV=$(git diff --cached --name-only | grep -E "\.env$|google-services\.json$" || true)

if [ -n "$STAGED_ENV" ]; then
  echo "❌ KESALAHAN: Anda mencoba men-commit file sensitif:"
  echo "$STAGED_ENV"
  echo "Gunakan 'git rm --cached <file>' dan pastikan masuk ke .gitignore."
  exit 1
fi

# 2. Cek apakah ada kata kunci sensitif (API Keys) yang tidak sengaja tertulis di kode
# Mencari pola umum API Key (panjang & random) di file yang akan di-commit
FORBIDDEN_KEYWORDS="AIza\|sk-\|TMDB_API_KEY\|FIREBASE_KEY"
LEAK_DETECTED=$(git diff --cached | grep -i "$FORBIDDEN_KEYWORDS" || true)

if [ -n "$LEAK_DETECTED" ]; then
  echo "⚠️ PERINGATAN: Ditemukan teks yang mirip API Key di dalam kode Anda!"
  echo "Pastikan Anda menggunakan .env atau --dart-define, jangan menulis API Key langsung."
  # Kita beri pilihan tetap lanjut atau batal (exit 1 untuk batal)
  # exit 1
fi

echo "✅ Pemeriksaan selesai. Melanjutkan commit..."
exit 0
