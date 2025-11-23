# Getting Started Guide

## 🚀 Quick Start Checklist

Follow these steps in order to get your portfolio CMS up and running:

### 1. Prerequisites ✅

- [ ] Flutter SDK installed
- [ ] Supabase account created
- [ ] Firebase project created (optional, for analytics)
- [ ] Postman installed (for API testing)

### 2. Clone & Setup Project

```bash
# Navigate to your project
cd /Users/macbookm1pro/StudioProjects/portfolio

# Install dependencies
flutter pub get
```

### 3. Configure Supabase

#### 3.1 Get Your Supabase Credentials

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project (or create one)
3. Go to **Settings** → **API**
4. Copy:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key**

#### 3.2 Create `.env` File

Create a `.env` file in the project root:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# App Configuration
APP_NAME=Portfolio
DEFAULT_LOCALE=en
SUPPORTED_LOCALES=en,ar,fr

# Feature Flags
ENABLE_ANALYTICS=true
ENABLE_CRASH_REPORTING=true
```

#### 3.3 Run Database Migrations

```bash
# If you have Supabase CLI installed
supabase db push

# Or manually run migrations in Supabase Dashboard:
# SQL Editor → Run the SQL from supabase/migrations/001_initial_schema.sql
# Then run 003_analytics_and_config.sql
```

#### 3.4 Create Storage Buckets

In Supabase Dashboard → **Storage**:

Create these buckets (make them public):
- `avatars` - for profile images
- `works` - for project images
- `blogs` - for blog images
- `services` - for service icons
- `testimonials` - for client images

For each bucket:
1. Click **New bucket**
2. Name it (e.g., `avatars`)
3. Make it **Public**
4. Click **Create bucket**

### 4. Set Up Admin User

#### Option A: Via Supabase Dashboard

1. Go to **Authentication** → **Users**
2. Click **Add user** → **Create new user**
3. Enter email and password
4. Save the credentials (you'll need them to login)

#### Option B: Via SQL

```sql
-- This will be handled by Supabase Auth
-- Just create a user via the dashboard
```

### 5. Configure Firebase (Optional but Recommended)

#### 5.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project
3. Add a web app to your project
4. Copy the Firebase config

#### 5.2 Add Firebase Config

For Flutter Web, you'll need to configure Firebase in your project. The Firebase service is already set up in the code.

### 6. Run the Application

```bash
# Run on web
flutter run -d chrome

# Or specify a port
flutter run -d chrome --web-port=8080
```

### 7. Access Admin Panel

1. Navigate to: `http://localhost:port/admin/login`
2. Login with your admin credentials
3. You should see the admin dashboard

### 8. Set Up Postman Collection

1. Open Postman
2. Import `portfolio-api.postman_collection.json`
3. See `POSTMAN_SETUP_GUIDE.md` for detailed setup instructions

## 📝 First Steps After Setup

### 1. Create Your Profile

**Via Admin Panel:**
- Go to `/admin/login`
- Navigate to **Profile**
- Fill in your information
- Upload an avatar
- Click **Save Profile**

**Via Postman:**
- Use **Update Profile** endpoint
- Send your profile data

### 2. Add Social Links

**Via Admin Panel:**
- Go to **Social Links**
- Click **Add Social Link**
- Select platform and enter URL
- Save

### 3. Add Services

**Via Admin Panel:**
- Go to **Services**
- Click **Add Service**
- Enter title, description
- Upload icon (optional)
- Set order index
- Save

### 4. Add Works/Projects

**Via Admin Panel:**
- Go to **Works**
- Click **Add Work**
- Fill in project details
- Upload project image
- Save

### 5. Add Experiences

**Via Admin Panel:**
- Go to **Experiences**
- Click **Add Experience**
- Enter company, position, dates
- Save

### 6. Add Testimonials

**Via Admin Panel:**
- Go to **Testimonials**
- Click **Add Testimonial**
- Enter client info and quote
- Set rating
- Save

### 7. Add Blogs (Optional)

**Via Admin Panel:**
- Go to **Blogs**
- Click **Add Blog**
- Write your blog post
- Upload featured image
- Publish when ready

## 🧪 Testing

### Test Public Endpoints

1. Open Postman
2. Use **Get Profile** (should work without auth)
3. Use **Get All Works** (should return your works)
4. Use **Submit Contact Form** (test contact form)

### Test Admin Endpoints

1. Get JWT token (see `POSTMAN_SETUP_GUIDE.md`)
2. Set `JWT_TOKEN` in Postman environment
3. Try **Update Profile** (should work with auth)
4. Try **Create Work** (should create a new work)

### Test Admin Panel

1. Login at `/admin/login`
2. Navigate through all sections
3. Create, edit, delete items
4. Verify changes appear on public site

## 🔍 Verify Everything Works

### Check Database

1. Go to Supabase Dashboard → **Table Editor**
2. Verify tables exist:
   - `profiles`
   - `works`
   - `blogs`
   - `services`
   - `experiences`
   - `testimonials`
   - `social_links`
   - `contact_messages`
   - `page_views`
   - `custom_events`

### Check Storage

1. Go to Supabase Dashboard → **Storage**
2. Verify buckets exist
3. Try uploading an image via admin panel
4. Verify it appears in storage

### Check Analytics

1. Visit your public site pages
2. Go to Admin Panel → **Analytics**
3. You should see page views being tracked

## 🐛 Troubleshooting

### Issue: "Supabase not initialized"

**Solution:**
- Check `.env` file exists and has correct values
- Restart the Flutter app
- Check console for error messages

### Issue: "Can't login to admin panel"

**Solution:**
- Verify user exists in Supabase Auth
- Check email/password are correct
- Verify RLS policies allow authenticated access

### Issue: "Can't upload images"

**Solution:**
- Verify storage buckets exist
- Check buckets are set to public
- Verify RLS policies on storage buckets

### Issue: "API endpoints return 401"

**Solution:**
- Check JWT token is valid (not expired)
- Verify token is set in Postman environment
- Make sure you're using the correct environment

### Issue: "No data showing"

**Solution:**
- Check database has data (Supabase Dashboard)
- Verify RLS policies allow public read
- Check network tab for API errors

## 📚 Next Steps

1. **Customize Design**: Modify theme in `lib/shared/theme/app_theme.dart`
2. **Add More Features**: Extend the admin panel as needed
3. **Deploy**: See deployment guide (to be created)
4. **Monitor**: Check analytics dashboard regularly
5. **Backup**: Set up database backups in Supabase

## 🆘 Need Help?

- **API Issues**: See `API_DOCUMENTATION.md`
- **Admin Panel**: See `ADMIN_PANEL_GUIDE.md`
- **Postman Setup**: See `POSTMAN_SETUP_GUIDE.md`
- **Setup Issues**: See `README_SETUP.md`

## ✅ Success Checklist

- [ ] Project runs without errors
- [ ] Can login to admin panel
- [ ] Can create profile
- [ ] Can add works/services
- [ ] Can upload images
- [ ] Public site shows data
- [ ] Postman collection works
- [ ] Analytics tracking works
- [ ] Contact form works

---

**You're all set! Start adding your content and customizing your portfolio!** 🎉

