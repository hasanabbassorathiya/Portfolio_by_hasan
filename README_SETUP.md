# Portfolio CMS Setup Guide

> **🚀 New to this project?** Start with `GETTING_STARTED.md` for a complete step-by-step guide!
> **📮 Using Postman?** See `POSTMAN_SETUP_GUIDE.md` for Postman collection setup.

This guide will help you set up the Portfolio CMS project with Supabase backend.

## Prerequisites

- Flutter SDK (3.7.0 or higher)
- Dart SDK (3.7.0 or higher)
- Supabase account (free tier works)
- Git (optional, for version control)

## Quick Start

### 1. Clone/Download the Project

```bash
# If using git
git clone <repository-url>
cd portfolio

# Or extract the project files
```

### 2. Run Setup Script

```bash
# On macOS/Linux
chmod +x scripts/setup.sh
./scripts/setup.sh

# On Windows
scripts\setup.ps1
```

The setup script will:
- Create `.env` file from `.env.example`
- Install Flutter dependencies
- Check for required tools

### 3. Set Up Supabase

#### Option A: Using Supabase Dashboard (Recommended for beginners)

1. Go to [https://supabase.com](https://supabase.com) and create an account
2. Create a new project
3. Wait for the project to be ready (takes ~2 minutes)
4. Go to **Settings** → **API**
5. Copy your **Project URL** and **anon/public key**
6. Open `.env` file and update:
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

#### Option B: Using Supabase CLI

1. Install Supabase CLI:
   ```bash
   # macOS
   brew install supabase/tap/supabase
   
   # Or download from: https://github.com/supabase/cli/releases
   ```

2. Login to Supabase:
   ```bash
   supabase login
   ```

3. Link your project:
   ```bash
   supabase link --project-ref your-project-ref
   ```

4. Push migrations:
   ```bash
   supabase db push
   ```

### 4. Run Database Migrations

#### Using Supabase Dashboard:

1. Go to **SQL Editor** in your Supabase dashboard
2. Open `supabase/migrations/001_initial_schema.sql`
3. Copy and paste the SQL into the editor
4. Click **Run**
5. Repeat for `002_seed_data.sql` (optional, for sample data)

#### Using Supabase CLI:

```bash
supabase db push
```

### 5. Configure Storage (Optional)

If you want to upload images:

1. Go to **Storage** in Supabase dashboard
2. Create buckets:
   - `avatars` - for profile images
   - `works` - for project images
   - `blogs` - for blog images
   - `uploads` - for contact form attachments

3. Set bucket policies (public read for images):
   ```sql
   -- Allow public read access
   CREATE POLICY "Public Access" ON storage.objects
   FOR SELECT USING (bucket_id = 'works' OR bucket_id = 'blogs' OR bucket_id = 'avatars');
   ```

### 6. Run the Application

```bash
# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Or run on specific device
flutter devices
flutter run -d <device-id>
```

## Environment Variables

Create a `.env` file in the root directory:

```env
# Supabase Configuration
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# App Configuration
APP_NAME=Portfolio
DEFAULT_LOCALE=en
SUPPORTED_LOCALES=en,ar,fr

# Feature Flags
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
```

## Database Schema

The database includes the following tables:

- `profiles` - Portfolio owner information
- `social_links` - Social media links
- `services` - Service offerings
- `works` - Portfolio projects
- `blogs` - Blog posts
- `testimonials` - Client testimonials
- `experiences` - Work experience
- `contact_messages` - Contact form submissions
- `localizations` - Multi-language content
- `settings` - Global settings

See `IMPLEMENTATION_PLAN.md` for detailed schema documentation.

## Localization

The app supports multiple languages:

- English (en) - Default
- Arabic (ar)
- French (fr)

To add more languages:

1. Update `SUPPORTED_LOCALES` in `.env`
2. Add translations to `lib/l10n/app_localizations.dart`
3. Add translations to database via `localizations` table

## API Usage

### Public Endpoints (No Authentication)

```dart
// Get all blogs
final blogs = await BlogRepository().getAllBlogs();

// Get all works
final works = await WorkRepository().getAllWorks();

// Get featured works
final featured = await WorkRepository().getFeaturedWorks();
```

### Admin Endpoints (Requires Authentication)

Admin endpoints will be available when authentication is set up. See `IMPLEMENTATION_PLAN.md` for details.

## Troubleshooting

### Issue: "Supabase not initialized"

**Solution**: Make sure you've:
1. Created `.env` file
2. Added `SUPABASE_URL` and `SUPABASE_ANON_KEY`
3. Initialized Supabase in `main.dart`

### Issue: "Table does not exist"

**Solution**: Run the database migrations:
1. Go to Supabase Dashboard → SQL Editor
2. Run `001_initial_schema.sql`
3. Run `002_seed_data.sql` (optional)

### Issue: "Permission denied" errors

**Solution**: Check Row Level Security (RLS) policies in Supabase:
1. Go to Authentication → Policies
2. Ensure public read policies are enabled

### Issue: Images not loading

**Solution**: 
1. Check if storage buckets are created
2. Verify bucket policies allow public read
3. Check image URLs in database

## Next Steps

1. **Customize Content**: Update database with your information
2. **Add Images**: Upload images to Supabase Storage
3. **Configure Localization**: Add translations for your languages
4. **Deploy**: Deploy to production (see `DEPLOYMENT.md`)

## Support

For issues or questions:
- Check `IMPLEMENTATION_PLAN.md` for architecture details
- Review Supabase documentation: https://supabase.com/docs
- Review Flutter documentation: https://flutter.dev/docs

## License

[Your License Here]

