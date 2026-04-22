# Portfolio

A Flutter portfolio application using Turso database.

## Screenshots

### Web
\![Web](assets/screenshots/web.png)

### Mobile
\![Mobile](assets/screenshots/mobile.png)


## Setup Instructions for Your Own Portfolio

This repository uses **Turso** as its database and **Firebase Auth** for the admin panel. 
To clone and use this for your own portfolio, follow these steps:

### 1. Database Setup (Turso)
1. Install the Turso CLI: `curl -sSf https://get.turso.tech/install.sh | bash`
2. Sign up and create a database:
   ```bash
   turso auth signup
   turso db create portfolio-db
   turso db show portfolio-db --url
   turso db tokens create portfolio-db
   ```
3. Take your Database URL and Token and put them in your `lib/core/services/turso_service.dart` or a `.env` file.
4. Set up the tables. You can execute the SQL queries located in `supabase/migrations/` against your Turso DB using the Turso CLI:
   ```bash
   turso db shell portfolio-db < supabase/migrations/001_initial_schema.sql
   turso db shell portfolio-db < supabase/migrations/009_add_quote_and_app_store_links.sql
   turso db shell portfolio-db < supabase/migrations/010_add_years_of_experience.sql
   ```

### 2. Admin Authentication Setup (Firebase)
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Create a new project.
3. Go to **Authentication** -> **Sign-in method** and enable **Email/Password**.
4. Go to the **Users** tab and click **Add user**. Enter your email and a secure password. This will be your Admin login.
5. Register a Web App in your Firebase Project settings to get your configuration.
6. Add the configuration to a new file at `lib/firebase_options.dart`:
   ```dart
   import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
   import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

   class DefaultFirebaseOptions {
     static FirebaseOptions get currentPlatform {
       // Insert your Firebase configuration here
       return const FirebaseOptions(
         apiKey: "YOUR_API_KEY",
         appId: "YOUR_APP_ID",
         messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
         projectId: "YOUR_PROJECT_ID",
       );
     }
   }
   ```

### 3. Local Turso Embedded Replicas (Optional)
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
