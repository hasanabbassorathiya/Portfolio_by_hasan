# Admin Panel Guide

## Overview

The admin panel provides a complete content management system for your portfolio. Access it at `/admin/login` (or `/admin/dashboard` if already logged in).

## Features

### 1. **Authentication**
- Secure login using Supabase Auth
- Session management
- Protected admin routes

### 2. **Dashboard**
- Overview statistics
- Quick access to all management sections

### 3. **Content Management**

#### Blogs
- Create, edit, and delete blog posts
- Set publish status
- Manage content, images, tags, and categories
- Auto-generate slugs from titles

#### Works/Projects
- Manage portfolio projects
- Set featured status
- Organize with order index
- Add project details (client, year, role, etc.)

#### Experiences
- Manage work experience entries
- Set current/previous positions
- Add company and role details

#### Testimonials
- Add client testimonials
- Manage testimonial display order
- Set active/inactive status

#### Services
- Manage service offerings
- Set active status
- Organize display order

#### Profile
- Update personal information
- Manage social links
- Update contact details

#### Contacts
- View all contact form submissions
- Mark messages as read/unread
- View message details

## Setup Instructions

### 1. Create Admin User

You need to create an admin user in Supabase:

**Option A: Using Supabase Dashboard**
1. Go to Supabase Dashboard → Authentication → Users
2. Click "Add user" → "Create new user"
3. Enter email and password
4. Save the credentials

**Option B: Using SQL**
```sql
-- Create admin user (replace with your email and password)
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'admin@example.com',
  crypt('your-password', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW()
);
```

### 2. Set Up Admin Policies

Update Row Level Security policies to allow admin access:

```sql
-- Allow authenticated users to manage content
CREATE POLICY "Admins can manage blogs"
  ON blogs FOR ALL
  USING (auth.role() = 'authenticated');

CREATE POLICY "Admins can manage works"
  ON works FOR ALL
  USING (auth.role() = 'authenticated');

CREATE POLICY "Admins can manage experiences"
  ON experiences FOR ALL
  USING (auth.role() = 'authenticated');

CREATE POLICY "Admins can manage testimonials"
  ON testimonials FOR ALL
  USING (auth.role() = 'authenticated');

CREATE POLICY "Admins can manage services"
  ON services FOR ALL
  USING (auth.role() = 'authenticated');

CREATE POLICY "Admins can manage profiles"
  ON profiles FOR ALL
  USING (auth.role() = 'authenticated');

-- Allow admins to read all contact messages
CREATE POLICY "Admins can read contact messages"
  ON contact_messages FOR SELECT
  USING (auth.role() = 'authenticated');
```

### 3. Access the Admin Panel

1. Navigate to `/admin/login` in your app
2. Enter your admin email and password
3. You'll be redirected to the dashboard

## Usage

### Adding Content

1. **Blogs**: Click "Blogs" → "Add New Blog"
   - Fill in title, content, image URL
   - Add tags, category, author
   - Set publish status
   - Click "Save"

2. **Works**: Click "Works" → "Add New Work"
   - Fill in project details
   - Add images, tags, technologies
   - Set featured/active status
   - Click "Save"

3. **Experiences**: Click "Experiences" → "Add Experience"
   - Enter company, position, dates
   - Add description
   - Click "Save"

### Editing Content

1. Navigate to the relevant section
2. Click the edit icon on any item
3. Modify the fields
4. Click "Save"

### Deleting Content

1. Navigate to the relevant section
2. Click the delete icon
3. Confirm deletion

### Managing Contact Messages

1. Click "Contacts" in the sidebar
2. View all submitted messages
3. Click on a message to view details
4. Mark as read/unread using the icon

## Image Management

### Uploading Images

1. Go to Supabase Dashboard → Storage
2. Create buckets: `works`, `blogs`, `avatars`
3. Upload images
4. Copy the public URL
5. Use the URL in your content forms

### Image URLs Format

```
https://your-project.supabase.co/storage/v1/object/public/works/image.jpg
```

## Security Notes

- Admin routes are protected by authentication
- Only logged-in users can access admin panel
- RLS policies control database access
- Contact messages are read-only for admins

## Troubleshooting

### Can't Login
- Verify user exists in Supabase Auth
- Check email/password are correct
- Ensure RLS policies allow authenticated access

### Can't Save Content
- Check RLS policies are set correctly
- Verify you're logged in
- Check browser console for errors

### Images Not Loading
- Verify image URLs are correct
- Check storage bucket policies allow public read
- Ensure images are uploaded to Supabase Storage

## Next Steps

1. Create your admin user
2. Set up RLS policies
3. Start adding content!
4. Customize the admin panel as needed

