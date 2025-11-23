#!/bin/bash

# Portfolio CMS Setup Script
# This script helps set up the portfolio project with Supabase

set -e

echo "🚀 Portfolio CMS Setup Script"
echo "=============================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file from .env.example...${NC}"
    cp .env.example .env
    echo -e "${GREEN}✓ Created .env file${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Please update .env with your Supabase credentials:${NC}"
    echo "   - SUPABASE_URL"
    echo "   - SUPABASE_ANON_KEY"
    echo ""
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}✗ Flutter is not installed. Please install Flutter first.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Flutter is installed${NC}"

# Get Flutter dependencies
echo ""
echo "📦 Installing Flutter dependencies..."
flutter pub get

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Flutter dependencies installed${NC}"
else
    echo -e "${RED}✗ Failed to install Flutter dependencies${NC}"
    exit 1
fi

# Check if Supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo ""
    echo -e "${YELLOW}Supabase CLI is not installed.${NC}"
    echo "Would you like to install it? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Installing Supabase CLI..."
        # Install Supabase CLI (adjust for your OS)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            brew install supabase/tap/supabase
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            echo "Please install Supabase CLI manually: https://supabase.com/docs/guides/cli"
        else
            echo "Please install Supabase CLI manually: https://supabase.com/docs/guides/cli"
        fi
    fi
else
    echo -e "${GREEN}✓ Supabase CLI is installed${NC}"
fi

# Database setup instructions
echo ""
echo "📊 Database Setup"
echo "=================="
echo ""
echo "To set up the database:"
echo "1. Create a Supabase project at https://supabase.com"
echo "2. Copy your project URL and anon key to .env file"
echo "3. Run the migration scripts:"
echo ""
echo "   Option A: Using Supabase Dashboard"
echo "   - Go to SQL Editor in your Supabase dashboard"
echo "   - Run the SQL files from supabase/migrations/ in order"
echo ""
echo "   Option B: Using Supabase CLI"
echo "   - Run: supabase db push"
echo ""

# Generate code (if using code generation)
if [ -f "pubspec.yaml" ] && grep -q "build_runner" pubspec.yaml; then
    echo ""
    echo "🔨 Generating code..."
    flutter pub run build_runner build --delete-conflicting-outputs
    echo -e "${GREEN}✓ Code generation complete${NC}"
fi

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Update .env with your Supabase credentials"
echo "2. Run database migrations"
echo "3. Start the app: flutter run -d chrome"
echo ""

