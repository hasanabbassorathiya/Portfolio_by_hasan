#!/bin/bash

# Setup Firebase Secrets for GitHub Actions
# This script helps you set up GitHub secrets for Firebase deployment

echo "🔧 Firebase GitHub Secrets Setup"
echo "=================================="
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "Install it from: https://cli.github.com/"
    echo ""
    echo "Alternatively, you can set secrets manually:"
    echo "1. Go to your GitHub repo → Settings → Secrets and variables → Actions"
    echo "2. Add each secret manually"
    exit 1
fi

echo "✅ GitHub CLI found"
echo ""

# Check if logged in
if ! gh auth status &> /dev/null; then
    echo "❌ Not logged in to GitHub CLI"
    echo "Run: gh auth login"
    exit 1
fi

echo "✅ Logged in to GitHub"
echo ""

# Get repository name
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
if [ -z "$REPO" ]; then
    echo "❌ Could not determine repository"
    echo "Make sure you're in a git repository"
    exit 1
fi

echo "📦 Repository: $REPO"
echo ""

# Service Account Key
echo "📝 Setting up FIREBASE_SERVICE_ACCOUNT"
echo "----------------------------------------"
echo "Enter the path to your Firebase service account JSON file:"
read -r SERVICE_ACCOUNT_PATH

if [ ! -f "$SERVICE_ACCOUNT_PATH" ]; then
    echo "❌ File not found: $SERVICE_ACCOUNT_PATH"
    exit 1
fi

echo "Setting secret..."
gh secret set FIREBASE_SERVICE_ACCOUNT < "$SERVICE_ACCOUNT_PATH"
echo "✅ FIREBASE_SERVICE_ACCOUNT set"
echo ""

# Supabase URL
echo "📝 Setting up SUPABASE_URL"
echo "----------------------------------------"
echo "Enter your Supabase URL (e.g., https://xxxxx.supabase.co):"
read -r SUPABASE_URL

if [ -z "$SUPABASE_URL" ]; then
    echo "❌ SUPABASE_URL cannot be empty"
    exit 1
fi

gh secret set SUPABASE_URL <<< "$SUPABASE_URL"
echo "✅ SUPABASE_URL set"
echo ""

# Supabase Anon Key
echo "📝 Setting up SUPABASE_ANON_KEY"
echo "----------------------------------------"
echo "Enter your Supabase anon key:"
read -r SUPABASE_ANON_KEY

if [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "❌ SUPABASE_ANON_KEY cannot be empty"
    exit 1
fi

gh secret set SUPABASE_ANON_KEY <<< "$SUPABASE_ANON_KEY"
echo "✅ SUPABASE_ANON_KEY set"
echo ""

# Optional secrets
echo "📝 Optional Secrets"
echo "----------------------------------------"
echo "Would you like to set optional secrets? (y/n)"
read -r SET_OPTIONAL

if [ "$SET_OPTIONAL" = "y" ] || [ "$SET_OPTIONAL" = "Y" ]; then
    echo ""
    echo "APP_NAME (default: Portfolio):"
    read -r APP_NAME
    if [ -n "$APP_NAME" ]; then
        gh secret set APP_NAME <<< "$APP_NAME"
        echo "✅ APP_NAME set"
    fi

    echo ""
    echo "DEFAULT_LOCALE (default: en):"
    read -r DEFAULT_LOCALE
    if [ -n "$DEFAULT_LOCALE" ]; then
        gh secret set DEFAULT_LOCALE <<< "$DEFAULT_LOCALE"
        echo "✅ DEFAULT_LOCALE set"
    fi

    echo ""
    echo "SUPPORTED_LOCALES (default: en, comma-separated):"
    read -r SUPPORTED_LOCALES
    if [ -n "$SUPPORTED_LOCALES" ]; then
        gh secret set SUPPORTED_LOCALES <<< "$SUPPORTED_LOCALES"
        echo "✅ SUPPORTED_LOCALES set"
    fi
fi

echo ""
echo "✅ All secrets configured!"
echo ""
echo "📋 Summary:"
echo "  - FIREBASE_SERVICE_ACCOUNT: ✅"
echo "  - SUPABASE_URL: ✅"
echo "  - SUPABASE_ANON_KEY: ✅"
if [ "$SET_OPTIONAL" = "y" ] || [ "$SET_OPTIONAL" = "Y" ]; then
    echo "  - Optional secrets: ✅"
fi
echo ""
echo "🚀 Ready to deploy! Push to main branch to trigger deployment."

