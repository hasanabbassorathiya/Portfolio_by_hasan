# Resume Parser Setup Guide

## Overview

The resume parser feature allows you to upload a PDF resume and automatically extract information to populate your portfolio sections:
- Personal information (name, email, phone, location, title, bio)
- Work experience
- Skills
- Education
- Social links
- Projects

## Current Status

✅ **IMPLEMENTED**: The feature now uses a Supabase Edge Function for server-side PDF parsing, avoiding dependency conflicts and working on all platforms.

**See `RESUME_PARSER_EDGE_FUNCTION_SETUP.md` for complete setup instructions.**

## Quick Start

1. Create `resumes` bucket in Supabase Storage
2. Run migration: `supabase/migrations/009_create_resumes_bucket.sql`
3. Deploy Edge Function: `supabase/functions/parse-resume/index.ts`
4. Test the feature in Admin → Profile → "Parse Resume"

## Alternative Approaches

If you prefer client-side parsing, here are the options:

## Option 1: Client-Side PDF Parsing (Recommended for Development)

### Step 1: Add PDF Parsing Package

Due to dependency conflicts, you'll need to resolve the `go_router` version issue first, then add a PDF parsing package:

```bash
# Option A: Use pdf_text (if compatible)
flutter pub add pdf_text

# Option B: Use doc_text_extractor (supports PDF, DOCX, etc.)
flutter pub add doc_text_extractor

# Option C: Use extract_text (simple, supports PDF)
flutter pub add extract_text
```

### Step 2: Update Resume Parser Service

Once you've added a package, update `lib/core/services/resume_parser_service.dart`:

**For pdf_text:**
```dart
import 'package:pdf_text/pdf_text.dart' as pdf_text;

static Future<ParsedResumeData> parseResumeFromFile(String filePath) async {
  final doc = await pdf_text.PdfDoc.fromFile(filePath);
  final text = await doc.text;
  return _parseText(text);
}

static Future<ParsedResumeData> parseResumeFromBytes(List<int> bytes) async {
  final doc = await pdf_text.PdfDoc.fromData(bytes);
  final text = await doc.text;
  return _parseText(text);
}
```

**For doc_text_extractor:**
```dart
import 'package:doc_text_extractor/doc_text_extractor.dart';

static Future<ParsedResumeData> parseResumeFromFile(String filePath) async {
  final extractor = DocTextExtractor();
  final text = await extractor.extractText(filePath);
  return _parseText(text);
}

static Future<ParsedResumeData> parseResumeFromBytes(List<int> bytes) async {
  // doc_text_extractor may need file path, so you might need to save bytes temporarily
  // or use a different approach for web
  throw UnimplementedError('Use parseResumeFromFile for this package');
}
```

## Option 2: Server-Side PDF Parsing (Recommended for Production)

Use a Supabase Edge Function or external API to parse PDFs server-side. This is more reliable and doesn't require client-side dependencies.

### Using Supabase Edge Function

1. Create a Supabase Edge Function that uses a PDF parsing library (Node.js)
2. Upload the PDF to Supabase Storage
3. Call the Edge Function to parse the PDF
4. Return structured JSON data

### Using External API

Services like:
- **hireparse.com** - AI-powered resume parsing API
- **resumeparserplus.com** - Resume parsing with API access
- **hirize.hr** - Resume parser with 95% accuracy

## Setup Steps

### 1. Create Resumes Storage Bucket

In Supabase Dashboard:
1. Go to Storage
2. Create a new bucket named `resumes`
3. Set it to public or configure RLS policies

### 2. Add Storage Policy (if needed)

Run this SQL in Supabase SQL Editor:

```sql
-- Allow authenticated users to upload resumes
CREATE POLICY "Authenticated users can upload resumes"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'resumes');

-- Allow public to read resumes (or restrict as needed)
CREATE POLICY "Public can read resumes"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'resumes');
```

### 3. Fix Dependency Issues

If you encounter dependency conflicts:
1. Check your `pubspec.yaml` for version constraints
2. Update `go_router` or other conflicting packages
3. Run `flutter pub get`

### 4. Test the Feature

1. Go to Admin → Profile
2. Click "Parse Resume" button
3. Upload a PDF resume
4. Review the extracted data
5. Click "Apply to Portfolio" to populate sections

## How It Works

1. **Upload**: User selects a PDF resume file
2. **Parse**: PDF text is extracted using the parsing package
3. **Extract**: Text is analyzed using regex patterns to find:
   - Personal info (email, phone, name patterns)
   - Work experience (company, position, dates)
   - Skills (common technology keywords)
   - Education (degree patterns)
   - Social links (URL patterns)
   - Projects (project section patterns)
4. **Preview**: User reviews extracted data
5. **Apply**: Data is saved to respective database tables:
   - `profiles` table for personal info
   - `experiences` table for work experience
   - `social_links` table for social media links
   - Resume PDF is saved to Storage

## Limitations

- PDF parsing accuracy depends on resume format
- Complex layouts may not parse correctly
- Dates and experience parsing may need manual correction
- Skills extraction relies on keyword matching

## Future Enhancements

- AI-powered parsing using OpenAI or similar
- Support for DOCX and other formats
- Better date parsing
- Skill extraction from context
- Automatic categorization of projects

## Troubleshooting

### "PDF parsing not yet implemented" error
- Add a PDF parsing package (see Option 1 above)
- Or implement server-side parsing (see Option 2)

### Dependency conflicts
- Check `pubspec.yaml` for version constraints
- Try updating packages: `flutter pub upgrade`
- Consider using a different PDF parsing package

### Parsing accuracy issues
- Ensure resume has clear sections
- Use standard resume formats
- Manually review and correct extracted data
- Consider using AI-powered parsing services

