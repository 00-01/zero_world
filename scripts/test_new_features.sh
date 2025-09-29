#!/bin/bash

echo "🧪 Testing Zero World New Features"
echo "=================================="

BASE_URL="https://www.zn-01.com/api"
echo "Testing API at: $BASE_URL"

echo ""
echo "1. Testing Health Check..."
HEALTH=$(curl -s -k "$BASE_URL/health")
echo "Health: $HEALTH"

echo ""
echo "2. Testing Listings Endpoint..."
LISTINGS=$(curl -s -k "$BASE_URL/listings/")
echo "Listings: $LISTINGS"

echo ""
echo "3. Testing Auth Endpoints..."

# Test registration
echo "Registering test user..."
REG_RESPONSE=$(curl -s -k -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "testpass123"
  }')
echo "Registration: $REG_RESPONSE"

# Test login
echo ""
echo "Testing login..."
LOGIN_RESPONSE=$(curl -s -k -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d 'username=test@example.com&password=testpass123')
echo "Login: $LOGIN_RESPONSE"

# Extract token (if login successful)
if echo "$LOGIN_RESPONSE" | grep -q "access_token"; then
  TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"access_token":"[^"]*' | cut -d'"' -f4)
  echo "Token extracted: ${TOKEN:0:20}..."
  
  echo ""
  echo "4. Testing Authenticated Endpoints..."
  
  # Test profile
  echo "Getting profile..."
  PROFILE=$(curl -s -k "$BASE_URL/auth/me" \
    -H "Authorization: Bearer $TOKEN")
  echo "Profile: $PROFILE"
  
  # Create a test listing
  echo ""
  echo "Creating test listing..."
  LISTING=$(curl -s -k -X POST "$BASE_URL/listings/" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
      "title": "Test Item",
      "description": "A test item for sale",
      "price": 99.99,
      "category": "Electronics",
      "location": "Test City"
    }')
  echo "Listing created: $LISTING"
  
  # Extract listing ID
  if echo "$LISTING" | grep -q '"_id"'; then
    LISTING_ID=$(echo "$LISTING" | grep -o '"_id":"[^"]*' | cut -d'"' -f4)
    echo "Listing ID: $LISTING_ID"
    
    echo ""
    echo "5. Testing Listing Chat Feature..."
    
    # Test starting a chat about the listing (this should fail since it's our own listing)
    echo "Testing chat with own listing (should fail)..."
    CHAT_RESPONSE=$(curl -s -k -X POST "$BASE_URL/chat/listing/$LISTING_ID" \
      -H "Authorization: Bearer $TOKEN")
    echo "Chat response: $CHAT_RESPONSE"
  fi
fi

echo ""
echo "✅ Testing Complete!"
echo ""
echo "🌐 You can now:"
echo "  1. Visit https://www.zn-01.com to see the website"
echo "  2. Click 'Log in' to access the authentication system"
echo "  3. Create listings and chat with other users"
echo "  4. Click on listings to see the 'Contact Seller' button"