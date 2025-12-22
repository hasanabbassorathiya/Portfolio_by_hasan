# 🚀 Firebase Hosting Deployment Guide

This guide walks you through deploying your Flutter web app to Firebase Hosting with GitHub Actions CI/CD.

---

## 📋 Prerequisites

1. ✅ Firebase project created (`hasan-abbas-portfolio`)
2. ✅ FlutterFire CLI installed
3. ✅ GitHub repository set up
4. ✅ Firebase CLI installed locally (optional, for testing)

---

## 🔧 Setup Steps

### 1. Firebase Project Configuration

Your project is already configured:
- **Project ID**: `hasan-abbas-portfolio`
- **Firebase config**: `firebase.json` ✅
- **Project config**: `.firebaserc` ✅

### 2. Enable Firebase Hosting

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `hasan-abbas-portfolio`
3. Go to **Hosting** → **Get Started**
4. Follow the setup wizard (you can skip this if already done)

### 3. Get Firebase Service Account Key

**For GitHub Actions deployment, you need a service account:**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Project Settings** (gear icon) → **Service Accounts**
4. Click **Generate New Private Key**
5. Download the JSON file
6. **⚠️ Keep this file secure - never commit it to git!**

### 4. Configure GitHub Secrets

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions**

Add these secrets:

#### Required Secrets:

| Secret Name | Description | Example |
|------------|-------------|---------|
| `FIREBASE_SERVICE_ACCOUNT` | Content of the service account JSON file | `{"type":"service_account",...}` |
| `SUPABASE_URL` | Your Supabase project URL | `https://xxxxx.supabase.co` |
| `SUPABASE_ANON_KEY` | Your Supabase anon key | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` |

#### Optional Secrets (with defaults):

| Secret Name | Default | Description |
|------------|---------|-------------|
| `APP_NAME` | `Portfolio` | Application name |
| `DEFAULT_LOCALE` | `en` | Default locale |
| `SUPPORTED_LOCALES` | `en` | Comma-separated locales |
| `ENABLE_ANALYTICS` | `true` | Enable analytics |
| `ENABLE_CRASH_REPORTING` | `true` | Enable crash reporting |

**How to add secrets:**
1. Click **New repository secret**
2. Enter the name and value
3. Click **Add secret**

**For FIREBASE_SERVICE_ACCOUNT:**
- Copy the entire contents of the JSON file
- Paste it as the secret value (it's a multi-line JSON)

---

## 🚀 Deployment

### Automatic Deployment (GitHub Actions)

The workflow is configured to deploy automatically:

1. **On push to `main` or `master` branch** → Deploys to production
2. **On pull request** → Creates preview deployment

**Workflow files:**
- `.github/workflows/firebase-deploy.yml` - Production deployment
- `.github/workflows/firebase-deploy-preview.yml` - Preview deployments

### Manual Deployment (Local)

If you want to test deployment locally:

```bash
# Install Firebase CLI (if not installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Build Flutter web app
flutter build web --release --base-href /

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

---

## 📝 Build Configuration

### Environment Variables

The build process uses environment variables for configuration. These are set in GitHub Actions secrets.

**Build command:**
```bash
flutter build web --release --base-href /
```

**Environment variables are injected during build** via GitHub Actions secrets.

### Custom Domain (Optional)

To use a custom domain:

1. Go to Firebase Console → **Hosting**
2. Click **Add custom domain**
3. Follow the setup wizard
4. Update DNS records as instructed

---

## 🔍 Monitoring Deployments

### View Deployment Status

1. **GitHub Actions**: Go to your repo → **Actions** tab
2. **Firebase Console**: Go to **Hosting** → **Deployments**

### View Live Site

After deployment, your site will be available at:
- `https://hasan-abbas-portfolio.web.app`
- `https://hasan-abbas-portfolio.firebaseapp.com`

---

## 🐛 Troubleshooting

### Build Fails

**Issue**: Build fails in GitHub Actions

**Solutions**:
- Check Flutter version compatibility
- Verify all dependencies are in `pubspec.yaml`
- Check build logs for specific errors
- Ensure environment variables are set correctly

### Deployment Fails

**Issue**: `FIREBASE_SERVICE_ACCOUNT` secret not found

**Solution**:
- Verify the secret is added in GitHub Settings → Secrets
- Check the secret name matches exactly: `FIREBASE_SERVICE_ACCOUNT`
- Ensure the JSON content is valid

### Environment Variables Not Working

**Issue**: App doesn't have access to environment variables

**Solution**:
- For Flutter web, environment variables must be set at build time
- They are injected via GitHub Actions secrets
- Check that secrets are properly set in GitHub

### Preview Deployments Not Working

**Issue**: Preview deployments not created for PRs

**Solution**:
- Check that `FIREBASE_SERVICE_ACCOUNT` secret is set
- Verify the workflow file is in `.github/workflows/`
- Check GitHub Actions logs for errors

---

## 🔒 Security Best Practices

1. **Never commit service account keys** to git
2. **Use GitHub Secrets** for all sensitive data
3. **Rotate service account keys** periodically
4. **Limit service account permissions** in Firebase Console
5. **Review deployment logs** regularly

---

## 📊 Deployment Workflow

```
┌─────────────────┐
│  Push to main   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ GitHub Actions  │
│  Triggered      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Checkout Code  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Setup Flutter   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Get Dependencies│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Build Web App  │
│ (with env vars) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Deploy to       │
│ Firebase Hosting│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Site Live!     │
└─────────────────┘
```

---

## 🎯 Quick Start Checklist

- [ ] Firebase project created
- [ ] Firebase Hosting enabled
- [ ] Service account key downloaded
- [ ] GitHub secrets configured:
  - [ ] `FIREBASE_SERVICE_ACCOUNT`
  - [ ] `SUPABASE_URL`
  - [ ] `SUPABASE_ANON_KEY`
  - [ ] Optional secrets (if needed)
- [ ] Push to `main` branch
- [ ] Check GitHub Actions for deployment status
- [ ] Verify site is live

---

## 📚 Additional Resources

- [Firebase Hosting Docs](https://firebase.google.com/docs/hosting)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)

---

## 🆘 Support

If you encounter issues:

1. Check GitHub Actions logs
2. Check Firebase Console → Hosting
3. Review this guide
4. Check Firebase and GitHub documentation

---

**Ready to deploy?** Push to `main` branch and watch the magic happen! 🚀

