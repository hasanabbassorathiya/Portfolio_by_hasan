# Postman Troubleshooting Guide

## 🔴 Error: "requested path is invalid"

This error means Postman can't reach your Supabase API. Here's how to fix it:

### Step 1: Verify Your BASE_URL Format

Your `BASE_URL` should be in this exact format:
```
https://your-project-id.supabase.co/rest/v1
```

**Common mistakes:**
- ❌ `https://your-project.supabase.co` (missing `/rest/v1`)
- ❌ `https://your-project.supabase.co/api` (wrong path)
- ❌ `http://your-project.supabase.co/rest/v1` (should be `https`)
- ✅ `https://your-project-id.supabase.co/rest/v1` (correct)

### Step 2: Get Your Correct Supabase URL

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Go to **Settings** → **API**
4. Look for **Project URL** - it should look like:
   ```
   https://abcdefghijklmnop.supabase.co
   ```
5. Copy this URL and add `/rest/v1` at the end:
   ```
   https://abcdefghijklmnop.supabase.co/rest/v1
   ```

### Step 3: Update Postman Environment

1. In Postman, click **Environments** (left sidebar)
2. Click on your environment to edit it
3. Find `BASE_URL` variable
4. Update it to: `https://your-actual-project-id.supabase.co/rest/v1`
5. Click **Save**

### Step 4: Test the URL Directly

Test if your URL works by opening it in a browser:
```
https://your-project-id.supabase.co/rest/v1/
```

You should see a JSON response (even if it's an error, it means the URL is correct).

### Step 5: Verify Request Headers

Make sure your request has these headers:
- `apikey: {{ANON_KEY}}`
- `Content-Type: application/json`

### Step 6: Test with a Simple Request

Try the simplest endpoint first:

**Get Profile:**
- Method: `GET`
- URL: `{{BASE_URL}}/profiles`
- Headers:
  - `apikey: {{ANON_KEY}}`
  - `Content-Type: application/json`

If this works, your BASE_URL is correct!

## 🔴 Error: "JWT expired" or "401 Unauthorized"

### Solution: Get a Fresh JWT Token

#### Method 1: Using Admin Dashboard (Easiest)

1. Run your Flutter app:
   ```bash
   flutter run -d chrome
   ```

2. Go to: `http://localhost:port/admin/login`

3. Login with your admin credentials

4. Once logged in, go to the **Dashboard** tab in admin panel

5. You'll see a **JWT Token Helper** card with your token

6. Click the **Copy** button to copy the token

7. In Postman:
   - Go to **Environments**
   - Edit your environment
   - Update `JWT_TOKEN` variable with the copied token
   - Save

#### Method 2: Using Supabase Auth API

1. In Postman, create a new request:
   - Method: `POST`
   - URL: `https://your-project-id.supabase.co/auth/v1/token?grant_type=password`
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

3. In the response, find `access_token`

4. Copy the `access_token` value

5. Update `JWT_TOKEN` in Postman environment

#### Method 3: Using Browser DevTools

1. Login to admin panel in browser

2. Open DevTools (F12)

3. Go to **Application** tab → **Local Storage**

4. Look for keys starting with `sb-` or `supabase`

5. Find the one containing `access_token` or `auth-token`

6. Copy the token value

## 🔴 Error: "Missing API key"

### Solution:

1. Make sure `ANON_KEY` is set in your Postman environment
2. Verify the environment is selected (top right dropdown)
3. Check that requests include `apikey: {{ANON_KEY}}` header

## 🔴 Error: "Row Level Security policy violation"

### Solution:

This means your RLS policies are blocking the request. Check:

1. **For Public Endpoints:**
   - Go to Supabase Dashboard → **Authentication** → **Policies**
   - Make sure public read policies exist for tables like `profiles`, `works`, `blogs`, etc.

2. **For Admin Endpoints:**
   - Make sure you're authenticated (JWT token is valid)
   - Check that authenticated user policies exist

## 🔴 Error: "relation does not exist"

### Solution:

The database tables haven't been created yet. Run migrations:

1. If using Supabase CLI:
   ```bash
   supabase db push
   ```

2. Or manually in Supabase Dashboard:
   - Go to **SQL Editor**
   - Run the SQL from `supabase/migrations/001_initial_schema.sql`
   - Then run `003_analytics_and_config.sql`

## ✅ Quick Verification Checklist

Before testing endpoints, verify:

- [ ] `BASE_URL` ends with `/rest/v1`
- [ ] `BASE_URL` uses `https://` (not `http://`)
- [ ] `ANON_KEY` is set and correct
- [ ] Environment is selected in Postman (top right)
- [ ] Database migrations have been run
- [ ] For admin endpoints: `JWT_TOKEN` is set and not expired

## 🧪 Test Your Setup

### Test 1: Public Endpoint (No Auth)

**Get Profile:**
```
GET {{BASE_URL}}/profiles
Headers:
  apikey: {{ANON_KEY}}
  Content-Type: application/json
```

**Expected:** Should return profile data or empty array `[]`

### Test 2: Admin Endpoint (With Auth)

**Update Profile:**
```
PATCH {{BASE_URL}}/profiles?id=eq.YOUR_PROFILE_ID
Headers:
  apikey: {{ANON_KEY}}
  Authorization: Bearer {{JWT_TOKEN}}
  Content-Type: application/json
Body:
  {
    "name": "Test Name"
  }
```

**Expected:** Should return updated profile data

## 📝 Common URL Patterns

### Correct ✅
```
https://abcdefghijklmnop.supabase.co/rest/v1/profiles
https://abcdefghijklmnop.supabase.co/rest/v1/works
https://abcdefghijklmnop.supabase.co/rest/v1/blogs
```

### Incorrect ❌
```
https://abcdefghijklmnop.supabase.co/profiles  (missing /rest/v1)
https://app.supabase.com/project/xxx/rest/v1/profiles  (wrong format)
http://abcdefghijklmnop.supabase.co/rest/v1/profiles  (should be https)
```

## 🆘 Still Having Issues?

1. **Check Supabase Dashboard:**
   - Go to **Logs** → **API Logs**
   - See what errors are being logged

2. **Test in Browser:**
   - Try accessing: `https://your-project-id.supabase.co/rest/v1/profiles?apikey=YOUR_ANON_KEY`
   - Should return JSON data

3. **Verify Project is Active:**
   - Make sure your Supabase project isn't paused
   - Check project status in dashboard

4. **Check Network:**
   - Make sure you can access Supabase (not blocked by firewall)

