# Portfolio CMS API Documentation

> **📖 Quick Start**: See `POSTMAN_SETUP_GUIDE.md` for step-by-step Postman setup instructions.
> **🚀 Getting Started**: See `GETTING_STARTED.md` for complete project setup guide.

## Base URL

```
https://your-project.supabase.co/rest/v1
```

**How to find your Base URL:**
1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Go to **Settings** → **API**
4. Copy the **Project URL** and append `/rest/v1`

## Authentication

All admin endpoints require authentication. Include the JWT token in the Authorization header:

```
Authorization: Bearer YOUR_JWT_TOKEN
```

To get a JWT token:
1. Sign in via `/admin/login` in the admin panel
2. Or use Supabase Auth API to authenticate

## Public Endpoints (No Authentication Required)

### Get Profile

```http
GET /profiles
```

**Response:**
```json
{
  "id": "uuid",
  "name": "Hasan Abbas Sorathiya",
  "title": "Software Engineer",
  "bio": "Hello there!...",
  "email": "hasan@example.com",
  "phone": "+971 58 960 2320",
  "location": "Dubai, UAE",
  "avatar_url": "https://...",
  "resume_url": "https://...",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

**cURL:**
```bash
curl -X GET 'https://your-project.supabase.co/rest/v1/profiles' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json"
```

### Get All Works

```http
GET /works?is_active=eq.true&order=order_index.asc
```

**Query Parameters:**
- `is_active` (boolean): Filter by active status
- `is_featured` (boolean): Filter by featured status
- `order` (string): Order by field (e.g., `order_index.asc`)
- `limit` (integer): Limit number of results
- `offset` (integer): Offset for pagination

**Response:**
```json
[
  {
    "id": "uuid",
    "title": "Bally Website Research",
    "category": "UX case study",
    "description": "...",
    "image_url": "https://...",
    "project_url": "https://...",
    "client": "Bally",
    "year": "2022",
    "role": "Lead UX Designer",
    "tags": ["UX Design", "Research"],
    "technologies": ["Figma", "Adobe XD"],
    "is_featured": true,
    "is_active": true,
    "order_index": 0
  }
]
```

**cURL:**
```bash
curl -X GET 'https://your-project.supabase.co/rest/v1/works?is_active=eq.true&order=order_index.asc' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json"
```

### Get Work by ID

```http
GET /works?id=eq.{id}
```

**cURL:**
```bash
curl -X GET 'https://your-project.supabase.co/rest/v1/works?id=eq.UUID' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json"
```

### Get All Blogs

```http
GET /blogs?is_published=eq.true&order=published_at.desc
```

**Query Parameters:**
- `is_published` (boolean): Filter by published status
- `order` (string): Order by field
- `limit` (integer): Limit number of results
- `offset` (integer): Offset for pagination

**cURL:**
```bash
curl -X GET 'https://your-project.supabase.co/rest/v1/blogs?is_published=eq.true&order=published_at.desc' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json"
```

### Get Blog by Slug

```http
GET /blogs?slug=eq.{slug}
```

**cURL:**
```bash
curl -X GET 'https://your-project.supabase.co/rest/v1/blogs?slug=eq.my-blog-post' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json"
```

### Get All Services

```http
GET /services?is_active=eq.true&order=order_index.asc
```

**cURL:**
```bash
curl -X GET 'https://your-project.supabase.co/rest/v1/services?is_active=eq.true&order=order_index.asc' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json"
```

### Get All Experiences

```http
GET /experiences?order=order_index.asc,start_date.desc
```

**cURL:**
```bash
curl -X GET 'https://your-project.supabase.co/rest/v1/experiences?order=order_index.asc,start_date.desc' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json"
```

### Get All Testimonials

```http
GET /testimonials?is_active=eq.true&order=order_index.asc
```

**cURL:**
```bash
curl -X GET 'https://your-project.supabase.co/rest/v1/testimonials?is_active=eq.true&order=order_index.asc' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json"
```

### Get Social Links

```http
GET /social_links?order=order_index.asc
```

**cURL:**
```bash
curl -X GET 'https://your-project.supabase.co/rest/v1/social_links?order=order_index.asc' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json"
```

### Submit Contact Form

```http
POST /contact_messages
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "message": "Hello, I'm interested in your services.",
  "attachment_url": "https://..." // Optional
}
```

**cURL:**
```bash
curl -X POST 'https://your-project.supabase.co/rest/v1/contact_messages' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "message": "Hello, I am interested in your services."
  }'
```

## Admin Endpoints (Authentication Required)

### Update Profile

```http
PATCH /profiles?id=eq.{id}
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Updated Name",
  "title": "Updated Title",
  "bio": "Updated bio",
  "email": "updated@example.com",
  "phone": "+971 58 960 2320",
  "location": "Dubai, UAE",
  "avatar_url": "https://...",
  "resume_url": "https://..."
}
```

**cURL:**
```bash
curl -X PATCH 'https://your-project.supabase.co/rest/v1/profiles?id=eq.UUID' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{
    "name": "Updated Name",
    "title": "Updated Title"
  }'
```

### Create Work

```http
POST /works
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "New Project",
  "category": "Web Design",
  "description": "Project description",
  "image_url": "https://...",
  "project_url": "https://...",
  "client": "Client Name",
  "year": "2024",
  "role": "Lead Designer",
  "tags": ["Design", "Development"],
  "technologies": ["React", "Node.js"],
  "is_featured": false,
  "is_active": true,
  "order_index": 0
}
```

**cURL:**
```bash
curl -X POST 'https://your-project.supabase.co/rest/v1/works' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{
    "title": "New Project",
    "category": "Web Design",
    "description": "Project description",
    "image_url": "https://...",
    "is_active": true
  }'
```

### Update Work

```http
PATCH /works?id=eq.{id}
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

**cURL:**
```bash
curl -X PATCH 'https://your-project.supabase.co/rest/v1/works?id=eq.UUID' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{
    "title": "Updated Title",
    "is_featured": true
  }'
```

### Delete Work

```http
DELETE /works?id=eq.{id}
Authorization: Bearer YOUR_JWT_TOKEN
```

**cURL:**
```bash
curl -X DELETE 'https://your-project.supabase.co/rest/v1/works?id=eq.UUID' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Create Blog

```http
POST /blogs
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "My Blog Post",
  "slug": "my-blog-post",
  "content": "Blog content here...",
  "excerpt": "Short excerpt",
  "image_url": "https://...",
  "author": "Hasan Abbas Sorathiya",
  "read_time": "5 min read",
  "category": "Design",
  "tags": ["design", "ux"],
  "is_published": true,
  "published_at": "2024-01-01T00:00:00Z"
}
```

**cURL:**
```bash
curl -X POST 'https://your-project.supabase.co/rest/v1/blogs' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Prefer: return=representation" \
  -d '{
    "title": "My Blog Post",
    "slug": "my-blog-post",
    "content": "Blog content...",
    "author": "Hasan Abbas Sorathiya",
    "is_published": true
  }'
```

### Get Analytics Data

```http
GET /page_views?order=created_at.desc&limit=100
Authorization: Bearer YOUR_JWT_TOKEN
```

**cURL:**
```bash
curl -X GET 'https://your-project.supabase.co/rest/v1/page_views?order=created_at.desc&limit=100' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"
```

### Get Contact Messages

```http
GET /contact_messages?order=created_at.desc
Authorization: Bearer YOUR_JWT_TOKEN
```

**cURL:**
```bash
curl -X GET 'https://your-project.supabase.co/rest/v1/contact_messages?order=created_at.desc' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json"
```

### Update Contact Message (Mark as Read)

```http
PATCH /contact_messages?id=eq.{id}
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

**Request Body:**
```json
{
  "is_read": true
}
```

**cURL:**
```bash
curl -X PATCH 'https://your-project.supabase.co/rest/v1/contact_messages?id=eq.UUID' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"is_read": true}'
```

## Storage Endpoints

### Upload Image

```http
POST /storage/v1/object/{bucket}/{path}
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: image/jpeg
```

**cURL:**
```bash
curl -X POST 'https://your-project.supabase.co/storage/v1/object/works/image.jpg' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: image/jpeg" \
  --data-binary @image.jpg
```

### Get Public URL

```
https://your-project.supabase.co/storage/v1/object/public/{bucket}/{path}
```

## Error Responses

All endpoints may return the following error responses:

**400 Bad Request:**
```json
{
  "message": "Error message",
  "code": "PGRST116",
  "details": "..."
}
```

**401 Unauthorized:**
```json
{
  "message": "JWT expired",
  "code": "PGRST301"
}
```

**404 Not Found:**
```json
{
  "message": "The result contains 0 rows",
  "code": "PGRST116"
}
```

## Postman Collection

See `portfolio-api.postman_collection.json` for a complete Postman collection with all endpoints pre-configured.

## Rate Limiting

Supabase has rate limits based on your plan:
- Free tier: 500 requests per second
- Pro tier: Higher limits

## Best Practices

1. **Use Filters**: Always use query parameters to filter data
2. **Pagination**: Use `limit` and `offset` for large datasets
3. **Caching**: Cache responses on the client side when appropriate
4. **Error Handling**: Always handle errors gracefully
5. **Authentication**: Store JWT tokens securely

