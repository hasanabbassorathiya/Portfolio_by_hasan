# Frequently Asked Questions (FAQ)

Common questions and solutions for the Portfolio CMS.

## Setup & Configuration

### Q: How do I get my Supabase credentials?

A: 
1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Go to **Settings** → **API**
4. Copy **Project URL** and **anon public key**

### Q: Where do I put my environment variables?

A: Create a `.env` file in the project root:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

### Q: Do I need Firebase?

A: Firebase is optional but recommended for analytics. The app will work without it, but analytics features will be disabled.

## Database

### Q: How do I run database migrations?

A: Two options:

**Option 1: Supabase CLI (Recommended)**
```bash
supabase db push
```

**Option 2: Manual**
1. Go to Supabase Dashboard → SQL Editor
2. Run each file from `docs/sql/` in order

### Q: What if a migration fails?

A: 
- Check the error message
- Common issues:
  - Table already exists: Skip that migration or drop the table
  - Policy already exists: Should be handled by `DROP POLICY IF EXISTS`
- Run migrations in order (001, 002, 003, etc.)

### Q: How do I reset the database?

A:
```bash
# Using Supabase CLI
supabase db reset

# Or manually drop tables in SQL Editor
```

## Storage

### Q: File uploads are failing. What's wrong?

A: Check:
1. Storage buckets exist (avatars, works, blogs, etc.)
2. Buckets are public or policies allow access
3. Run migration `008_setup_storage_policies.sql`
4. Check file size limits

### Q: How do I create storage buckets?

A:
1. Supabase Dashboard → Storage
2. Click **New bucket**
3. Name it (e.g., `avatars`)
4. Check **Public bucket**
5. Click **Create bucket**

## Admin Panel

### Q: How do I create an admin user?

A:
1. Supabase Dashboard → Authentication → Users
2. Click **Add user** → **Create new user**
3. Enter email and password
4. Use these credentials to login at `/admin/login`

### Q: I can't access admin routes. Why?

A: 
- Ensure you're logged in
- Check that RLS policies are set up (run migration `004_admin_policies.sql`)
- Verify your user exists in Supabase Auth

### Q: How do I get a JWT token for API testing?

A:
1. Login to admin panel at `/admin/login`
2. Or use Supabase Auth API:
   ```bash
   curl -X POST 'https://your-project.supabase.co/auth/v1/token?grant_type=password' \
     -H "apikey: YOUR_ANON_KEY" \
     -H "Content-Type: application/json" \
     -d '{"email":"your@email.com","password":"yourpassword"}'
   ```

## API

### Q: How do I test the API?

A:
1. Import Postman collection: `docs/api/portfolio-api.postman_collection.json`
2. Set environment variables:
   - `BASE_URL`: Your Supabase REST API URL
   - `ANON_KEY`: Your Supabase anon key
   - `JWT_TOKEN`: Admin JWT token
3. See [Postman Setup Guide](../api/POSTMAN_SETUP.md)

### Q: Getting "row-level security policy violation" error?

A:
- Ensure you're authenticated (include JWT token)
- Check that RLS policies exist (run migrations)
- Verify your user has admin role

### Q: CORS errors when calling API from browser?

A: Supabase handles CORS automatically. If you see errors:
- Check your Supabase project URL is correct
- Verify API keys are correct
- Check browser console for specific error

## Deployment

### Q: How do I deploy to Firebase Hosting?

A:
```bash
flutter build web --release
firebase deploy --only hosting
```

See [Deployment Guide](DEPLOYMENT.md) for details.

### Q: Build fails. What should I do?

A:
- Run `flutter clean`
- Run `flutter pub get`
- Check Flutter version: `flutter --version`
- Verify all dependencies are compatible

### Q: Images not loading after deployment?

A:
- Check image URLs are correct
- Verify storage buckets are public
- Check CORS settings
- Ensure image files exist in storage

## Troubleshooting

### Q: App shows "Supabase not initialized"

A:
- Check `.env` file exists and has correct values
- Verify `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- Restart the app after changing `.env`

### Q: Analytics not working

A:
- Check Firebase is configured
- Verify `ENABLE_ANALYTICS=true` in `.env`
- Check Firebase console for events
- Ensure Firebase config is correct

### Q: Blog posts not showing

A:
- Check blog status is "published"
- Verify `is_published=true` in database
- Check RLS policies allow public read
- Verify blog has `published_at` date

## General

### Q: Can I customize the theme?

A: Yes! See [Design System Guide](../guides/DESIGN_SYSTEM.md) for customization options.

### Q: How do I add a new language?

A:
1. Add locale files in `lib/l10n/`
2. Update `pubspec.yaml` with locale
3. Configure in app settings

### Q: Where can I get help?

A:
- Check relevant documentation in `docs/`
- Review [Setup Guide](SETUP.md)
- Open an issue on GitHub

---

**Still have questions?** Open an issue on GitHub!

