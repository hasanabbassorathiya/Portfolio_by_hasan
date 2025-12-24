# Portfolio CMS - Modern Flutter Portfolio Website

A beautiful, production-ready portfolio website built with Flutter, Supabase, and Firebase. Features a complete admin panel for content management, analytics tracking, and a modern responsive design.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![Supabase](https://img.shields.io/badge/Supabase-3FCF8E?logo=supabase)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase)

## ✨ Features

- 🎨 **Modern UI/UX** - Beautiful, responsive design with Material 3
- 📱 **Multi-Platform** - Web, Mobile (iOS/Android), Desktop (macOS/Windows/Linux)
- 🔐 **Admin Panel** - Complete CMS for managing all content
- 📊 **Analytics** - Built-in analytics tracking (Firebase + Supabase)
- 🎯 **SEO Optimized** - Meta tags, structured data, and web optimization
- 🌐 **Internationalization** - Multi-language support ready
- 📝 **Blog System** - Full-featured blog with draft/scheduled publishing
- 💼 **Portfolio Showcase** - Works, experiences, testimonials, services
- 📧 **Contact Form** - Integrated contact form with email notifications
- 🔗 **Social Links** - Manage social media links with platform icons
- 🎨 **Draggable Lists** - Reorder items with drag-and-drop
- 📤 **File Uploads** - Upload images/files from any device (web/mobile/desktop)
- 🔍 **Search & Filter** - Advanced filtering for works and blogs

## 🚀 Quick Start Guide

### Step 1: Prerequisites

Before you begin, ensure you have:

- **Flutter SDK** (3.0 or higher)
  - Install from [flutter.dev](https://flutter.dev/docs/get-started/install)
  - Verify: `flutter --version`
- **Supabase Account** - [Sign up free](https://supabase.com)
- **Firebase Account** (optional, for analytics) - [Sign up free](https://firebase.google.com)
- **Git** - For cloning the repository

### Step 2: Clone the Repository

```bash
git clone https://github.com/yourusername/portfolio.git
cd portfolio
```

### Step 3: Install Dependencies

```bash
flutter pub get
```

### Step 4: Set Up Supabase

#### 4.1 Create Supabase Project

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Click **New Project**
3. Fill in:
   - **Name**: Your project name
   - **Database Password**: Choose a strong password (save it!)
   - **Region**: Choose closest to your users
4. Click **Create new project**
5. Wait for project to be ready (2-3 minutes)

#### 4.2 Get Your Credentials

1. In Supabase Dashboard, go to **Settings** → **API**
2. Copy the following:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: Long string starting with `eyJ...`

#### 4.3 Run Database Migrations

**Option A: Using Supabase CLI (Recommended)**

```bash
# Install Supabase CLI
npm install -g supabase
# Or using Homebrew (Mac)
brew install supabase/tap/supabase

# Login to Supabase
supabase login

# Link your project
supabase link --project-ref your-project-ref

# Push all migrations
supabase db push
```

**Option B: Manual Setup**

1. Go to Supabase Dashboard → **SQL Editor**
2. Run each migration file in order from `docs/sql/`:
   - `001_initial_schema.sql`
   - `002_seed_data.sql`
   - `003_analytics_and_config.sql`
   - `004_admin_policies.sql`
   - `005_fix_analytics_rls.sql`
   - `006_fix_blog_rls.sql`
   - `007_add_blog_status_and_scheduling.sql`
   - `008_setup_storage_policies.sql`

#### 4.4 Create Storage Buckets

1. Go to **Storage** in Supabase Dashboard
2. Create these buckets (make them **Public**):
   - `avatars` - Profile images
   - `works` - Project images
   - `blogs` - Blog post images
   - `services` - Service icons
   - `testimonials` - Client images

For each bucket:
- Click **New bucket**
- Enter bucket name
- Check **Public bucket**
- Click **Create bucket**

### Step 5: Configure Environment Variables

Create a `.env` file in the project root:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# App Configuration
APP_NAME=Portfolio
DEFAULT_LOCALE=en

# Feature Flags
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=false
```

**Important**: Replace `your-project.supabase.co` and `your-anon-key-here` with your actual values from Step 4.2.

### Step 6: Set Up Admin User

1. Go to Supabase Dashboard → **Authentication** → **Users**
2. Click **Add user** → **Create new user**
3. Enter:
   - **Email**: Your admin email
   - **Password**: Strong password
4. Click **Create user**
5. **Save these credentials** - you'll need them to login to the admin panel

### Step 7: Configure Firebase (Optional but Recommended)

#### 7.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **Add project**
3. Enter project name
4. Follow the setup wizard

#### 7.2 Add Web App

1. In Firebase Console, click **Web** icon (`</>`)
2. Register app with a nickname
3. Copy the Firebase config

#### 7.3 Configure Firebase in Flutter

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

Follow the prompts to select your Firebase project and platforms.

### Step 8: Run the Application

```bash
# For web
flutter run -d chrome

# For mobile (iOS)
flutter run -d ios

# For mobile (Android)
flutter run -d android

# For desktop (macOS)
flutter run -d macos
```

### Step 9: Access Admin Panel

1. Once the app is running, navigate to `/admin/login`
2. Enter your admin credentials (from Step 6)
3. You'll be redirected to the admin dashboard

### Step 10: Initial Setup in Admin Panel

After logging in:

1. **Profile**: Update your profile information
2. **Works**: Add your portfolio projects
3. **Experiences**: Add your work experience
4. **Services**: Add services you offer
5. **Social Links**: Add your social media links
6. **Blogs**: Create your first blog post

## 📚 Documentation

- **[Complete Setup Guide](docs/setup/SETUP.md)** - Detailed step-by-step setup instructions
- **[Database Setup](docs/setup/DATABASE.md)** - SQL migrations and database configuration
- **[API Documentation](docs/api/API.md)** - Complete API reference
- **[Postman Collection](docs/api/portfolio-api.postman_collection.json)** - Import for API testing
- **[Postman Setup Guide](docs/api/POSTMAN_SETUP.md)** - How to use the Postman collection
- **[Deployment Guide](docs/setup/DEPLOYMENT.md)** - Deploy to production
- **[FAQ](docs/setup/FAQ.md)** - Frequently asked questions

## 🗂️ Project Structure

```
portfolio/
├── lib/
│   ├── core/              # Core services, repositories, config
│   ├── features/          # Feature modules (admin, auth)
│   ├── models/            # Data models
│   ├── shared/            # Shared widgets, utils, constants
│   └── views/              # UI screens (home, about, blogs, etc.)
├── docs/                   # Documentation
│   ├── sql/               # Database migrations (8 files)
│   ├── api/               # API documentation & Postman collection
│   ├── setup/             # Setup guides
│   └── guides/            # Feature guides
├── supabase/
│   └── migrations/        # Supabase database migrations
├── assets/                 # Images, icons, fonts
└── web/                    # Web-specific files
```

## 🛠️ Tech Stack

- **Frontend**: Flutter, Dart
- **Backend**: Supabase (PostgreSQL, Storage, Auth)
- **Analytics**: Firebase Analytics
- **Hosting**: Firebase Hosting (web)
- **State Management**: Built-in Flutter (ValueNotifier, ChangeNotifier)
- **Routing**: GoRouter
- **Styling**: Material 3, Custom Theme

## 📋 Database Schema

The project uses Supabase (PostgreSQL) with the following main tables:

- `profiles` - User profile information
- `works` - Portfolio projects/works
- `blogs` - Blog posts
- `experiences` - Work experience
- `services` - Services offered
- `testimonials` - Client testimonials
- `social_links` - Social media links
- `contact_messages` - Contact form submissions
- `analytics_summary` - Analytics data

See [Database Setup](docs/setup/DATABASE.md) for complete schema.

## 🧪 Testing APIs

### Using Postman

1. **Import Collection**
   - Open Postman
   - Click **Import** → **File**
   - Select `docs/api/portfolio-api.postman_collection.json`

2. **Set Environment Variables**
   - Create a new environment in Postman
   - Add these variables:
     - `BASE_URL`: `https://your-project.supabase.co/rest/v1`
     - `ANON_KEY`: Your Supabase anon key
     - `JWT_TOKEN`: Admin JWT token (get from admin login)

3. **Get JWT Token**
   - Login to admin panel at `/admin/login`
   - Or use Supabase Auth API (see [API Documentation](docs/api/API.md))

See [Postman Setup Guide](docs/api/POSTMAN_SETUP.md) for detailed instructions.

## 🚢 Deployment

### Web Deployment (Firebase Hosting)

#### Prerequisites

- Firebase account
- Firebase CLI installed: `npm install -g firebase-tools`
- Firebase project created

#### Steps

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

5. **Access Your Site**
   - Your site will be available at: `https://your-project.web.app`
   - Or your custom domain if configured

### Mobile Deployment

#### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

#### iOS

```bash
# Build for App Store
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode to archive and upload.

See [Deployment Guide](docs/setup/DEPLOYMENT.md) for detailed instructions.

## 📖 Admin Panel Features

Access the admin panel at `/admin/login` after deployment.

**Available Features:**
- 📊 **Dashboard** - Overview with statistics
- 👤 **Profile** - Manage your profile information
- 📝 **Blogs** - Create/edit blogs with draft/scheduled publishing
- 💼 **Works** - Manage portfolio projects
- 🏢 **Experiences** - Manage work experience
- 🛠️ **Services** - Manage services offered
- 💬 **Testimonials** - Manage client testimonials
- 🔗 **Social Links** - Manage social media links
- 📊 **Analytics** - View analytics data
- 📧 **Contacts** - View contact form submissions

## 🔑 Environment Variables Reference

Create a `.env` file in the project root:

```env
# Supabase Configuration (Required)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# App Configuration (Optional)
APP_NAME=Portfolio
DEFAULT_LOCALE=en
SUPPORTED_LOCALES=en,ar,fr

# Feature Flags (Optional)
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=false
```

Get Supabase credentials from: Supabase Dashboard → Settings → API

## 🐛 Troubleshooting

### Common Issues

#### "Supabase not initialized"
- Check your `.env` file exists and has correct values
- Verify `SUPABASE_URL` and `SUPABASE_ANON_KEY` are correct
- Restart the app after changing `.env`

#### "Row-level security policy violation"
- Run all SQL migrations in order
- Check that RLS policies are created (see `docs/sql/`)
- Verify you're authenticated (include JWT token for admin endpoints)

#### "Storage bucket not found"
- Create the required storage buckets in Supabase Dashboard
- Ensure buckets are public or policies allow access
- Run migration `008_setup_storage_policies.sql`

#### "Failed to upload file"
- Check storage bucket exists
- Verify storage policies allow uploads
- Check file size limits

### Getting Help

- Check [FAQ](docs/setup/FAQ.md)
- Review [Setup Guide](docs/setup/SETUP.md)
- Open an issue on GitHub

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- Firebase for analytics and hosting
- All contributors and users

## 📞 Support

For issues, questions, or contributions:
- 📖 Check the [Documentation](docs/)
- ❓ Review [FAQ](docs/setup/FAQ.md)
- 🐛 Open an issue on GitHub
- 💬 Start a discussion

## 🌟 Star History

If you find this project useful, please consider giving it a star ⭐

---

**Made with ❤️ using Flutter**

**Ready to build your portfolio? Start with [Step 1](#step-1-prerequisites) above!**
