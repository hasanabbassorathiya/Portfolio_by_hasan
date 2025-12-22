# Password Reset Setup Guide

## Overview

The admin login page now includes a "Forgot Password?" feature that allows users to reset their password via email.

## Prerequisites

1. ✅ Supabase project configured
2. ✅ Admin user created in Supabase
3. ✅ Email service configured in Supabase

## Configuration Steps

### 1. Configure Redirect URLs in Supabase

**Important**: Supabase requires redirect URLs to be whitelisted for security.

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Navigate to **Authentication** → **URL Configuration**
4. Add your redirect URLs to the **Redirect URLs** list:

   **For Local Development:**
   ```
   http://localhost:*/admin/login
   http://127.0.0.1:*/admin/login
   ```

   **For Production:**
   ```
   https://your-domain.com/admin/login
   https://hasan-abbas-portfolio.web.app/admin/login
   https://hasan-abbas-portfolio.firebaseapp.com/admin/login
   ```

5. **Site URL** should be set to your main domain:
   ```
   https://hasan-abbas-portfolio.web.app
   ```

### 2. Configure Email Templates

1. Go to **Authentication** → **Email Templates**
2. Find the **Reset Password** template
3. Ensure it includes the reset link:
   ```html
   <a href="{{ .SiteURL }}/auth/confirm?token_hash={{ .TokenHash }}&type=recovery&next={{ .RedirectTo }}">
     Reset Password
   </a>
   ```

### 3. Verify Email Service

1. Go to **Settings** → **Auth**
2. Check **Enable Email Confirmations** is enabled
3. Verify **SMTP Settings** (if using custom SMTP):
   - Host
   - Port
   - Username
   - Password
   - Sender email

**Note**: Supabase provides a free email service, but for production, consider using a custom SMTP provider (SendGrid, Mailgun, etc.).

## Testing Password Reset

### Step 1: Test the Feature

1. Navigate to `/admin/login`
2. Enter your admin email address
3. Click **"Forgot Password?"**
4. Check the console for debug logs:
   ```
   [AdminLogin] Attempting to send password reset email
   [AdminLogin] Redirect URL: http://localhost:xxxx/admin/login
   [AdminLogin] Password reset email sent successfully
   ```

### Step 2: Check Email

1. Check your inbox for the reset email
2. **Also check spam/junk folder**
3. The email should come from: `noreply@mail.app.supabase.io` (default) or your custom SMTP sender

### Step 3: Reset Password

1. Click the reset link in the email
2. You'll be redirected to your app
3. Enter your new password
4. Confirm the new password
5. Log in with the new password

## Troubleshooting

### Issue: "No email received"

**Possible Causes:**

1. **Email not in Supabase users**
   - Solution: Verify the email exists in **Authentication** → **Users**
   - Supabase sends emails even for non-existent users (for security), but the link won't work

2. **Redirect URL not whitelisted**
   - Solution: Add the redirect URL to Supabase **Authentication** → **URL Configuration**

3. **Email in spam folder**
   - Solution: Check spam/junk folder
   - Add `noreply@mail.app.supabase.io` to your contacts

4. **SMTP not configured**
   - Solution: Check **Settings** → **Auth** → **SMTP Settings**
   - For production, configure a custom SMTP provider

### Issue: "Redirect URL not configured" error

**Solution:**
1. Check browser console for the actual redirect URL being used
2. Add that exact URL to Supabase **Authentication** → **URL Configuration**
3. Include both `http://` and `https://` versions if needed
4. Include port numbers for local development (e.g., `:8080`, `:3000`)

### Issue: "User not found" when clicking reset link

**Solution:**
1. Verify the email exists in Supabase **Authentication** → **Users**
2. Ensure the user's email is confirmed
3. Try creating a new admin user if needed

### Issue: Reset link doesn't work

**Possible Causes:**

1. **Link expired** (default: 1 hour)
   - Solution: Request a new reset email

2. **Redirect URL mismatch**
   - Solution: Ensure the redirect URL in the email matches your whitelisted URLs exactly

3. **Token already used**
   - Solution: Request a new reset email

## Debug Information

The app logs detailed information to help troubleshoot:

- **Success**: `[AdminLogin] Password reset email sent successfully`
- **Error**: `[AdminLogin] Failed to send password reset email` with full error details
- **Redirect URL**: Shows the redirect URL being used

Check browser console (F12 → Console) for these logs.

## Security Notes

1. **Rate Limiting**: Supabase limits password reset requests to prevent abuse
2. **Token Expiry**: Reset tokens expire after 1 hour (configurable in Supabase)
3. **One-time Use**: Reset tokens can only be used once
4. **Email Verification**: Users must have verified email addresses

## Next Steps

After configuring:

1. ✅ Test password reset flow end-to-end
2. ✅ Verify email delivery
3. ✅ Test reset link functionality
4. ✅ Confirm new password works for login

---

**Status**: ✅ Password reset feature implemented
**Last Updated**: After adding "Forgot Password?" button to admin login

