#!/bin/bash

# --- CONFIGURATION ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔍 Menjalankan Pemeriksaan Cepat...${NC}"

# 1. Cek apakah file .env tidak sengaja masuk ke staging
STAGED_ENV=$(git diff --cached --name-only | grep -E "\.env$")
if [ ! -z "$STAGED_ENV" ]; then
    echo -e "${RED}❌ ERROR: Anda mencoba meng-commit file .env ($STAGED_ENV)!${NC}"
    exit 1
fi

# 2. Cek file yang di-stage saja
STAGED_DART_FILES=$(git diff --cached --name-only | grep "\.dart$")

if [ -z "$STAGED_DART_FILES" ]; then
    echo -e "${GREEN}✅ Tidak ada file Dart yang berubah. Lanjut commit...${NC}"
    exit 0
fi

# 3. Jalankan Dart Format (Hanya pada file yang di-stage)
echo -e "${YELLOW}📐 Memeriksa format kode pada file yang berubah...${NC}"
FORMAT_ERROR=0
for FILE in $STAGED_DART_FILES; do
    if [ -f "$FILE" ]; then
        dart format --set-exit-if-changed "$FILE" > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ ERROR: File $FILE belum dirapikan.${NC}"
            FORMAT_ERROR=1
        fi
    fi
done

if [ $FORMAT_ERROR -eq 1 ]; then
    echo -e "${YELLOW}👉 Jalankan 'dart format .' untuk memperbaiki semua file.${NC}"
    exit 1
fi

# 4. Jalankan Flutter Analyze (Hanya jika ada perubahan signifikan)
echo -e "${YELLOW}🧪 Menjalankan analisa statis (flutter analyze)...${NC}"
# Menggunakan --no-fatal-infos agar tidak terlalu cerewet
ANALYSIS=$(flutter analyze --no-fatal-infos 2>&1)
EXIT_CODE=$?

# Jika exit code 0 ATAU output mengandung "No issues found", maka dianggap lolos.
# Ini untuk menangani bug exit code pada beberapa shell Windows.
if [ $EXIT_CODE -eq 0 ] || [[ "$ANALYSIS" == *"No issues found"* ]]; then
    echo -e "${GREEN}✅ Kode bersih dan rapi. Lanjut commit!${NC}"
    exit 0
else
    echo -e "${RED}❌ ERROR: Ditemukan masalah pada kode.${NC}"
    echo "$ANALYSIS" | grep -E "info|warning|error" | head -n 5
    echo -e "${YELLOW}... (hanya menampilkan 5 masalah pertama)${NC}"
    exit 1
fi
