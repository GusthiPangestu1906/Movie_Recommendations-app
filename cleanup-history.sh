#!/bin/bash
# 🔐 Git History Cleanup Script
# Menghapus credentials dari git history TANPA mengubah key yang sekarang
# Script ini menggunakan git-filter-repo untuk rewrite history

set -e

echo "═══════════════════════════════════════════════════════════"
echo "🔐 GIT HISTORY CLEANUP - Remove Credentials from History"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "⚠️  WARNING: Script ini akan:"
echo "   • Rewrite seluruh git history"
echo "   • Menghapus credentials dari OLD commits"
echo "   • File saat ini TIDAK berubah (sudah aman)"
echo "   • Semua orang harus re-clone atau git reset"
echo ""
read -p "Lanjutkan? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

echo ""
echo "Step 1: Checking git-filter-repo..."
if ! command -v git-filter-repo &> /dev/null; then
    echo "📦 Installing git-filter-repo..."
    pip install git-filter-repo
fi

echo ""
echo "Step 2: Creating backup..."
BACKUP_DIR="../Movie_Recommendations-app.backup.$(date +%s)"
cp -r . "$BACKUP_DIR"
echo "✅ Backup created at: $BACKUP_DIR"

echo ""
echo "Step 3: Cleaning git history..."
echo "   - Removing Firebase IDs: 1:REDACTED_SENDER_ID:*"
echo "   - Removing Project ID: REDACTED_PROJECT_ID"
echo "   - Removing App IDs: *REDACTED_APP_ID"
echo ""

# Create replacement patterns file
cat > /tmp/redactions.txt << 'EOF'
1:REDACTED_SENDER_ID:web:REDACTED_APP_ID==>REDACTED_WEB_APP_ID
REDACTED_ANDROID_APP_ID==>REDACTED_ANDROID_APP_ID
REDACTED_APP_ID==>REDACTED_APP_ID
REDACTED_APP_ID==>REDACTED_APP_ID
REDACTED_SENDER_ID==>REDACTED_SENDER_ID
REDACTED_PROJECT_ID==>REDACTED_PROJECT_ID
REDACTED_PROJECT_ID.firebaseapp.com==>REDACTED_AUTH_DOMAIN
REDACTED_PROJECT_ID.firebasestorage.app==>REDACTED_STORAGE_BUCKET
EOF

# Run git-filter-repo
git filter-repo --replace-text /tmp/redactions.txt --force

echo ""
echo "✅ History cleaned successfully!"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📌 NEXT STEPS:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "1. Verify perubahan di history (optional):"
echo "   git log --all --oneline | head -20"
echo ""
echo "2. Force push ke GitHub:"
echo "   git push origin --force --all"
echo "   git push origin --force --tags"
echo ""
echo "3. Inform team members (IMPORTANT):"
echo "   • Old local clones akan error"
echo "   • They must: git clone [fresh]"
echo "   • Or: git fetch origin && git reset --hard origin/main"
echo ""
echo "4. Backup tersimpan di:"
echo "   $BACKUP_DIR"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
