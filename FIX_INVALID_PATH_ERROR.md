# 🔴 Fix "requested path is invalid" Error

## The Problem

You're seeing this error in Postman:
```json
{
    "error": "requested path is invalid"
}
```

**This means your `BASE_URL` is wrong!**

## ✅ The Solution (3 Steps)

### Step 1: Get Your Supabase Project URL

1. Go to [https://app.supabase.com](https://app.supabase.com)
2. **Select your project** (or create one if you don't have one)
3. Click **Settings** (gear icon in left sidebar)
4. Click **API** (under Project Settings)
5. Find **Project URL** - it looks like this:
   ```
   https://abcdefghijklmnop.supabase.co
   ```
6. **Copy this entire URL**

### Step 2: Add `/rest/v1` to the End

Your `BASE_URL` MUST end with `/rest/v1`

**Example:**
- ❌ Wrong: `https://abcdefghijklmnop.supabase.co`
- ✅ Correct: `https://abcdefghijklmnop.supabase.co/rest/v1`

### Step 3: Update Postman Environment

1. Open **Postman**
2. Click **Environments** (left sidebar)
3. Click on your environment to **edit** it
4. Find the `BASE_URL` variable
5. **Replace** the value with: `https://your-project-id.supabase.co/rest/v1`
   - Replace `your-project-id` with your actual project ID from Step 1
6. Click **Save**

## 🧪 Test It

1. In Postman, select your environment (top right dropdown)
2. Open: **Portfolio CMS API** → **Public Endpoints** → **Get Profile**
3. Click **Send**
4. You should see data (or empty array `[]`) - NOT an error!

## 📸 Visual Guide

### What Your BASE_URL Should Look Like:

```
https://abcdefghijklmnop.supabase.co/rest/v1
│                                    │      │
│                                    │      └─ MUST have this
│                                    └─ Your project ID (from Supabase)
└─ Always https://
```

### Common Mistakes:

❌ **Wrong:**
```
https://your-project.supabase.co
https://app.supabase.com/project/xxx
http://your-project.supabase.co/rest/v1
https://your-project.supabase.co/api
```

✅ **Correct:**
```
https://abcdefghijklmnop.supabase.co/rest/v1
```

## 🔍 How to Verify Your URL is Correct

### Test in Browser:

1. Open a new browser tab
2. Type: `https://your-project-id.supabase.co/rest/v1/`
3. You should see a JSON response (even if it's an error, it means the URL is correct!)
4. If you see "404" or "not found", the URL is wrong

### Test in Postman:

**Request:**
- Method: `GET`
- URL: `{{BASE_URL}}/profiles`
- Headers:
  - `apikey: {{ANON_KEY}}`
  - `Content-Type: application/json`

**Expected Response:**
- ✅ Success: `[]` or `[{...}]` (array of profiles)
- ❌ Error: `{"error": "requested path is invalid"}` (BASE_URL is wrong)

## 🆘 Still Not Working?

### Check These:

1. **Is BASE_URL set correctly?**
   - Must end with `/rest/v1`
   - Must use `https://` (not `http://`)
   - Must have your actual project ID

2. **Is environment selected?**
   - Top right dropdown in Postman
   - Must show your environment name

3. **Is ANON_KEY set?**
   - Should be your Supabase anon key
   - Get from: Supabase Dashboard → Settings → API

4. **Does your project exist?**
   - Go to Supabase Dashboard
   - Make sure project is active (not paused)

5. **Test the URL directly:**
   - Open: `https://your-project-id.supabase.co/rest/v1/profiles?apikey=YOUR_ANON_KEY`
   - Should return JSON data

## 📝 Quick Checklist

- [ ] Got Project URL from Supabase Dashboard
- [ ] Added `/rest/v1` to the end
- [ ] Updated `BASE_URL` in Postman environment
- [ ] Saved the environment
- [ ] Selected the environment (top right)
- [ ] Tested "Get Profile" endpoint
- [ ] Got data or empty array (not error)

## ✅ Success!

Once you fix the `BASE_URL`, you should see:
- ✅ No more "requested path is invalid" error
- ✅ API responses with data
- ✅ Can test all endpoints

---

**Still having issues?** Check `POSTMAN_TROUBLESHOOTING.md` for more help!

