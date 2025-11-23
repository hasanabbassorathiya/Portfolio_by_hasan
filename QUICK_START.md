# Quick Start Guide - Portfolio CMS

## 🚀 Getting Started in 5 Minutes

### Step 1: Set Up Supabase (2 minutes)

1. Go to [supabase.com](https://supabase.com) and create a free account
2. Create a new project
3. Copy your **Project URL** and **anon key** from Settings → API

### Step 2: Configure Environment (1 minute)

1. Copy `.env.example` to `.env`
2. Add your Supabase credentials:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```

### Step 3: Set Up Database (1 minute)

1. Go to **SQL Editor** in Supabase dashboard
2. Run `supabase/migrations/001_initial_schema.sql`
3. (Optional) Run `supabase/migrations/002_seed_data.sql` for sample data

### Step 4: Run the App (1 minute)

```bash
flutter pub get
flutter run -d chrome
```

## 📝 Using the New API System

### Before (Static Data)
```dart
// Old way - static data
final blogs = BlogRepository.getAllBlogs();
```

### After (Dynamic from Supabase)
```dart
// New way - dynamic from Supabase
final blogRepo = BlogRepository();
final blogs = await blogRepo.getAllBlogs();
```

### Example: Fetching Works
```dart
import 'package:portfolio/core/repositories/work_repository.dart';

final workRepo = WorkRepository();

// Get all works
final allWorks = await workRepo.getAllWorks();

// Get featured works
final featured = await workRepo.getFeaturedWorks(limit: 4);

// Get work by ID
final work = await workRepo.getWorkById('work-id-here');
```

### Example: Fetching Blogs
```dart
import 'package:portfolio/core/repositories/blog_repository.dart';

final blogRepo = BlogRepository();

// Get all published blogs
final blogs = await blogRepo.getAllBlogs();

// Get blog by slug
final blog = await blogRepo.getBlogBySlug('my-blog-post');

// Get featured blogs
final featured = await blogRepo.getFeaturedBlogs(limit: 3);
```

## 🌍 Localization

### Change Language
```dart
import 'package:portfolio/core/services/localization_service.dart';

final localization = LocalizationService();
await localization.setLocale(Locale('ar')); // Arabic
await localization.setLocale(Locale('fr')); // French
```

### Using Localized Strings
```dart
import 'package:portfolio/l10n/app_localizations.dart';

final l10n = AppLocalizations.of(context)!;
Text(l10n.home); // "Home" or "الرئيسية" or "Accueil"
```

## 🔄 Migrating Existing Code

### Update Views to Use New Repositories

**Before:**
```dart
class BlogsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final blogs = BlogRepository.getAllBlogs();
    // ...
  }
}
```

**After:**
```dart
class BlogsView extends StatefulWidget {
  @override
  State<BlogsView> createState() => _BlogsViewState();
}

class _BlogsViewState extends State<BlogsView> {
  final _blogRepo = BlogRepository();
  List<BlogModel> _blogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    try {
      final blogs = await _blogRepo.getAllBlogs();
      setState(() {
        _blogs = blogs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }
    // Use _blogs...
  }
}
```

## 📊 Database Management

### Adding Content via Supabase Dashboard

1. Go to **Table Editor** in Supabase
2. Select a table (e.g., `works`, `blogs`)
3. Click **Insert** → **Insert row**
4. Fill in the fields
5. Click **Save`

### Adding Content via SQL

```sql
-- Add a new work
INSERT INTO works (title, category, description, image_url, is_active)
VALUES (
  'My New Project',
  'Web Design',
  'A beautiful website redesign',
  'https://example.com/image.jpg',
  true
);
```

## 🎨 Image Management

### Upload Images to Supabase Storage

1. Go to **Storage** in Supabase dashboard
2. Create buckets: `works`, `blogs`, `avatars`
3. Upload images
4. Copy the public URL
5. Use the URL in your database records

### Using Image URLs

```dart
// In your models, image_url will be a Supabase Storage URL
Image.network(work.imageAsset); // Now uses Supabase URL
```

## 🔐 Security Notes

- **Public Read**: All content tables allow public read access
- **Contact Form**: Anyone can submit contact messages
- **Admin Access**: Will be added in future updates
- **RLS**: Row Level Security is enabled on all tables

## 📚 Next Steps

1. **Customize Content**: Update database with your information
2. **Add Images**: Upload to Supabase Storage
3. **Configure Localization**: Add translations
4. **Deploy**: See `DEPLOYMENT.md` for production deployment

## 🆘 Need Help?

- Check `README_SETUP.md` for detailed setup
- Review `IMPLEMENTATION_PLAN.md` for architecture
- Check Supabase docs: https://supabase.com/docs

