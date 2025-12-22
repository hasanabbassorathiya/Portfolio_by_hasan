# Password Reset Link Expired/Invalid - Fix Guide

## Problem

When clicking the password reset link from email, you see:
- "Invalid or expired reset link"
- "OTP invalid" 
- "Link is expired"

## Root Cause

The redirect URL in Supabase must match **exactly** (including port number for localhost). If it doesn't match, Supabase can't establish the recovery session.

## Solution

### Step 1: Get Your Exact Redirect URL

When you click "Forgot Password?" on the login page, check the browser console. You should see:
```
[AdminLogin] Generated redirect URL: http://localhost:52387/admin/reset-password
```

**Copy this exact URL** (including the port number).

### Step 2: Configure Redirect URL in Supabase

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Navigate to **Authentication** → **URL Configuration**
4. In the **Redirect URLs** section, add:

   **For your current session:**
   ```
   http://localhost:52387/admin/reset-password
   ```

   **For other localhost ports (add multiple):**
   ```
   http://localhost:*/admin/reset-password
   http://127.0.0.1:*/admin/reset-password
   ```

   **For production:**
   ```
   https://hasan-abbas-portfolio.web.app/admin/reset-password
   https://hasan-abbas-portfolio.firebaseapp.com/admin/reset-password
   ```

5. **Important**: The URL must match **exactly**, including:
   - Protocol (`http://` or `https://`)
   - Host (`localhost` or your domain)
   - Port number (for localhost: `:52387`)
   - Path (`/admin/reset-password`)

6. Click **Save**

### Step 3: Verify Site URL

Also check the **Site URL** field:
- For local development: `http://localhost:52387` (with your current port)
- For production: `https://hasan-abbas-portfolio.web.app`

### Step 4: Test Again

1. Go to `/admin/login`
2. Click "Forgot Password?"
3. Check your email
4. Click the reset link
5. You should now be able to reset your password

## Alternative: Use a Fixed Port

If the port keeps changing, you can run Flutter with a fixed port:

```bash
flutter run -d chrome --web-port=8080
```

Then add to Supabase:
```
http://localhost:8080/admin/reset-password
```

## Debugging

### Check Console Logs

When you click the reset link, open browser console (F12) and look for:

```
[AdminResetPassword] Full URL: http://localhost:52387/admin/reset-password#access_token=...
[AdminResetPassword] Token check - token_hash: true, access_token: true
[AdminResetPassword] Session established after 500ms
```

If you see "Token found but no session", the redirect URL doesn't match.

### Common Issues

1. **Port mismatch**: URL has port `52387` but Supabase has `8080`
   - **Fix**: Add the exact URL with the correct port

2. **Protocol mismatch**: URL uses `http://` but Supabase has `https://`
   - **Fix**: Use `http://` for localhost, `https://` for production

3. **Path mismatch**: URL has `/admin/reset-password` but Supabase has `/admin/login`
   - **Fix**: Update Supabase to use `/admin/reset-password`

4. **Token expired**: Link was sent more than 1 hour ago
   - **Fix**: Request a new password reset

5. **Token already used**: Link was clicked before
   - **Fix**: Request a new password reset

## Quick Fix Checklist

- [ ] Check browser console for the exact redirect URL
- [ ] Add that exact URL to Supabase Redirect URLs
- [ ] Ensure Site URL matches your app URL
- [ ] Request a new password reset email
- [ ] Click the new link within 1 hour
- [ ] Check console logs for session establishment

## Still Not Working?

1. **Clear browser cache and cookies**
2. **Try in incognito/private mode**
3. **Check Supabase logs**: Dashboard → Logs → Auth Logs
4. **Verify email is confirmed**: Dashboard → Authentication → Users

---

**Note**: The redirect URL is now automatically generated with the correct port. Just make sure it's added to Supabase's allowed redirect URLs list.

