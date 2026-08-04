#!/bin/bash

# --- CONFIGURATION ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🔍 Menjalankan Pemeriksaan Keamanan Ketat...${NC}"

# 1. Cek apakah file .env tidak sengaja masuk ke staging
STAGED_ENV=$(git diff --cached --name-only | grep -E "\.env$")
if [ ! -z "$STAGED_ENV" ]; then
    echo -e "${RED}❌ ERROR: Anda mencoba meng-commit file .env ($STAGED_ENV)!${NC}"
    echo -e "${YELLOW}Gunakan 'git rm --cached .env' untuk mengeluarkannya.${NC}"
    exit 1
fi

# 2. Cek Hardcoded Secrets (Pola Manusiawi)
# Mencari: defaultValue: '...', apiKey = '...', secret: "..."
# Mengecualikan: String kosong ('') atau variabel
SUSPICIOUS_PATTERNS=(
    "defaultValue:\s*['\"][^'\"]+['\"]"          # defaultValue dengan isi (seperti Haleluyah1976)
    "(apiKey|api_key|secret|token|password)\s*[:=]\s*['\"][^'\"]+['\"]" # Assignment rahasia
    "api_key=[a-zA-Z0-9]{10,}"                   # API key dalam URL string
)

FAILED=0
for PATTERN in "${SUSPICIOUS_PATTERNS[@]}"; do
    # Scan hanya pada file .dart yang di-stage (staged files)
    MATCHES=$(git diff --cached --name-only | grep "\.dart$" | xargs grep -E "$PATTERN" 2>/dev/null)

    if [ ! -z "$MATCHES" ]; then
        echo -e "${RED}❌ ERROR: Ditemukan potensi Hardcoded Secret!${NC}"
        echo -e "${YELLOW}Pola: $PATTERN${NC}"
        echo -e "$MATCHES"
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    echo -e "${RED}🚨 Commit ditolak. Bersihkan rahasia sebelum commit kembali.${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Keamanan kode lolos verifikasi.${NC}"
fi

exit 0
