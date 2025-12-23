# Deployment Guide

Complete guide for deploying the Portfolio CMS to production.

## Table of Contents

1. [Web Deployment (Firebase Hosting)](#web-deployment-firebase-hosting)
2. [Mobile Deployment](#mobile-deployment)
3. [Desktop Deployment](#desktop-deployment)
4. [Environment Configuration](#environment-configuration)
5. [Post-Deployment Checklist](#post-deployment-checklist)

## Web Deployment (Firebase Hosting)

### Prerequisites

- Firebase account
- Firebase CLI installed: `npm install -g firebase-tools`
- Firebase project created

### Setup

1. **Login to Firebase**
   ```bash
   firebase login
   ```

2. **Initialize Firebase** (if not already done)
   ```bash
   firebase init hosting
   ```
   - Select your Firebase project
   - Public directory: `build/web`
   - Single-page app: Yes
   - Overwrite index.html: No

3. **Build for Production**
   ```bash
   flutter build web --release
   ```

4. **Deploy**
   ```bash
   firebase deploy --only hosting
   ```

### Custom Domain

1. Go to Firebase Console → Hosting
2. Click **Add custom domain**
3. Follow the DNS configuration steps
4. Wait for SSL certificate (automatic)

### Environment Variables for Web

For web deployment, you'll need to set environment variables. Options:

**Option 1: Build-time variables**
- Use `--dart-define` flags:
  ```bash
  flutter build web --release \
    --dart-define=SUPABASE_URL=https://your-project.supabase.co \
    --dart-define=SUPABASE_ANON_KEY=your-key
  ```

**Option 2: Runtime configuration**
- Store in `lib/core/config/app_config.dart`
- Load from a config file or API

## Mobile Deployment

### Android

#### Build APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

#### Build App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

#### Play Store Setup

1. Create app in Google Play Console
2. Upload the `.aab` file
3. Fill in store listing
4. Submit for review

### iOS

#### Build for App Store

```bash
flutter build ios --release
```

#### App Store Setup

1. Open `ios/Runner.xcworkspace` in Xcode
2. Configure signing:
   - Select your team
   - Enable automatic signing
3. Archive:
   - Product → Archive
4. Upload to App Store Connect
5. Submit for review

## Desktop Deployment

### macOS

```bash
flutter build macos --release
```

Output: `build/macos/Build/Products/Release/portfolio.app`

### Windows

```bash
flutter build windows --release
```

Output: `build/windows/runner/Release/`

### Linux

```bash
flutter build linux --release
```

Output: `build/linux/x64/release/bundle/`

## Environment Configuration

### Production Environment Variables

Create a production `.env` file or use build-time variables:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-production-anon-key
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
```

### Supabase Production Settings

1. **Enable RLS**: Ensure all tables have RLS enabled
2. **API Keys**: Use production keys (not development)
3. **Storage**: Verify bucket policies
4. **Database**: Run all migrations in production

### Firebase Production Settings

1. **Analytics**: Enable in Firebase Console
2. **Crash Reporting**: Enable if using
3. **Performance Monitoring**: Optional

## Post-Deployment Checklist

### ✅ Functionality

- [ ] Home page loads correctly
- [ ] About page displays profile
- [ ] Works/Projects display
- [ ] Blog posts load
- [ ] Contact form submits
- [ ] Admin login works
- [ ] File uploads work
- [ ] Images load correctly

### ✅ Performance

- [ ] Page load time < 3 seconds
- [ ] Images optimized
- [ ] No console errors
- [ ] Analytics tracking works

### ✅ Security

- [ ] RLS policies active
- [ ] Admin routes protected
- [ ] API keys not exposed
- [ ] HTTPS enabled

### ✅ SEO

- [ ] Meta tags configured
- [ ] Sitemap generated (if applicable)
- [ ] Robots.txt configured
- [ ] Open Graph tags

## Continuous Deployment

### GitHub Actions (Example)

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Firebase

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.0.0'
      - run: flutter pub get
      - run: flutter build web --release
      - uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: your-project-id
```

## Troubleshooting

### Build Errors

- **Missing dependencies**: Run `flutter pub get`
- **Build failures**: Check Flutter version compatibility
- **Web build issues**: Clear build cache: `flutter clean`

### Deployment Errors

- **Firebase auth**: Ensure `firebase login` completed
- **Permissions**: Check Firebase project permissions
- **Build size**: Optimize assets if build is too large

### Runtime Errors

- **API errors**: Check Supabase URL and keys
- **CORS issues**: Verify Supabase CORS settings
- **Storage errors**: Check bucket policies

## Next Steps

- [Setup Guide](SETUP.md)
- [Database Setup](DATABASE.md)
- [API Documentation](../api/API.md)

