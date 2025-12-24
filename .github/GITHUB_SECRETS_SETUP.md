# GitHub Secrets Setup Guide

This guide shows you how to set up GitHub Secrets for CI/CD deployment based on your local `.env` file and Firebase service account.

## 📋 Required Secrets

### 1. Firebase Service Account

**Secret Name:** `FIREBASE_SERVICE_ACCOUNT`

**Value:** Copy the entire contents of `hasan-abbas-portfolio-ed6ec57373ed.json`

**How to set:**
1. Open `hasan-abbas-portfolio-ed6ec57373ed.json`
2. Copy the entire JSON content (all 14 lines)
3. Go to GitHub → Your Repository → Settings → Secrets and variables → Actions
4. Click "New repository secret"
5. Name: `FIREBASE_SERVICE_ACCOUNT`
6. Paste the entire JSON content
7. Click "Add secret"

**⚠️ Important:** The JSON should be a single-line or multi-line string. GitHub Secrets will handle it correctly.

### 2. Supabase Configuration

**Secret Name:** `SUPABASE_URL`

**Value:** From your `.env` file (line 2)
```
https://your-project-id.supabase.co
```

**Secret Name:** `SUPABASE_ANON_KEY`

**Value:** From your `.env` file (line 3)
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlvdXItcHJvamVjdC1pZCIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNzYzOTIzMTkwLCJleHAiOjIwNzk0OTkxOTB9.example_key_here
```

### 3. App Configuration (Optional - with defaults)

**Secret Name:** `APP_NAME`

**Value:** From your `.env` file (line 6)
```
Hasan Abbas Sorathiya
```

**Default if not set:** `Hasan Abbas Sorathiya`

---

**Secret Name:** `DEFAULT_LOCALE`

**Value:** From your `.env` file (line 7)
```
en
```

**Default if not set:** `en`

---

**Secret Name:** `SUPPORTED_LOCALES`

**Value:** From your `.env` file (line 8)
```
en,ar,fr
```

**Default if not set:** `en,ar,fr`

---

**Secret Name:** `ENABLE_ANALYTICS`

**Value:** From your `.env` file (line 11)
```
true
```

**Default if not set:** `true`

---

**Secret Name:** `ENABLE_CRASH_REPORTING`

**Value:** From your `.env` file (line 12)
```
true
```

**Default if not set:** `true`

## 🚀 Quick Setup Steps

1. **Go to GitHub Repository Settings**
   - Navigate to: `https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions`

2. **Add Each Secret**
   - Click "New repository secret"
   - Enter the name and value from the table above
   - Click "Add secret"

3. **Verify Secrets**
   - You should have at least these secrets:
     - ✅ `FIREBASE_SERVICE_ACCOUNT` (required)
     - ✅ `SUPABASE_URL` (required)
     - ✅ `SUPABASE_ANON_KEY` (required)
     - ⚙️ `APP_NAME` (optional)
     - ⚙️ `DEFAULT_LOCALE` (optional)
     - ⚙️ `SUPPORTED_LOCALES` (optional)
     - ⚙️ `ENABLE_ANALYTICS` (optional)
     - ⚙️ `ENABLE_CRASH_REPORTING` (optional)

## 📝 Secret Values Reference

Based on your current `.env` file:

| Secret Name | Value (Example) |
|------------|----------------|
| `FIREBASE_SERVICE_ACCOUNT` | Full JSON from your Firebase service account file |
| `SUPABASE_URL` | `https://your-project-id.supabase.co` |
| `SUPABASE_ANON_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (your actual key) |
| `APP_NAME` | `Your App Name` |
| `DEFAULT_LOCALE` | `en` |
| `SUPPORTED_LOCALES` | `en,ar,fr` |
| `ENABLE_ANALYTICS` | `true` |
| `ENABLE_CRASH_REPORTING` | `true` |

**⚠️ Important:** Replace the example values above with your actual values from your `.env` file and Firebase service account JSON.

## 🔒 Security Notes

- ⚠️ **Never commit** `hasan-abbas-portfolio-ed6ec57373ed.json` to git
- ⚠️ **Never commit** `.env` file to git (already in `.gitignore`)
- ✅ Use GitHub Secrets for all sensitive data
- ✅ The Firebase service account JSON should only exist as a GitHub Secret

## ✅ Verification

After setting up secrets, push to `main` branch to trigger deployment. The workflow will:
1. Use your secrets to build the app
2. Authenticate with Firebase using the service account
3. Deploy to Firebase Hosting

Check the Actions tab to verify the deployment succeeded!

