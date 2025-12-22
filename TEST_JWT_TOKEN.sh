#!/bin/bash

# Test if JWT token contains user ID
# This helps debug why auth.uid() might not be working

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}Testing JWT Token Contents...${NC}\n"

# Load .env
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

EMAIL="hasanabbassorathiya12@gmail.com"
PASSWORD="Arrow@2013"

echo -e "${BLUE}Step 1: Authenticating...${NC}"
AUTH_RESPONSE=$(curl -s -X POST \
  "${SUPABASE_URL}/auth/v1/token?grant_type=password" \
  -H "apikey: ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"email\": \"${EMAIL}\", \"password\": \"${PASSWORD}\"}")

JWT_TOKEN=$(echo "$AUTH_RESPONSE" | jq -r '.access_token' 2>/dev/null)
USER_ID=$(echo "$AUTH_RESPONSE" | jq -r '.user.id' 2>/dev/null)

if [ -z "$JWT_TOKEN" ]; then
    echo -e "${RED}✗ Authentication failed${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Authenticated${NC}"
echo "  User ID from response: $USER_ID"
echo ""

echo -e "${BLUE}Step 2: Decoding JWT token (payload only)...${NC}"
# JWT has 3 parts: header.payload.signature
# Extract payload (2nd part) and decode
PAYLOAD=$(echo "$JWT_TOKEN" | cut -d'.' -f2)

# Add padding if needed
case $((${#PAYLOAD} % 4)) in
  2) PAYLOAD="${PAYLOAD}==" ;;
  3) PAYLOAD="${PAYLOAD}=" ;;
esac

# Decode base64
DECODED=$(echo "$PAYLOAD" | base64 -d 2>/dev/null)

echo "JWT Payload (decoded):"
echo "$DECODED" | jq '.' 2>/dev/null || echo "$DECODED"
echo ""

# Extract sub (user ID) from JWT
JWT_USER_ID=$(echo "$DECODED" | jq -r '.sub' 2>/dev/null)
echo -e "${BLUE}User ID from JWT (sub claim): $JWT_USER_ID${NC}"
echo ""

if [ "$USER_ID" = "$JWT_USER_ID" ]; then
    echo -e "${GREEN}✓ User ID matches between response and JWT${NC}"
else
    echo -e "${RED}✗ User ID mismatch!${NC}"
fi

echo ""
echo -e "${YELLOW}If auth.uid() is not working, the JWT might not be properly validated by Supabase.${NC}"
echo "This could happen if:"
echo "1. The JWT secret key is misconfigured"
echo "2. The JWT is being sent incorrectly"
echo "3. There's a mismatch between the JWT issuer and Supabase config"

