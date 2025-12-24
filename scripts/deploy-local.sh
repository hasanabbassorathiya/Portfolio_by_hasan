#!/bin/bash

# Local Firebase Deployment Script
# Use this to test deployment locally before pushing to GitHub

set -e

echo "🚀 Local Firebase Deployment"
echo "============================="
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI is not installed"
    echo "Install it with: npm install -g firebase-tools"
    exit 1
fi

echo "✅ Firebase CLI found"
echo ""

# Check if logged in
if ! firebase projects:list &> /dev/null; then
    echo "❌ Not logged in to Firebase"
    echo "Run: firebase login"
    exit 1
fi

echo "✅ Logged in to Firebase"
echo ""

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "⚠️  Warning: .env file not found"
    echo "Environment variables will use defaults"
    echo ""
else
    echo "✅ .env file found"
    # Load environment variables
    export $(cat .env | grep -v '^#' | xargs)
    echo ""
fi

# Build Flutter web app
echo "📦 Building Flutter web app..."

# Check if .env file exists and extract values
if [ -f ".env" ]; then
    SUPABASE_URL=$(grep "^SUPABASE_URL=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
    SUPABASE_ANON_KEY=$(grep "^SUPABASE_ANON_KEY=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
    APP_NAME=$(grep "^APP_NAME=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
    DEFAULT_LOCALE=$(grep "^DEFAULT_LOCALE=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
    SUPPORTED_LOCALES=$(grep "^SUPPORTED_LOCALES=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
    ENABLE_ANALYTICS=$(grep "^ENABLE_ANALYTICS=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
    ENABLE_CRASH_REPORTING=$(grep "^ENABLE_CRASH_REPORTING=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
    
    # Set defaults if not found
    APP_NAME=${APP_NAME:-"Hasan Abbas Sorathiya"}
    DEFAULT_LOCALE=${DEFAULT_LOCALE:-"en"}
    SUPPORTED_LOCALES=${SUPPORTED_LOCALES:-"en,ar,fr"}
    ENABLE_ANALYTICS=${ENABLE_ANALYTICS:-"true"}
    ENABLE_CRASH_REPORTING=${ENABLE_CRASH_REPORTING:-"true"}
    
    if [ -n "$SUPABASE_URL" ] && [ -n "$SUPABASE_ANON_KEY" ]; then
        echo "✅ Using environment variables from .env"
        echo "   SUPABASE_URL: ${SUPABASE_URL:0:30}..."
        echo "   APP_NAME: $APP_NAME"
        echo ""
        flutter clean
        flutter pub get
        flutter build web --release \
            --base-href / \
            --dart-define=SUPABASE_URL="$SUPABASE_URL" \
            --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
            --dart-define=APP_NAME="$APP_NAME" \
            --dart-define=DEFAULT_LOCALE="$DEFAULT_LOCALE" \
            --dart-define=SUPPORTED_LOCALES="$SUPPORTED_LOCALES" \
            --dart-define=ENABLE_ANALYTICS="$ENABLE_ANALYTICS" \
            --dart-define=ENABLE_CRASH_REPORTING="$ENABLE_CRASH_REPORTING" \
            --source-maps
    else
        echo "❌ SUPABASE_URL or SUPABASE_ANON_KEY not found in .env"
        echo "   Please ensure your .env file contains:"
        echo "   SUPABASE_URL=https://your-project.supabase.co"
        echo "   SUPABASE_ANON_KEY=your-anon-key"
        exit 1
    fi
else
    echo "❌ .env file not found"
    echo "   Please create a .env file with your Supabase credentials"
    exit 1
fi

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✅ Build successful"
echo ""

# Deploy to Firebase
echo "🚀 Deploying to Firebase Hosting..."
firebase deploy --only hosting

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Deployment successful!"
    echo ""
    echo "🌐 Your site is live at:"
    echo "   https://hasan-abbas-portfolio.web.app"
    echo "   https://hasan-abbas-portfolio.firebaseapp.com"
else
    echo "❌ Deployment failed"
    exit 1
fi

