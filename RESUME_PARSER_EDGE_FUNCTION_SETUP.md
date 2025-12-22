# Resume Parser Edge Function Setup

## Overview

The resume parser now uses a Supabase Edge Function for server-side PDF parsing. This approach:
- ✅ Avoids dependency conflicts
- ✅ Works on all platforms (web, mobile, desktop)
- ✅ More reliable than client-side parsing
- ✅ Can be enhanced with better PDF parsing libraries

## Setup Steps

### 1. Create Resumes Storage Bucket

1. Go to Supabase Dashboard → Storage
2. Click "New bucket"
3. Name: `resumes`
4. Public: `true` (or configure RLS policies)
5. Click "Create bucket"

### 2. Run Storage Policies Migration

Run the SQL migration to set up storage policies:

```bash
# In Supabase SQL Editor, run:
supabase/migrations/009_create_resumes_bucket.sql
```

Or manually run:
```sql
-- Allow authenticated users to upload resumes
CREATE POLICY "Authenticated users can upload resumes"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'resumes');

-- Allow public to read resumes
CREATE POLICY "Public can read resumes"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'resumes');
```

### 3. Deploy Edge Function

#### Option A: Using Supabase CLI (Recommended)

```bash
# Install Supabase CLI if not already installed
# npm install -g supabase

# Login to Supabase
supabase login

# Link your project
supabase link --project-ref your-project-ref

# Deploy the function
supabase functions deploy parse-resume
```

#### Option B: Using Supabase Dashboard

1. Go to Supabase Dashboard → Edge Functions
2. Click "Create a new function"
3. Name: `parse-resume`
4. Copy the code from `supabase/functions/parse-resume/index.ts`
5. Click "Deploy"

### 4. Test the Function

You can test the Edge Function using the Supabase Dashboard:

1. Go to Edge Functions → `parse-resume`
2. Click "Invoke function"
3. Use this test payload:
```json
{
  "fileUrl": "https://your-supabase-url.supabase.co/storage/v1/object/public/resumes/test-resume.pdf",
  "bucket": "resumes",
  "fileName": "test-resume.pdf"
}
```

## How It Works

1. **User uploads PDF** → File is uploaded to Supabase Storage (`resumes` bucket)
2. **Edge Function called** → Client calls the `parse-resume` Edge Function with file URL
3. **PDF parsed server-side** → Edge Function downloads PDF and extracts text
4. **Data extracted** → Text is analyzed using regex patterns
5. **Structured data returned** → JSON response with parsed resume data
6. **Client displays preview** → User reviews extracted data
7. **Data applied** → User clicks "Apply" to populate portfolio sections

## Current Implementation

The Edge Function uses basic PDF text extraction. For production, consider:

### Enhanced PDF Parsing Options

1. **Use pdfjs-dist** (Recommended)
   ```typescript
   import { getDocument } from 'https://cdn.skypack.dev/pdfjs-dist';
   
   const pdf = await getDocument({ data: bytes }).promise;
   let text = '';
   for (let i = 1; i <= pdf.numPages; i++) {
     const page = await pdf.getPage(i);
     const textContent = await page.getTextContent();
     text += textContent.items.map(item => item.str).join(' ');
   }
   ```

2. **Use external API** (Most reliable)
   - Integrate with hireparse.com, resumeparserplus.com, or hirize.hr
   - These services provide high-accuracy parsing

3. **Use Deno PDF library**
   - Search for Deno-compatible PDF parsing libraries
   - Example: `https://deno.land/x/pdfjs`

## Troubleshooting

### "Function not found" error
- Ensure the Edge Function is deployed
- Check the function name matches: `parse-resume`
- Verify you're using the correct Supabase project

### "Failed to download file" error
- Check that the `resumes` bucket exists
- Verify storage policies allow reading
- Ensure the file URL is correct

### "Could not extract text from PDF" error
- PDF might be image-based (scanned)
- Try using OCR or an external parsing service
- Ensure PDF contains selectable text

### Parsing accuracy issues
- Current implementation uses basic regex patterns
- Consider upgrading to AI-powered parsing
- Manually review and correct extracted data

## Next Steps

1. ✅ Create `resumes` bucket
2. ✅ Run storage policies migration
3. ✅ Deploy Edge Function
4. ✅ Test with a sample resume
5. 🔄 (Optional) Enhance PDF parsing with better libraries
6. 🔄 (Optional) Add OCR support for scanned PDFs

## Testing

After setup, test the feature:

1. Go to Admin → Profile
2. Click "Parse Resume"
3. Upload a PDF resume
4. Review extracted data
5. Click "Apply to Portfolio"

The feature should now work end-to-end! 🎉

