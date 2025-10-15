# AI Concierge System - API Endpoints

**Status**: ✅ **IMPLEMENTED** (Backend endpoints ready for testing)  
**Date**: October 15, 2025

---

## 📋 Overview

The AI Concierge API provides REST endpoints and WebSocket connections for managing end-to-end service fulfillment conversations. Users can order food, request rides, book services, and track everything in real-time through a conversational AI interface.

---

## 🚀 Base URL

```
http://localhost:8000/api/concierge
https://www.zn-01.com/api/concierge
```

---

## 🔐 Authentication

All endpoints require authentication via Bearer token:

```http
Authorization: Bearer <your_jwt_token>
```

---

## 📡 API Endpoints

### **CONVERSATION MANAGEMENT**

#### **POST /conversation/start**

Start a new conversation with the AI Concierge.

**Request Body:**
```json
{
  "initial_message": "I want pizza",
  "session_id": "optional-session-id"
}
```

**Response:**
```json
{
  "conversation_id": "conv_123abc",
  "message": "I can help you order pizza! What type would you like?",
  "stage": "category_selection",
  "progress_percentage": 22,
  "suggested_replies": ["Pepperoni", "Veggie", "Show all options"]
}
```

---

####  **POST /conversation/{conversation_id}/message**

Send a message in an ongoing conversation.

**Request Body:**
```json
{
  "message": "I want pepperoni pizza",
  "extracted_data": {
    "food_type": "pizza",
    "specific_item": "pepperoni"
  }
}
```

**Response:**
```json
{
  "conversation_id": "conv_123abc",
  "message": "Great choice! Here are nearby pizzerias...",
  "stage": "item_selection",
  "progress_percentage": 33,
  "collected_data": {
    "service_type": "food_delivery",
    "food_type": "pizza",
    "category": "pepperoni"
  },
  "pending_questions": ["Which restaurant?"],
  "service_options": [
    {
      "id": "rest_1",
      "provider": "mock_food_delivery",
      "name": "Papa's Pizza Palace",
      "description": "Authentic Italian pizza",
      "rating": 4.7,
      "price_level": 2,
      "delivery_time": 30,
      "delivery_fee": 2.99
    }
  ],
  "suggested_replies": ["Papa's Pizza", "See more options"]
}
```

---

#### **GET /conversation/{conversation_id}**

Get the current state of a conversation.

**Response:**
```json
{
  "conversation_id": "conv_123abc",
  "user_id": "user_456",
  "service_type": "food_delivery",
  "provider": "mock_food_delivery",
  "stage": "item_selection",
  "collected_data": {...},
  "pending_questions": ["Which restaurant?"],
  "order_id": null,
  "order_status": null,
  "progress_percentage": 33,
  "created_at": "2025-10-15T12:00:00Z",
  "last_update": "2025-10-15T12:05:00Z"
}
```

---

#### **DELETE /conversation/{conversation_id}/cancel**

Cancel an active conversation.

**Response:**
```json
{
  "message": "Conversation cancelled successfully"
}
```

---

### **SERVICE SEARCH**

#### **GET /services/search**

Search for services across all providers.

**Query Parameters:**
- `category` (required): ServiceCategory enum (FOOD, TRANSPORTATION, etc.)
- `query` (optional): Search query string
- `lat` (optional): Latitude for location-based search
- `lng` (optional): Longitude for location-based search
- `limit` (optional): Max results (default: 10)

**Example:**
```http
GET /api/concierge/services/search?category=FOOD&query=pizza&lat=37.7749&lng=-122.4194&limit=5
```

**Response:**
```json
{
  "results": [
    {
      "id": "rest_1",
      "provider": "mock_food_delivery",
      "name": "Papa's Pizza Palace",
      "description": "Authentic Italian pizza made fresh daily",
      "rating": 4.7,
      "price_level": 2,
      "delivery_time": 30,
      "delivery_fee": 2.99,
      "distance": 1.2,
      "tags": ["Pizza", "Italian", "Fast Delivery"],
      "image_url": "https://example.com/papas-pizza.jpg",
      "available": true
    }
  ],
  "total": 5
}
```

---

#### **GET /services/{service_id}/details**

Get detailed information about a specific service.

**Query Parameters:**
- `provider` (required): Provider name

**Example:**
```http
GET /api/concierge/services/rest_1/details?provider=mock_food_delivery
```

**Response:**
```json
{
  "id": "rest_1",
  "provider": "mock_food_delivery",
  "name": "Papa's Pizza Palace",
  "description": "Authentic Italian pizza made fresh daily",
  "category": "Italian",
  "rating": 4.7,
  "price_level": 2,
  "delivery_time": 30,
  "delivery_fee": 2.99,
  "minimum_order": 15.00,
  "menu_items": [
    {
      "id": "item_1",
      "name": "Pepperoni Pizza",
      "description": "Classic pepperoni with mozzarella",
      "price": 18.99,
      "size": "Large",
      "category": "Pizza",
      "image_url": "https://example.com/pepperoni.jpg",
      "available": true
    }
  ],
  "hours": {...},
  "location": {...},
  "reviews": [...]
}
```

---

#### **POST /services/{service_id}/estimate**

Get a cost estimate for a service.

**Query Parameters:**
- `provider` (required): Provider name

**Request Body:**
```json
{
  "service_id": "rest_1",
  "items": [
    {"id": "item_1", "quantity": 1, "size": "Large"}
  ],
  "delivery_address": {
    "street": "123 Main St",
    "city": "San Francisco",
    "state": "CA",
    "zip": "94102"
  },
  "customizations": {
    "extra_cheese": true
  }
}
```

**Response:**
```json
{
  "subtotal": 18.99,
  "delivery_fee": 2.99,
  "tax": 1.96,
  "tip": 3.00,
  "total": 26.94,
  "estimated_delivery_time": "30-45 minutes",
  "breakdown": {...}
}
```

---

### **ORDER MANAGEMENT**

#### **POST /orders/place**

Place an order through a service provider.

**Request Body:**
```json
{
  "conversation_id": "conv_123abc",
  "service_id": "rest_1",
  "items": [
    {"id": "item_1", "quantity": 1, "size": "Large"}
  ],
  "delivery_address": {
    "street": "123 Main St",
    "city": "San Francisco",
    "state": "CA",
    "zip": "94102",
    "instructions": "Ring doorbell"
  },
  "payment_method_id": "pm_123456",
  "customizations": {
    "extra_cheese": true
  },
  "tip_amount": 3.00,
  "notes": "No onions please"
}
```

**Response:**
```json
{
  "order_id": "order_789xyz",
  "provider_order_id": "PROVIDER_ORDER_123",
  "status": "placed",
  "service_name": "Papa's Pizza Palace",
  "items": [...],
  "subtotal": 18.99,
  "delivery_fee": 2.99,
  "tax": 1.96,
  "tip": 3.00,
  "total": 26.94,
  "estimated_delivery_time": "2025-10-15T13:00:00Z",
  "delivery_address": {...},
  "payment_method": {...},
  "tracking_url": "https://track.example.com/order_789xyz",
  "created_at": "2025-10-15T12:30:00Z"
}
```

---

#### **GET /orders/{order_id}**

Get order details.

**Query Parameters:**
- `provider` (required): Provider name

**Response:**
```json
{
  "order_id": "order_789xyz",
  "status": "in_transit",
  "message": "Your order is on the way! Driver is 5 minutes away.",
  "timestamp": "2025-10-15T12:50:00Z",
  "driver_location": {
    "lat": 37.7749,
    "lng": -122.4194
  },
  "estimated_minutes": 5,
  "metadata": {
    "driver_name": "John",
    "driver_phone": "+1-555-0123",
    "vehicle": "Blue Honda Civic"
  }
}
```

---

#### **GET /orders/{order_id}/status**

Get real-time order status (polling endpoint).

**Query Parameters:**
- `provider` (required): Provider name

**Response:** Same as GET /orders/{order_id}

---

#### **POST /orders/{order_id}/cancel**

Cancel an active order.

**Query Parameters:**
- `provider` (required): Provider name

**Response:**
```json
{
  "message": "Order cancelled successfully"
}
```

---

### **REAL-TIME TRACKING (WebSocket)**

#### **WS /orders/{order_id}/track**

WebSocket endpoint for real-time order tracking.

**Query Parameters:**
- `provider` (required): Provider name

**Connection:**
```javascript
const ws = new WebSocket(
  'ws://localhost:8000/api/concierge/orders/order_789xyz/track?provider=mock_food_delivery'
);

ws.onmessage = (event) => {
  const update = JSON.parse(event.data);
  console.log('Order status:', update.status);
  console.log('Driver location:', update.driver_location);
  console.log('ETA:', update.estimated_minutes, 'minutes');
};
```

**Messages Received:**
```json
{
  "order_id": "order_789xyz",
  "status": "in_transit",
  "message": "Your order is 3 minutes away",
  "timestamp": "2025-10-15T12:52:00Z",
  "driver_location": {
    "lat": 37.7755,
    "lng": -122.4185
  },
  "estimated_minutes": 3
}
```

The WebSocket will automatically close when order reaches final state (delivered, completed, cancelled).

---

## 🔄 Conversation Flow Example

### **Complete User Journey:**

1. **Start Conversation**
   ```http
   POST /conversation/start
   Body: {"initial_message": "I'm hungry"}
   ```

2. **AI Recognizes Intent**
   ```
   Response: "I can help with food delivery! What would you like?"
   Stage: intent_recognition → category_selection
   ```

3. **User Specifies Food**
   ```http
   POST /conversation/{id}/message
   Body: {"message": "Pizza"}
   ```

4. **AI Shows Options**
   ```
   Response: Returns list of nearby pizzerias
   Stage: category_selection → item_selection
   ```

5. **User Selects Restaurant**
   ```http
   POST /conversation/{id}/message
   Body: {"message": "Papa's Pizza Palace"}
   ```

6. **AI Shows Menu**
   ```
   Response: Returns menu items
   Stage: item_selection → customization
   ```

7. **User Selects Items**
   ```http
   POST /conversation/{id}/message
   Body: {"message": "Large pepperoni pizza"}
   ```

8. **AI Requests Delivery Address**
   ```
   Response: "Where should we deliver?"
   Stage: customization → delivery_details
   ```

9. **User Provides Address**
   ```http
   POST /conversation/{id}/message
   Body: {"message": "123 Main St, San Francisco"}
   ```

10. **AI Requests Payment**
    ```
    Response: "How would you like to pay?"
    Stage: delivery_details → payment_setup
    ```

11. **User Confirms Payment**
    ```http
    POST /conversation/{id}/message
    Body: {"message": "Card ending in 1234"}
    ```

12. **AI Shows Order Summary**
    ```
    Response: "Order total: $26.94. Place order?"
    Stage: payment_setup → confirmation
    ```

13. **User Confirms**
    ```http
    POST /orders/place
    Body: {full order details}
    ```

14. **AI Starts Tracking**
    ```
    Response: Order placed successfully
    Stage: confirmation → tracking
    ```

15. **Real-time Updates**
    ```javascript
    // Connect WebSocket
    ws = new WebSocket('/orders/{order_id}/track')
    // Receive live updates until delivery
    ```

---

## 📊 Order Status Flow

```
placed → confirmed → preparing → ready → 
picked_up → in_transit → nearby → arrived → 
delivered → completed
```

**Or:**
```
placed → confirmed → cancelled
```

---

## 🧪 Testing the API

### **Using cURL:**

```bash
# Get auth token first
TOKEN=$(curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password"}' \
  | jq -r '.access_token')

# Start conversation
curl -X POST http://localhost:8000/api/concierge/conversation/start \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"initial_message": "I want pizza"}'

# Search for restaurants
curl -X GET "http://localhost:8000/api/concierge/services/search?category=FOOD&query=pizza" \
  -H "Authorization: Bearer $TOKEN"

# Get restaurant details
curl -X GET "http://localhost:8000/api/concierge/services/rest_1/details?provider=mock_food_delivery" \
  -H "Authorization: Bearer $TOKEN"
```

### **Using Python:**

```python
import requests
import json

BASE_URL = "http://localhost:8000/api/concierge"
TOKEN = "your_jwt_token"

headers = {
    "Authorization": f"Bearer {TOKEN}",
    "Content-Type": "application/json"
}

# Start conversation
response = requests.post(
    f"{BASE_URL}/conversation/start",
    headers=headers,
    json={"initial_message": "I want pizza"}
)

conversation = response.json()
conv_id = conversation["conversation_id"]

# Send message
response = requests.post(
    f"{BASE_URL}/conversation/{conv_id}/message",
    headers=headers,
    json={"message": "Large pepperoni"}
)

print(response.json())
```

---

## 🎯 Currently Implemented

✅ **Conversation Management**
- Start conversation with optional initial message
- Send messages and get AI responses
- Track conversation state and progress
- Cancel conversations

✅ **Service Search**
- Search across all providers
- Filter by category, location, query
- Get detailed service information
- Estimate costs before ordering

✅ **Order Management**
- Place orders through providers
- Get order details
- Track order status
- Cancel orders

✅ **Real-time Tracking**
- WebSocket streaming of order updates
- Live driver location
- Dynamic ETA updates

✅ **Mock Provider**
- Mock food delivery with 5 restaurants
- Full menu system with 25+ items
- Realistic order flow simulation
- Cost calculation with fees and tax

---

## 🚧 Coming Next

- NLU integration for better intent recognition
- MongoDB persistence (currently in-memory)
- Payment processing (Stripe)
- Push notifications
- Real provider integrations (UberEats, DoorDash, Uber, Lyft)
- Additional service categories
- Voice command support
- Multi-service coordination

---

## 📝 Notes

- All endpoints require authentication
- Conversation states expire after 24 hours
- WebSocket connections auto-close on order completion
- Mock provider has 0.2-1.0 second delays to simulate real APIs
- Cost estimates include subtotal, delivery fee, tax (8%), and tip

---

## 🔗 Related Documentation

- [AI Concierge System Architecture](./AI_CONCIERGE_SYSTEM.md)
- [Conversation State Machine](../backend/app/services/conversation_state.py)
- [Service Provider Interface](../backend/app/services/service_provider.py)
- [Mock Food Delivery Provider](../backend/app/services/providers/mock_food_delivery.py)

---

**Last Updated**: October 15, 2025  
**API Version**: 1.0.0  
**Status**: ✅ Ready for Testing
