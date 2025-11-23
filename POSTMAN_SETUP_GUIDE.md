# Postman Collection Setup Guide

> **🔴 Getting "requested path is invalid" error?** See `FIX_INVALID_PATH_ERROR.md` for a quick fix!

## Step 1: Configure Postman Environment Variables

After importing the collection, you need to set up environment variables:

### Create a New Environment in Postman

1. Click on **Environments** in the left sidebar
2. Click **+** to create a new environment
3. Name it "Portfolio CMS" or "Local Development"

### Add These Variables

| Variable Name | Initial Value | Current Value | Description |
|--------------|---------------|---------------|-------------|
| `BASE_URL` | `https://your-project.supabase.co/rest/v1` | `https://your-project.supabase.co/rest/v1` | Your Supabase project URL |
| `ANON_KEY` | `YOUR_SUPABASE_ANON_KEY` | `YOUR_SUPABASE_ANON_KEY` | Your Supabase anon key |
| `JWT_TOKEN` | (leave empty) | (will be filled after login) | JWT token from admin login |

### How to Get Your Supabase Credentials

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Go to **Settings** → **API**
4. Copy:
   - **Project URL** → Use for `BASE_URL`
   - **anon/public key** → Use for `ANON_KEY`

### Set the Environment

1. Select your environment from the dropdown (top right in Postman)
2. Make sure it's active (highlighted)

## Step 2: Test Public Endpoints (No Auth Required)

### Test Get Profile

1. Open the collection: **Portfolio CMS API** → **Public Endpoints** → **Get Profile**
2. Click **Send**
3. You should see the profile data (or empty if no profile exists)

### Test Get All Works

1. Open **Get All Works**
2. Click **Send**
3. You should see a list of works (or empty array)

### Test Other Public Endpoints

Try these in order:
- Get All Blogs
- Get All Services
- Get All Experiences
- Get All Testimonials
- Get Social Links

## Step 3: Get JWT Token for Admin Endpoints

### Option A: Use Admin Panel (Recommended)

1. Run your Flutter app:
   ```bash
   flutter run -d chrome
   ```

2. Navigate to: `http://localhost:port/admin/login`

3. Login with your admin credentials

4. Open browser DevTools (F12) → **Application** → **Local Storage**

5. Look for Supabase auth token or check Network tab for Authorization header

6. Copy the JWT token

7. In Postman, update the `JWT_TOKEN` variable in your environment

### Option B: Use Supabase Auth API

1. In Postman, create a new request:
   - Method: `POST`
   - URL: `https://your-project.supabase.co/auth/v1/token?grant_type=password`
   - Headers:
     ```
     apikey: YOUR_ANON_KEY
     Content-Type: application/json
     ```
   - Body (raw JSON):
     ```json
     {
       "email": "your-admin-email@example.com",
       "password": "your-password"
     }
     ```

2. Send the request

3. Copy the `access_token` from the response

4. Update `JWT_TOKEN` in Postman environment

## Step 4: Test Admin Endpoints

Now you can test admin endpoints that require authentication:

### Test Update Profile

1. Open **Admin Endpoints** → **Update Profile**
2. The request should automatically use `{{JWT_TOKEN}}` from your environment
3. Modify the request body with your data
4. Click **Send**

### Test Create Work

1. Open **Create Work**
2. Modify the JSON body with your project data
3. Click **Send**
4. You should get the created work back

### Test Other Admin Endpoints

Try:
- Create Blog
- Create Service
- Create Experience
- Create Testimonial
- Create Social Link
- Get Analytics Data
- Get Contact Messages

## Step 5: Using Variables in Requests

The collection uses variables like `{{WORK_ID}}` and `{{BLOG_ID}}`. To use them:

1. After creating a work/blog, copy its `id` from the response
2. In your environment, add a new variable:
   - `WORK_ID` = the id you copied
   - `BLOG_ID` = the id you copied
3. Now requests like "Get Work by ID" will use that ID automatically

## Common Issues & Solutions

### Issue: "requested path is invalid"

**This is the most common error!** It means your `BASE_URL` is incorrect.

**Solution:**
1. Your `BASE_URL` MUST end with `/rest/v1`
2. Format: `https://your-project-id.supabase.co/rest/v1`
3. Get your project URL from Supabase Dashboard → Settings → API
4. See `POSTMAN_TROUBLESHOOTING.md` for detailed fix

**Quick Fix:**
- ❌ Wrong: `https://your-project.supabase.co`
- ✅ Correct: `https://your-project.supabase.co/rest/v1`

### Issue: "JWT expired" or "401 Unauthorized"

**Solution:**
- Your JWT token has expired (they expire after some time)
- Get a new token using Option A or B from Step 3
- Update `JWT_TOKEN` in your environment

### Issue: "Missing API key"

**Solution:**
- Make sure `ANON_KEY` is set in your environment
- Make sure the environment is selected (top right dropdown)
- Check that the request headers include `apikey: {{ANON_KEY}}`

### Issue: "requested path is invalid" (Most Common!)

**This means your BASE_URL is wrong!**

**Quick Fix:**
1. Go to Supabase Dashboard → Settings → API
2. Copy your **Project URL** (e.g., `https://abc123.supabase.co`)
3. Add `/rest/v1` to the end: `https://abc123.supabase.co/rest/v1`
4. Update `BASE_URL` in Postman environment
5. Save and try again

**See `POSTMAN_TROUBLESHOOTING.md` for detailed troubleshooting.**

### Issue: "404 Not Found"

**Solution:**
- Check that `BASE_URL` is correct
- Make sure you've run database migrations (`supabase db push`)
- Verify the table exists in Supabase dashboard

### Issue: "Row Level Security policy violation"

**Solution:**
- Make sure RLS policies are set up correctly
- For admin endpoints, ensure you're authenticated
- Check Supabase dashboard → **Authentication** → **Policies**

## Quick Test Checklist

- [ ] Environment variables set (`BASE_URL`, `ANON_KEY`)
- [ ] Environment is selected in Postman
- [ ] Can GET profile (public endpoint)
- [ ] Can GET works (public endpoint)
- [ ] JWT token obtained and set
- [ ] Can UPDATE profile (admin endpoint)
- [ ] Can CREATE work (admin endpoint)
- [ ] Can GET analytics (admin endpoint)

## Next Steps

1. **Set up your database**: Run migrations if you haven't
   ```bash
   supabase db push
   ```

2. **Create storage buckets**: In Supabase dashboard → Storage
   - Create: `avatars`, `works`, `blogs`, `services`, `testimonials`

3. **Test the admin panel**: 
   - Login at `/admin/login`
   - Try creating content through the UI
   - Verify it appears in Postman GET requests

4. **Add seed data**: Use the Postman collection to add initial data

## Example: Complete Workflow

1. **Get Profile** (Public) → See current profile
2. **Update Profile** (Admin) → Update your profile
3. **Create Work** (Admin) → Add a new project
4. **Get All Works** (Public) → See your new work
5. **Create Blog** (Admin) → Add a blog post
6. **Get All Blogs** (Public) → See your blog
7. **Submit Contact Form** (Public) → Test contact form
8. **Get Contact Messages** (Admin) → See the message

## Need Help?

- Check `API_DOCUMENTATION.md` for detailed endpoint documentation
- Check `ADMIN_PANEL_GUIDE.md` for admin panel usage
- Check Supabase logs in dashboard for detailed error messages

