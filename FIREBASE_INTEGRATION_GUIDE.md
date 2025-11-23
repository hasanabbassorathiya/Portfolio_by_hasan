# 🔥 Firebase Integration Guide

This guide explains how Firebase Remote Config, Crashlytics, and Performance Monitoring are integrated into the Portfolio CMS.

---

## 📋 Overview

The app integrates three Firebase services:
1. **Firebase Remote Config** - Dynamic app configuration
2. **Firebase Crashlytics** - Error tracking and crash reporting
3. **Firebase Performance** - Performance monitoring

All services are **optional** - the app works without Firebase configured.

---

## 🔧 Setup

### 1. Firebase Project Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing
3. Add your app (iOS/Android/Web)

### 2. Web Configuration

For Flutter Web, add Firebase config to `web/index.html`:

```html
<script type="module">
  import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js';
  import { getAnalytics } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-analytics.js';
  import { getRemoteConfig } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-remote-config.js';
  import { getPerformance } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-performance.js';

  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_PROJECT.firebaseapp.com",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_PROJECT.appspot.com",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "YOUR_APP_ID",
    measurementId: "YOUR_MEASUREMENT_ID"
  };

  const app = initializeApp(firebaseConfig);
  const analytics = getAnalytics(app);
  const remoteConfig = getRemoteConfig(app);
  const performance = getPerformance(app);
</script>
```

### 3. Mobile Configuration

- **iOS**: Add `GoogleService-Info.plist` to `ios/Runner/`
- **Android**: Add `google-services.json` to `android/app/`

---

## 🎛️ Remote Config

### Using Remote Config

The app uses `RemoteConfigService` which combines Firebase Remote Config with Supabase fallback:

```dart
import 'package:portfolio/core/services/remote_config_service.dart';

// Get a string value
final message = await RemoteConfigService.getString(
  'welcome_message',
  defaultValue: 'Welcome!',
);

// Get a boolean value
final isFeatureEnabled = await RemoteConfigService.getBool(
  'feature_new_design',
  defaultValue: false,
);

// Get a number
final maxItems = await RemoteConfigService.getNumber(
  'max_blog_items',
  defaultValue: 10,
);

// Check maintenance mode
final isMaintenance = await RemoteConfigService.isMaintenanceMode();

// Check if feature is enabled
final hasNewFeature = await RemoteConfigService.isFeatureEnabled('new_feature');
```

### Setting Remote Config Values

#### Via Firebase Console:
1. Go to Firebase Console → Remote Config
2. Add parameters:
   - `maintenance_mode` (Boolean) - Enable/disable maintenance mode
   - `maintenance_message` (String) - Message shown during maintenance
   - `feature_new_design` (Boolean) - Feature flags
   - `app_version` (String) - Current app version

#### Via Supabase (Admin Panel):
```dart
await RemoteConfigService.setConfig(
  key: 'maintenance_mode',
  value: true,
  description: 'Enable maintenance mode',
);
```

### Maintenance Mode

The app automatically checks for maintenance mode on startup and shows a maintenance screen if enabled:

```dart
// In main.dart
MaintenanceModeWidget(
  child: MaterialApp(...),
)
```

---

## 🐛 Crashlytics

### Automatic Error Tracking

Errors are automatically tracked via `ErrorHandler`:

```dart
// In main.dart
ErrorHandler.initialize();
```

This sets up:
- Flutter framework error handling
- Platform error handling (async errors)
- Automatic crash reporting

### Manual Error Reporting

```dart
import 'package:portfolio/core/services/error_handler.dart';

// Handle error with user message
await ErrorHandler.handleError(
  error,
  stackTrace,
  reason: 'Failed to load data',
  context: context,
  userMessage: 'Unable to load content. Please try again.',
);

// Safe call wrapper
final result = await ErrorHandler.safeCall(
  () => fetchData(),
  defaultValue: null,
  errorMessage: 'Failed to fetch data',
  context: context,
);
```

### Direct Crashlytics Access

```dart
import 'package:portfolio/core/services/firebase_service.dart';

await FirebaseService.recordError(
  exception,
  stackTrace,
  reason: 'Custom error reason',
  fatal: false, // true for crashes, false for non-fatal errors
);
```

---

## ⚡ Performance Monitoring

### Automatic Performance Tracking

The `PerformanceService` provides easy performance measurement:

```dart
import 'package:portfolio/core/services/performance_service.dart';

// Measure database query
final blogs = await PerformanceService.measureDatabaseQuery(
  'blogs',
  () => blogRepository.getAllBlogs(),
);

// Measure HTTP request
final data = await PerformanceService.measureHttpRequest(
  'https://api.example.com/data',
  () => http.get(Uri.parse('https://api.example.com/data')),
);

// Measure image load
final image = await PerformanceService.measureImageLoad(
  imageUrl,
  () => loadImage(imageUrl),
);

// Measure screen render
final result = await PerformanceService.measureScreenRender(
  'HomeScreen',
  () => buildHomeScreen(),
);

// Generic performance measurement
final result = await PerformanceService.measurePerformance(
  'custom_operation',
  () => performOperation(),
);
```

### Manual Trace Creation

```dart
final trace = PerformanceService.startTrace('my_operation');
trace?.start();

try {
  // Your operation
  await doSomething();
} finally {
  trace?.stop();
}
```

---

## 📊 Viewing Data

### Firebase Console

1. **Remote Config**: Firebase Console → Remote Config
2. **Crashlytics**: Firebase Console → Crashlytics
3. **Performance**: Firebase Console → Performance

### Supabase Analytics

Analytics data is also stored in Supabase:
- `page_views` table
- `custom_events` table
- View in Admin Panel → Analytics

---

## 🔒 Security Notes

1. **Firebase is Optional**: App works without Firebase configured
2. **Graceful Degradation**: All Firebase calls are wrapped in try-catch
3. **No Sensitive Data**: Don't store sensitive data in Remote Config
4. **Error Privacy**: Crashlytics may contain user data - review before sharing

---

## 🧪 Testing

### Test Remote Config Locally

```dart
// Set test values in Supabase
await RemoteConfigService.setConfig(
  key: 'test_feature',
  value: true,
);

// Fetch and activate
await RemoteConfigService.fetchAndActivate();
```

### Test Crashlytics

```dart
// Force a test crash (development only)
await FirebaseService.recordError(
  Exception('Test error'),
  StackTrace.current,
  reason: 'Testing Crashlytics',
  fatal: false,
);
```

### Test Performance

```dart
// Measure a slow operation
await PerformanceService.measurePerformance(
  'slow_operation',
  () async {
    await Future.delayed(Duration(seconds: 2));
    return 'result';
  },
);
```

---

## 📝 Best Practices

1. **Use Defaults**: Always provide default values for Remote Config
2. **Handle Errors**: Wrap Firebase calls in try-catch
3. **Measure Key Operations**: Add performance tracking to critical paths
4. **Monitor Regularly**: Check Crashlytics and Performance dashboards
5. **Test Features**: Test Remote Config changes before deploying

---

## 🚀 Deployment Checklist

- [ ] Firebase project created and configured
- [ ] Web config added to `index.html`
- [ ] Mobile config files added (iOS/Android)
- [ ] Remote Config defaults set
- [ ] Test Crashlytics reporting
- [ ] Test Performance monitoring
- [ ] Verify maintenance mode works
- [ ] Check Firebase Console for data

---

## 🆘 Troubleshooting

### Firebase Not Initializing

**Issue**: `Firebase web not configured - skipping (optional)`

**Solution**: 
- Check `web/index.html` has Firebase config
- Verify API keys are correct
- Check browser console for errors

### Remote Config Not Working

**Issue**: Config values not updating

**Solution**:
- Call `RemoteConfigService.fetchAndActivate()` periodically
- Check Firebase Console for parameter values
- Verify network connectivity

### Crashlytics Not Reporting

**Issue**: Errors not appearing in Crashlytics

**Solution**:
- Wait 24 hours for data to appear (can be delayed)
- Check Firebase project settings
- Verify Crashlytics is enabled in Firebase Console

---

## 📚 Additional Resources

- [Firebase Remote Config Docs](https://firebase.google.com/docs/remote-config)
- [Firebase Crashlytics Docs](https://firebase.google.com/docs/crashlytics)
- [Firebase Performance Docs](https://firebase.google.com/docs/perf-mon)

