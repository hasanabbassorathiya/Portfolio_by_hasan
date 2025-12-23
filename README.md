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

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.0 or higher)
- Supabase account ([Sign up free](https://supabase.com))
- Firebase account (optional, for analytics)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/portfolio.git
   cd portfolio
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   - Copy `.env.example` to `.env` (if exists) or create `.env`
   - Add your Supabase credentials (see [Setup Guide](docs/setup/SETUP.md))

4. **Run database migrations**
   - See [Database Setup](docs/setup/DATABASE.md) for detailed instructions
   - Or use: `supabase db push` (if CLI is installed)

5. **Run the app**
   ```bash
   flutter run -d chrome  # For web
   flutter run             # For mobile/desktop
   ```

## 📚 Documentation

- **[Complete Setup Guide](docs/setup/SETUP.md)** - Step-by-step setup instructions
- **[Database Setup](docs/setup/DATABASE.md)** - SQL migrations and database configuration
- **[API Documentation](docs/api/API.md)** - Complete API reference
- **[Postman Collection](docs/api/portfolio-api.postman_collection.json)** - Import for API testing
- **[Admin Panel Guide](docs/setup/ADMIN.md)** - Admin panel usage guide
- **[Deployment Guide](docs/setup/DEPLOYMENT.md)** - Deploy to production

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
│   ├── sql/               # Database migrations
│   ├── api/               # API documentation & Postman collection
│   └── setup/             # Setup guides
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

## 🔑 Environment Variables

Create a `.env` file in the project root:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

Get these from: Supabase Dashboard → Settings → API

## 🧪 Testing APIs

Import the Postman collection:

1. Open Postman
2. Import → File → Select `docs/api/portfolio-api.postman_collection.json`
3. Set environment variables:
   - `BASE_URL`: Your Supabase REST API URL
   - `ANON_KEY`: Your Supabase anon key
   - `JWT_TOKEN`: Admin JWT token (get from admin login)

See [API Documentation](docs/api/API.md) for details.

## 🚢 Deployment

### Web (Firebase Hosting)

```bash
flutter build web --release
firebase deploy --only hosting
```

### Mobile

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

See [Deployment Guide](docs/setup/DEPLOYMENT.md) for detailed instructions.

## 📖 Admin Panel

Access the admin panel at `/admin/login` after deployment.

**Default Features:**
- Dashboard with statistics
- Manage Profile
- Create/Edit Blogs (with draft/scheduled publishing)
- Manage Works/Projects
- Manage Experiences
- Manage Services
- Manage Testimonials
- Manage Social Links
- View Analytics
- View Contact Messages

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- Firebase for analytics and hosting
- All contributors and users

## 📞 Support

For issues, questions, or contributions:
- Open an issue on GitHub
- Check the [Documentation](docs/)
- Review [FAQ](docs/setup/FAQ.md)

---

**Made with ❤️ using Flutter**
