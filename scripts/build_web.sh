#!/bin/bash
set -e

echo "Building portfolio for web with Turso DB..."

# Read .env
if [ ! -f ".env" ]; then
  echo "ERROR: .env file not found"
  exit 1
fi

TURSO_URL=$(grep "^TURSO_URL=" .env | cut -d '=' -f2- | tr -d '"' | tr -d "'" | xargs)
TURSO_TOKEN=$(grep "^TURSO_TOKEN=" .env | cut -d '=' -f2- | tr -d '"' | tr -d "'" | xargs)

if [ -z "$TURSO_URL" ] || [ -z "$TURSO_TOKEN" ]; then
  echo "ERROR: TURSO_URL or TURSO_TOKEN missing from .env"
  exit 1
fi

echo "TURSO_URL: ${TURSO_URL:0:40}..."
echo "TURSO_TOKEN: ${TURSO_TOKEN:0:20}..."

flutter pub get
flutter build web --no-tree-shake-icons --no-pub \
  --dart-define=TURSO_URL="$TURSO_URL" \
  --dart-define=TURSO_TOKEN="$TURSO_TOKEN"

echo ""
echo "Build complete. Deploy with: firebase deploy --only hosting"
