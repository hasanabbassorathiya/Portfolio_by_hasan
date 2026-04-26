
<div align="center">
  <img src="assets/icons/appstore.png" alt="Logo" width="120">
  <h1 align="center">Hasan Abbas Sorathiya | Portfolio</h1>
  <p align="center">
    A stunning, fully open-source Developer Portfolio built with <strong>Flutter Web</strong>, powered by <strong>Turso</strong> at the edge, and secured by <strong>Firebase Auth</strong>.
  </p>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.27-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Turso](https://img.shields.io/badge/Turso-Database-000000?style=for-the-badge&logo=sqlite&logoColor=white)](https://turso.tech)
  [![Netlify](https://img.shields.io/badge/Hosted_on-Netlify-00C7B7?style=for-the-badge&logo=netlify&logoColor=white)](https://netlify.com)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
</div>

<br />

## ✨ Features

- **Blazing Fast Edge DB:** Uses Turso (SQLite at the Edge) for sub-millisecond data reads and global scalability.
- **Dynamic Admin Dashboard:** A fully protected Admin Panel to manage your Experience, Blogs, Projects, Skills, and Social Links.
- **Base64 Image Uploads:** Bypass external cloud storage entirely! Profile pictures and contact attachments are encoded into Base64 and stored directly in your Turso database.
- **Built-in Analytics:** Tracks page views and custom events seamlessly.
- **Firebase Secured:** Admin Panel is securely locked behind Firebase Authentication.
- **Responsive Design:** Looks incredible on both Desktop and Mobile devices.

## 📱 Screenshots

| Public Portfolio | Admin Dashboard |
| :---: | :---: |
| <img src="assets/screenshots/web.png" width="400" alt="Web View"> | <img src="assets/screenshots/mobile.png" width="400" alt="Mobile View"> |

> *Note: Place your actual high-quality screenshots in `assets/screenshots/web.png` and `assets/screenshots/mobile.png` to display them here!*

---

## 🚀 Quick Setup Instructions

This repository is designed to be easily cloned and deployed for **your own personal portfolio**.

### 1. Database Setup (Turso)
1. Install the Turso CLI: `curl -sSf https://get.turso.tech/install.sh | bash`
2. Sign up and create a database:
   ```bash
   turso auth signup
   turso db create portfolio-db
   turso db show portfolio-db --url
   turso db tokens create portfolio-db
   ```
3. Take your Database URL and Token and put them in a `.env` file at the root of the project.
4. Set up the tables. Execute the SQL queries located in `supabase/migrations/` against your Turso DB:
   ```bash
   turso db shell portfolio-db < supabase/migrations/001_initial_schema.sql
   turso db shell portfolio-db < supabase/migrations/009_add_quote_and_app_store_links.sql
   turso db shell portfolio-db < supabase/migrations/010_add_years_of_experience.sql
   turso db shell portfolio-db < supabase/migrations/011_add_contact_attachments_bucket.sql
   ```

### 2. Admin Authentication Setup (Firebase)
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Create a new project.
3. Go to **Authentication** -> **Sign-in method** and enable **Email/Password**.
4. Go to the **Users** tab and click **Add user**. Enter your email and a secure password. This will be your Admin login.
5. Use the **FlutterFire CLI** to automatically configure your project:
   ```bash
   # Install the CLI if you haven't already
   dart pub global activate flutterfire_cli

   # Log in to Firebase
   firebase login

   # Configure your Flutter project (this will generate lib/firebase_options.dart automatically)
   flutterfire configure
   ```

### 3. Hosting on Netlify (Recommended)

This repository includes a `netlify.toml` configuration file for seamless, zero-config deployment.

1. Log into your [Netlify](https://app.netlify.com/) account.
2. Click **Add new site** -> **Import an existing project**.
3. Connect your GitHub account and select your cloned repository.
4. The build settings (Command: `flutter build web --release`, Publish directory: `build/web`) will auto-populate from the `netlify.toml` file.
5. Click **Add environment variables** and enter:
   - `TURSO_URL` : Your Turso Pipeline URL
   - `TURSO_TOKEN` : Your Turso database token
   - `APP_NAME` : `Portfolio`
6. Click **Deploy site**.


### 5. Hosting on Firebase (Alternative)

If you prefer to host this app via Firebase Hosting using GitHub Actions, follow these steps:

1. Enable Firebase Hosting in the Firebase Console.
2. Initialize Firebase Hosting locally by running:
   ```bash
   firebase init hosting
   # Set the public directory to: build/web
   # Configure as a single-page app: Yes
   ```
3. Go to GitHub **Settings** -> **Secrets and variables** -> **Actions**.
4. Add your Turso Database Secrets (`TURSO_URL` and `TURSO_TOKEN`).
5. Add your Firebase Service Account JSON as a secret named `FIREBASE_SERVICE_ACCOUNT`.
6. Add your Firebase Project ID as a secret named `FIREBASE_PROJECT_ID`.
7. Push to `main`, and the `firebase-deploy.yml` GitHub Action will compile and release your app!


### 6. Local Turso Embedded Replicas (Optional Advanced Mode)
For ultra-fast sub-millisecond local reads, you can enable Turso's embedded replicas.
Update your database connection string in the Dart code to:
```dart
import 'package:libsql_dart/libsql_dart.dart';

final client = await LibsqlClient.create(
  url: 'file:local.db',
  syncUrl: 'libsql://[your-db].turso.io',
  authToken: '[your-token]',
);
await client.sync();
```
*(Ensure you add `libsql_dart` to your `pubspec.yaml` if you want to use embedded replicas instead of the HTTP pipeline).*

---

### ❤️ Contributing
Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/hasanabbassorathiya/Portfolio_by_hasan/issues).

### 📝 License
Copyright © 2026 [Hasan Abbas Sorathiya](https://github.com/hasanabbassorathiya).
