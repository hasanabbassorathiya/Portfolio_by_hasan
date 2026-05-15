#!/bin/bash

# scripts/deployToFirebase.sh
# Automates reading .env variables and deploying the Flutter web app to Firebase.

# Ensure we are in the project root
if [ ! -f "pubspec.yaml" ]; then
    echo "Error: Must run this script from the project root directory."
    exit 1
fi

# Load .env file
if [ -f .env ]; then
  # Use a safer way to load .env variables
  set -a
  source .env
  set +a
else
  echo "Error: .env file not found."
  exit 1
fi

echo "Debug: TURSO_URL length: ${#TURSO_URL}"
if [ ${#TURSO_URL} -eq 0 ]; then
  echo "Error: TURSO_URL is empty. Check .env file."
  exit 1
fi

echo "Building Flutter Web with environment variables..."

# Build
flutter build web --dart-define=TURSO_URL="$TURSO_URL" \
                  --dart-define=TURSO_TOKEN="$TURSO_TOKEN" \
                  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
                  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"

if [ $? -ne 0 ]; then
    echo "Error: Flutter build failed."
    exit 1
fi

echo "Deploying to Firebase..."

# Deploy
npx firebase-tools deploy --only hosting

if [ $? -eq 0 ]; then
    echo "Successfully deployed!"
else
    echo "Error: Firebase deployment failed."
    exit 1
fi
