# Portfolio CMS Implementation Plan

## Overview
This document outlines the implementation plan for converting the static portfolio website into a dynamic, API-driven, portable, and reusable CMS solution using Supabase as the backend.

## Architecture

### 1. Backend (Supabase)
- **Database**: PostgreSQL with Row Level Security (RLS)
- **Storage**: Supabase Storage for images/assets
- **API**: Auto-generated REST APIs + Custom Edge Functions
- **Authentication**: Supabase Auth (for admin panel)

### 2. Frontend (Flutter Web)
- **State Management**: Provider/ChangeNotifier
- **API Client**: Supabase Flutter SDK
- **Localization**: Flutter intl package
- **Caching**: Local storage for offline support

### 3. Data Flow
```
Supabase Database → Supabase API → Flutter Service Layer → Repository → UI
```

## Database Schema

### Tables

#### 1. `profiles`
Stores portfolio owner information
```sql
- id (uuid, primary key)
- name (text)
- title (text)
- bio (text)
- email (text)
- phone (text)
- location (text)
- avatar_url (text)
- resume_url (text)
- created_at (timestamp)
- updated_at (timestamp)
```

#### 2. `social_links`
Stores social media links
```sql
- id (uuid, primary key)
- profile_id (uuid, foreign key)
- platform (text) -- facebook, twitter, instagram, linkedin
- url (text)
- icon_url (text)
- order_index (integer)
- created_at (timestamp)
- updated_at (timestamp)
```

#### 3. `services`
Stores service offerings
```sql
- id (uuid, primary key)
- title (text)
- description (text)
- icon_url (text)
- order_index (integer)
- is_active (boolean)
- created_at (timestamp)
- updated_at (timestamp)
```

#### 4. `works` (projects)
Stores portfolio projects
```sql
- id (uuid, primary key)
- title (text)
- category (text)
- description (text)
- image_url (text)
- project_url (text)
- client (text)
- year (text)
- role (text)
- challenge (text)
- solution (text)
- tags (text[]) -- array of tags
- technologies (text[]) -- array of technologies
- images (text[]) -- array of image URLs
- order_index (integer)
- is_featured (boolean)
- is_active (boolean)
- created_at (timestamp)
- updated_at (timestamp)
```

#### 5. `blogs`
Stores blog posts
```sql
- id (uuid, primary key)
- title (text)
- slug (text, unique)
- content (text)
- excerpt (text)
- image_url (text)
- author (text)
- read_time (text)
- category (text)
- tags (text[])
- published_at (timestamp)
- is_published (boolean)
- views_count (integer)
- created_at (timestamp)
- updated_at (timestamp)
```

#### 6. `testimonials`
Stores client testimonials
```sql
- id (uuid, primary key)
- client_name (text)
- client_role (text)
- client_company (text)
- client_image_url (text)
- quote (text)
- rating (integer) -- 1-5
- order_index (integer)
- is_active (boolean)
- created_at (timestamp)
- updated_at (timestamp)
```

#### 7. `experiences`
Stores work experience
```sql
- id (uuid, primary key)
- company (text)
- position (text)
- description (text)
- start_date (date)
- end_date (date, nullable)
- is_current (boolean)
- order_index (integer)
- created_at (timestamp)
- updated_at (timestamp)
```

#### 8. `contact_messages`
Stores contact form submissions
```sql
- id (uuid, primary key)
- name (text)
- email (text)
- message (text)
- attachment_url (text, nullable)
- is_read (boolean)
- created_at (timestamp)
```

#### 9. `localizations`
Stores multi-language content
```sql
- id (uuid, primary key)
- table_name (text) -- profiles, services, works, blogs, etc.
- record_id (uuid)
- locale (text) -- en, ar, fr, etc.
- field_name (text) -- title, description, etc.
- translated_value (text)
- created_at (timestamp)
- updated_at (timestamp)
```

#### 10. `settings`
Stores global settings
```sql
- id (uuid, primary key)
- key (text, unique)
- value (jsonb)
- description (text)
- created_at (timestamp)
- updated_at (timestamp)
```

## API Endpoints Structure

### Public Endpoints (No Auth Required)
- `GET /profiles` - Get profile information
- `GET /social-links` - Get social links
- `GET /services` - Get all services
- `GET /works` - Get all works (with filters)
- `GET /works/:id` - Get work by ID
- `GET /blogs` - Get all published blogs
- `GET /blogs/:slug` - Get blog by slug
- `GET /testimonials` - Get active testimonials
- `GET /experiences` - Get all experiences
- `POST /contact-messages` - Submit contact form

### Admin Endpoints (Auth Required)
- All CRUD operations for all tables
- `POST /upload` - Upload images/files
- `GET /analytics` - Get analytics data

## Localization Strategy

### 1. Database Level
- Use `localizations` table for translatable fields
- Default language: English (en)
- Supported languages: Configurable via settings

### 2. Application Level
- Use Flutter's `intl` package
- Store translations in JSON files
- Support RTL languages (Arabic, Hebrew)

### 3. Implementation
- Language switcher in UI
- Store user preference in localStorage
- API requests include `Accept-Language` header

## Portability & Reusability

### 1. Configuration Files
- `.env.example` - Environment variables template
- `supabase/config.toml` - Supabase configuration
- `setup.sh` / `setup.ps1` - Setup scripts

### 2. Database Migrations
- SQL migration files in `supabase/migrations/`
- Versioned migrations
- Seed data scripts

### 3. Documentation
- `README.md` - Setup instructions
- `API_DOCUMENTATION.md` - API reference
- `DEPLOYMENT.md` - Deployment guide

### 4. Scripts
- `scripts/setup.sh` - Initial setup script
- `scripts/migrate.sh` - Database migration script
- `scripts/seed.sh` - Seed data script
- `scripts/deploy.sh` - Deployment script

## Implementation Steps

### Phase 1: Setup & Configuration
1. ✅ Create implementation plan
2. Add Supabase dependencies
3. Create environment configuration
4. Set up Supabase project structure

### Phase 2: Database & API
1. Create database schema
2. Set up Row Level Security (RLS)
3. Create Supabase service layer
4. Implement API abstraction

### Phase 3: Frontend Integration
1. Update models for Supabase
2. Create repository pattern with Supabase
3. Implement localization system
4. Update UI to use dynamic data

### Phase 4: Portability & Scripts
1. Create setup scripts
2. Create migration scripts
3. Create seed data scripts
4. Write comprehensive documentation

### Phase 5: Testing & Deployment
1. Test all CRUD operations
2. Test localization
3. Test portability
4. Deploy to production

## Security Considerations

1. **Row Level Security (RLS)**: Enable RLS on all tables
2. **API Keys**: Store in environment variables
3. **CORS**: Configure properly for web
4. **Rate Limiting**: Implement on contact form
5. **Input Validation**: Validate all inputs
6. **File Upload**: Validate file types and sizes

## Performance Optimizations

1. **Caching**: Implement caching strategy
2. **Image Optimization**: Use Supabase Image Transformations
3. **Pagination**: Implement for lists
4. **Lazy Loading**: Load images on demand
5. **CDN**: Use Supabase CDN for assets

## Future Enhancements

1. Admin dashboard (Flutter web)
2. Analytics integration
3. SEO optimization
4. Email notifications
5. Blog comments system
6. Search functionality

