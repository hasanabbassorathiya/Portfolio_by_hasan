# Deploy Resume Parser Edge Function

## Quick Deploy (Supabase Dashboard - Recommended)

1. **Go to Supabase Dashboard**
   - Visit: https://supabase.com/dashboard
   - Select your project: `hasan-abbas-portfolio` (or your project name)

2. **Navigate to Edge Functions**
   - Click "Edge Functions" in the left sidebar
   - If you don't see it, click "More" → "Edge Functions"

3. **Create New Function**
   - Click "Create a new function" or "Deploy a function"
   - Function name: `parse-resume` (must match exactly)

4. **Copy Function Code**
   - Open: `supabase/functions/parse-resume/index.ts`
   - Copy ALL the code
   - Paste into the function editor in Supabase Dashboard

5. **Deploy**
   - Click "Deploy" button
   - Wait for deployment to complete (usually 30-60 seconds)

6. **Verify Deployment**
   - You should see the function in the list
   - Status should show as "Active" or "Deployed"

## Deploy via CLI (Alternative)

### Prerequisites
```bash
# Install Supabase CLI
npm install -g supabase

# Or using Homebrew (Mac)
brew install supabase/tap/supabase
```

### Steps

1. **Login to Supabase**
   ```bash
   supabase login
   ```

2. **Link Your Project**
   ```bash
   # Get your project reference ID from Supabase Dashboard URL
   # Example: https://supabase.com/dashboard/project/bxdoymhgeoelidgqialg
   # Project ref: bxdoymhgeoelidgqialg
   
   supabase link --project-ref bxdoymhgeoelidgqialg
   ```

3. **Deploy the Function**
   ```bash
   cd /Users/macbookm1pro/StudioProjects/portfolio
   supabase functions deploy parse-resume
   ```

4. **Verify**
   ```bash
   supabase functions list
   ```

## Test the Function

After deployment, test it:

1. **Via Supabase Dashboard**
   - Go to Edge Functions → `parse-resume`
   - Click "Invoke function"
   - Use this test payload:
   ```json
   {
     "fileUrl": "https://bxdoymhgeoelidgqialg.supabase.co/storage/v1/object/public/resumes/resume_1766507786614.pdf",
     "bucket": "resumes",
     "fileName": "resume_1766507786614.pdf"
   }
   ```

2. **Via Your App**
   - Go to Admin → Resume Intake
   - Upload a PDF resume
   - It should now parse successfully!

## Troubleshooting

### "Function not found" error
- ✅ Ensure function name is exactly `parse-resume`
- ✅ Check function is deployed and active
- ✅ Verify you're using the correct Supabase project

### "Failed to download file" error
- ✅ Ensure `resumes` bucket exists in Storage
- ✅ Check storage policies allow reading
- ✅ Verify file URL is correct

### "Could not extract text from PDF" error
- ✅ PDF must contain selectable text (not scanned images)
- ✅ Try a different PDF file
- ✅ Check function logs in Supabase Dashboard

### CORS errors
- ✅ Function already includes CORS headers
- ✅ If issues persist, check browser console for specific CORS errors

## Function Location

The Edge Function code is located at:
```
supabase/functions/parse-resume/index.ts
```

## Environment Variables

The function automatically uses:
- `SUPABASE_URL` - From your project settings
- `SUPABASE_SERVICE_ROLE_KEY` - From your project settings

These are automatically provided by Supabase when the function runs.

## Next Steps

Once deployed:
1. ✅ Function will be accessible at: `https://bxdoymhgeoelidgqialg.supabase.co/functions/v1/parse-resume`
2. ✅ Your Flutter app will automatically use it
3. ✅ Resume parsing will work in Admin → Resume Intake

