# ⚡ Quick Reference: Performance Optimization Commands

## 🚀 Deployment Quick Guide

```bash
# Step 1: Clean & Build
flutter clean
flutter build web --release

# Step 2: Test Locally
firebase serve --hosting
# Open: http://localhost:5000

# Step 3: Deploy
firebase deploy --only hosting

# Step 4: Check
# Open: https://nyxdex.web.app
```

---

## 🧪 Testing Checklist

### Local Testing:
```bash
# Terminal 1: Serve locally
firebase serve --hosting

# Terminal 2: Run in Chrome (DevTools open)
# 1. DevTools > Application > Service Workers
#    ✓ Verify "service-worker.js" is activated
# 2. DevTools > Application > Cache Storage
#    ✓ Check nyxdex-v1 and nyxdex-runtime-v1 caches
# 3. DevTools > Network
#    ✓ Verify caching headers in response headers
# 4. Offline test:
#    DevTools > Network > Offline
#    ✓ Page should still load (from cache)
# 5. Lighthouse audit:
#    DevTools > Lighthouse > Generate report
#    ✓ Target: 75+ score
```

### Online Testing:
```bash
# After deploying to production:
# 1. PageSpeed Insights
#    https://pagespeed.web.dev/?url=https://nyxdex.web.app

# 2. Check Web Vitals
#    Google Search Console > Core Web Vitals
#    (may take 24-48 hours to see data)

# 3. Monitor in real-time
#    Firebase Console > Performance Monitoring
```

---

## 🔍 Cache Strategy Explained

### Image/Font Caching:
```
Cache-Control: public, max-age=31536000, immutable
# Cache untuk 1 tahun, tidak perlu re-validation
# Cocok untuk assets yang tidak pernah berubah
```

### JavaScript/CSS Caching:
```
Cache-Control: public, max-age=604800
# Cache untuk 7 hari
# Otomatis di-clear setelah 7 hari
```

### HTML Entry Point (index.html):
```
Cache-Control: public, max-age=3600, must-revalidate
# Cache untuk 1 jam, tapi harus di-check server
# Memastikan users mendapat update konten terbaru
```

### Service Worker:
```
Cache-Control: public, max-age=3600, must-revalidate
# Cache untuk 1 jam, tapi harus di-check server
# Otomatis update setiap jam jika ada perubahan
```

---

## 🆘 Troubleshooting

### Service Worker Not Registering?
```javascript
// Open DevTools Console dan cek error messages
// Common issues:
// 1. Not HTTPS (production requirement)
// 2. Wrong file path
// 3. Cache-Control headers blocking
// 4. CORS issues

// Fix: Clear site data
// DevTools > Application > Clear site data (check all)
// Reload page
```

### Still Slow After Deployment?
```bash
# 1. Run Lighthouse audit again
# 2. Check which resources are slow:
#    DevTools > Network tab > check waterfall chart
# 3. Identify bottleneck:
#    - JS bundle too large? → code splitting
#    - Images too large? → compression/WebP
#    - API calls slow? → optimize backend
# 4. Priority: FCP (rendering) > LCP (content) > TBT (interaction)
```

### Cache Not Updating?
```javascript
// If you need to force cache refresh:
// 1. Change CACHE_NAME in service-worker.js:
//    const CACHE_NAME = 'nyxdex-v2'; // was v1

// 2. Or clear all caches:
//    DevTools > Application > Cache Storage > Delete all

// 3. Reload page
```

---

## 📊 Metrics Dashboard

**Monitor These After Deployment:**

| Metric | Target | Tool | Frequency |
|--------|--------|------|-----------|
| FCP | <2.0s | PageSpeed Insights | Weekly |
| LCP | <2.5s | Google Search Console | Daily |
| CLS | <0.1 | Lighthouse | Weekly |
| TTI | <3.5s | PageSpeed Insights | Weekly |
| Lighthouse | 75+ | DevTools | Weekly |

---

## 🔐 Security Headers Verification

```bash
# Check headers via curl:
curl -I https://nyxdex.web.app

# Expected response headers:
# X-Frame-Options: SAMEORIGIN
# X-Content-Type-Options: nosniff
# X-XSS-Protection: 1; mode=block
# Referrer-Policy: strict-origin-when-cross-origin
```

---

## 📝 Update Service Worker Version

When you update the app and need to clear old caches:

```javascript
// In web/service-worker.js:
// OLD: const CACHE_NAME = 'nyxdex-v1';
// NEW: const CACHE_NAME = 'nyxdex-v2';

// OLD: const RUNTIME_CACHE = 'nyxdex-runtime-v1';
// NEW: const RUNTIME_CACHE = 'nyxdex-runtime-v2';
```

Then redeploy:
```bash
flutter build web --release
firebase deploy --only hosting
```

---

## ✅ Success Checklist

After deployment, verify:

- [ ] Service Worker registered (DevTools > Application)
- [ ] Cache Storage populated (DevTools > Cache Storage)
- [ ] Offline mode works (DevTools > Network > Offline)
- [ ] PageSpeed score 75+ (PageSpeed Insights)
- [ ] FCP < 2.0s (Lighthouse audit)
- [ ] LCP < 2.5s (Lighthouse audit)
- [ ] No console errors (DevTools > Console)
- [ ] All security headers present (curl -I)

---

## 🎯 Performance Goals

```
✅ First visit:  4.2s → 2.0s (52% faster)
✅ Repeat visit: 4.2s → 0.5-1.0s (75-88% faster)
✅ Offline:      ❌ → ✅ (now works!)
✅ Security:     Baseline → Strong
```

---

**Last Updated:** 2026-08-10  
**Version:** 1.0
