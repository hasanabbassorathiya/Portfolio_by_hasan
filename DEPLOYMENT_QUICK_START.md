# ⚡ Quick Deployment Guide

## 🚀 Deploy in 5 Minutes

### Step 1: Get Firebase Service Account Key (2 min)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `hasan-abbas-portfolio`
3. Go to **Project Settings** → **Service Accounts**
4. Click **Generate New Private Key**
5. Download the JSON file

### Step 2: Set GitHub Secrets (2 min)

**Option A: Using Script (Recommended)**
```bash
./scripts/setup-firebase-secrets.sh
```

**Option B: Manual Setup**
1. Go to GitHub repo → **Settings** → **Secrets and variables** → **Actions**
2. Add these secrets:
   - `FIREBASE_SERVICE_ACCOUNT` - Paste entire JSON file content
   - `SUPABASE_URL` - Your Supabase URL
   - `SUPABASE_ANON_KEY` - Your Supabase anon key

### Step 3: Push to Main (1 min)

```bash
git add .
git commit -m "Setup Firebase deployment"
git push origin main
```

**That's it!** 🎉 GitHub Actions will automatically:
- Build your Flutter web app
- Deploy to Firebase Hosting
- Make your site live!

---

## 📍 Your Site URLs

After deployment, your site will be available at:
- `https://hasan-abbas-portfolio.web.app`
- `https://hasan-abbas-portfolio.firebaseapp.com`

---

## 🧪 Test Locally First

Before pushing, test deployment locally:

```bash
./scripts/deploy-local.sh
```

This will:
1. Build the Flutter web app
2. Deploy to Firebase Hosting
3. Show you the live URL

---

## 📊 Monitor Deployment

1. **GitHub Actions**: `https://github.com/YOUR_USERNAME/YOUR_REPO/actions`
2. **Firebase Console**: `https://console.firebase.google.com/project/hasan-abbas-portfolio/hosting`

---

## ⚠️ Troubleshooting

### Build Fails
- Check GitHub Actions logs
- Verify Flutter version compatibility
- Ensure all dependencies are in `pubspec.yaml`

### Deployment Fails
- Verify `FIREBASE_SERVICE_ACCOUNT` secret is set correctly
- Check Firebase project ID matches `.firebaserc`
- Ensure Firebase Hosting is enabled

### Environment Variables Not Working
- Secrets must be set in GitHub Settings
- Variables are injected at build time
- Check secret names match exactly

---

## 📚 Full Documentation

For detailed information, see:
- `FIREBASE_DEPLOYMENT_GUIDE.md` - Complete deployment guide
- `DEPLOYMENT_READINESS.md` - Pre-deployment checklist

---

**Ready?** Push to `main` and watch it deploy! 🚀

