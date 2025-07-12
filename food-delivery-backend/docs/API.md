# Kenyan Food Delivery API Documentation

## Base URL
```
http://localhost:8080/api/v1
```

## Authentication
Most endpoints require authentication via JWT token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

## Response Format
All API responses follow this format:
```json
{
  "message": "Success message",
  "data": {}, // Response data
  "error": "Error message (if any)"
}
```

## Error Codes
- `400` - Bad Request
- `401` - Unauthorized
- `403` - Forbidden
- `404` - Not Found
- `500` - Internal Server Error

---

## Authentication Endpoints

### Register User
**POST** `/auth/register`

Register a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "phone_number": "254712345678",
  "password": "password123",
  "first_name": "John",
  "last_name": "Doe",
  "role": "customer", // customer, restaurant_owner, delivery_driver
  "preferred_language": "en" // en, sw
}
```

**Response:**
```json
{
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "phone_number": "254712345678",
      "first_name": "John",
      "last_name": "Doe",
      "role": "customer",
      "status": "active",
      "preferred_language": "en"
    },
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_in": 86400
  }
}
```

### Login
**POST** `/auth/login`

Authenticate user and get access token.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "email": "user@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "role": "customer"
    },
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_in": 86400
  }
}
```

### Refresh Token
**POST** `/auth/refresh`

Get new access token using refresh token.

**Request Body:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

### Logout
**POST** `/auth/logout`

Logout user (requires authentication).

---

## User Management Endpoints

### Get Profile
**GET** `/users/profile`

Get current user's profile (requires authentication).

**Response:**
```json
{
  "message": "Profile retrieved successfully",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "phone_number": "254712345678",
    "first_name": "John",
    "last_name": "Doe",
    "role": "customer",
    "preferred_language": "en",
    "addresses": []
  }
}
```

### Update Profile
**PUT** `/users/profile`

Update current user's profile (requires authentication).

**Request Body:**
```json
{
  "first_name": "John",
  "last_name": "Doe",
  "phone_number": "254712345678",
  "preferred_language": "sw",
  "profile_picture": "https://example.com/image.jpg"
}
```

### Add Address
**POST** `/users/address`

Add new delivery address (requires authentication).

**Request Body:**
```json
{
  "title": "Home",
  "street": "Kimathi Street",
  "building": "Building A",
  "floor": "2nd Floor",
  "apartment": "Apt 201",
  "landmark": "Near KCB Bank",
  "county": "Nairobi",
  "sub_county": "Starehe",
  "ward": "Nairobi Central",
  "postal_code": "00100",
  "latitude": -1.2921,
  "longitude": 36.8219,
  "is_default": true,
  "instructions": "Call when you arrive"
}
```

### Get Addresses
**GET** `/users/addresses`

Get all user addresses (requires authentication).

### Update Address
**PUT** `/users/addresses/:id`

Update existing address (requires authentication).

### Delete Address
**DELETE** `/users/addresses/:id`

Delete address (requires authentication).

---

## Restaurant Endpoints

### Get Restaurants
**GET** `/restaurants`

Get list of restaurants with optional filtering.

**Query Parameters:**
- `page` (int): Page number (default: 1)
- `limit` (int): Items per page (default: 20)
- `county` (string): Filter by county

**Response:**
```json
{
  "message": "Restaurants retrieved successfully",
  "data": [
    {
      "id": 1,
      "name": "Mama Oliech Restaurant",
      "description": "Authentic Kenyan cuisine",
      "phone_number": "254712345678",
      "address": "Tom Mboya Street, Nairobi",
      "county": "Nairobi",
      "is_open": true,
      "opening_time": "08:00",
      "closing_time": "22:00",
      "delivery_time": 45,
      "min_order_amount": 500,
      "delivery_fee": 150,
      "rating": 4.5,
      "total_reviews": 120,
      "categories": ["Kenyan Traditional"],
      "cuisines": ["Kenyan Traditional", "Swahili"]
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 50
  }
}
```

### Get Restaurant Details
**GET** `/restaurants/:id`

Get detailed restaurant information including menu.

### Get Restaurant Menu
**GET** `/restaurants/:id/menu`

Get restaurant's menu items.

**Response:**
```json
{
  "message": "Menu retrieved successfully",
  "data": [
    {
      "id": 1,
      "name": "Ugali with Sukuma Wiki",
      "name_swahili": "Ugali na Sukuma Wiki",
      "description": "Traditional Kenyan staple with vegetables",
      "price": 250,
      "image": "https://example.com/ugali.jpg",
      "is_vegetarian": true,
      "is_halal": true,
      "prep_time": 15,
      "category": {
        "id": 1,
        "name": "Main Dishes",
        "name_swahili": "Vyakula Vikuu"
      }
    }
  ]
}
```

### Search Restaurants
**GET** `/restaurants/search`

Search restaurants by name or description.

**Query Parameters:**
- `q` (string): Search query (required)
- `page` (int): Page number
- `limit` (int): Items per page

### Get Restaurants by Cuisine
**GET** `/restaurants/cuisine/:cuisine`

Get restaurants serving specific cuisine.

### Get Restaurants by Location
**GET** `/restaurants/location/:county`

Get restaurants in specific county.

---

## Order Endpoints

### Create Order
**POST** `/orders`

Create new order (requires authentication).

**Request Body:**
```json
{
  "restaurant_id": 1,
  "address_id": 1,
  "items": [
    {
      "menu_item_id": 1,
      "quantity": 2,
      "special_request": "Extra spicy"
    }
  ],
  "payment_method": "mpesa",
  "special_instructions": "Call when you arrive"
}
```

### Get User Orders
**GET** `/orders`

Get current user's orders (requires authentication).

**Query Parameters:**
- `page` (int): Page number
- `limit` (int): Items per page
- `status` (string): Filter by order status

### Get Order Details
**GET** `/orders/:id`

Get detailed order information (requires authentication).

### Cancel Order
**PUT** `/orders/:id/cancel`

Cancel order (requires authentication).

### Track Order
**GET** `/orders/:id/track`

Get real-time order tracking information (requires authentication).

---

## Payment Endpoints

### Initiate M-Pesa Payment
**POST** `/payments/mpesa/stk-push`

Initiate M-Pesa STK Push payment (requires authentication).

**Request Body:**
```json
{
  "order_id": 1,
  "phone_number": "254712345678",
  "amount": 1500
}
```

**Response:**
```json
{
  "message": "Payment initiated successfully",
  "data": {
    "checkout_request_id": "ws_CO_DMZ_123456789_12345678901234567890",
    "merchant_request_id": "29115-34620561-1",
    "response_code": "0",
    "response_description": "Success. Request accepted for processing",
    "customer_message": "Success. Request accepted for processing"
  }
}
```

### M-Pesa Callback
**POST** `/payments/mpesa/callback`

M-Pesa payment callback endpoint (webhook).

### Get Payment Methods
**GET** `/payments/methods`

Get available payment methods.

**Response:**
```json
{
  "message": "Payment methods retrieved successfully",
  "data": [
    {
      "id": "mpesa",
      "name": "M-Pesa",
      "description": "Pay with M-Pesa mobile money"
    },
    {
      "id": "card",
      "name": "Credit/Debit Card",
      "description": "Pay with credit or debit card"
    },
    {
      "id": "cash",
      "name": "Cash on Delivery",
      "description": "Pay with cash upon delivery"
    }
  ]
}
```

---

## Delivery Endpoints

### Get Delivery Zones
**GET** `/delivery/zones`

Get available delivery zones.

**Query Parameters:**
- `county` (string): Filter by county

**Response:**
```json
{
  "message": "Delivery zones retrieved successfully",
  "data": [
    {
      "id": 1,
      "county_code": "047",
      "name": "CBD",
      "description": "Central Business District",
      "delivery_fee": 100,
      "min_order_amount": 500,
      "max_delivery_time": 30,
      "is_active": true
    }
  ]
}
```

### Calculate Delivery Fee
**GET** `/delivery/fee`

Calculate delivery fee for given coordinates.

**Query Parameters:**
- `restaurant_lat` (float): Restaurant latitude
- `restaurant_lon` (float): Restaurant longitude
- `customer_lat` (float): Customer latitude
- `customer_lon` (float): Customer longitude

---

## Restaurant Owner Endpoints

### Create Restaurant
**POST** `/restaurant-owner/restaurant`

Create new restaurant (requires restaurant owner authentication).

### Update Restaurant
**PUT** `/restaurant-owner/restaurant/:id`

Update restaurant information (requires restaurant owner authentication).

### Get Restaurant Orders
**GET** `/restaurant-owner/restaurant/:id/orders`

Get orders for restaurant (requires restaurant owner authentication).

### Update Order Status
**PUT** `/restaurant-owner/orders/:id/status`

Update order status (requires restaurant owner authentication).

### Add Menu Item
**POST** `/restaurant-owner/restaurant/:id/menu`

Add new menu item (requires restaurant owner authentication).

### Update Menu Item
**PUT** `/restaurant-owner/menu/:id`

Update menu item (requires restaurant owner authentication).

### Delete Menu Item
**DELETE** `/restaurant-owner/menu/:id`

Delete menu item (requires restaurant owner authentication).

---

## Driver Endpoints

### Get Available Deliveries
**GET** `/driver/orders/available`

Get available delivery orders (requires driver authentication).

### Accept Delivery
**POST** `/driver/orders/:id/accept`

Accept delivery order (requires driver authentication).

### Update Delivery Status
**PUT** `/driver/orders/:id/status`

Update delivery status (requires driver authentication).

### Update Driver Location
**POST** `/driver/location`

Update driver's current location (requires driver authentication).

**Request Body:**
```json
{
  "latitude": -1.2921,
  "longitude": 36.8219,
  "accuracy": 5.0,
  "speed": 25.5,
  "heading": 180.0,
  "is_online": true
}
```

---

## Admin Endpoints

### Get Admin Statistics
**GET** `/admin/stats`

Get platform statistics (requires admin authentication).

### Get All Users
**GET** `/admin/users`

Get all users with pagination (requires admin authentication).

### Get All Restaurants
**GET** `/admin/restaurants`

Get all restaurants with pagination (requires admin authentication).

### Get All Orders
**GET** `/admin/orders`

Get all orders with pagination (requires admin authentication).

### Approve Restaurant
**PUT** `/admin/restaurants/:id/approve`

Approve restaurant registration (requires admin authentication).

### Update User Status
**PUT** `/admin/users/:id/status`

Update user account status (requires admin authentication).

---

## Kenyan Counties Reference

### All Counties
```json
[
  {"id": 1, "name": "Mombasa", "code": "001", "region": "Coast"},
  {"id": 2, "name": "Kwale", "code": "002", "region": "Coast"},
  {"id": 47, "name": "Nairobi", "code": "047", "region": "Central"}
]
```

### Regions
- **Coast**: Mombasa, Kwale, Kilifi, Tana River, Lamu, Taita Taveta
- **North Eastern**: Garissa, Wajir, Mandera
- **Eastern**: Marsabit, Isiolo, Meru, Tharaka Nithi, Embu, Kitui, Machakos, Makueni
- **Central**: Nyandarua, Nyeri, Kirinyaga, Murang'a, Kiambu, Nairobi
- **Rift Valley**: Turkana, West Pokot, Samburu, Trans Nzoia, Uasin Gishu, Elgeyo Marakwet, Nandi, Baringo, Laikipia, Nakuru, Narok, Kajiado, Kericho, Bomet
- **Western**: Kakamega, Vihiga, Bungoma, Busia
- **Nyanza**: Siaya, Kisumu, Homa Bay, Migori, Kisii, Nyamira

---

## Rate Limiting

API endpoints are rate limited to prevent abuse:
- **Default**: 100 requests per 15 minutes per IP
- **Authentication endpoints**: 10 requests per 15 minutes per IP
- **Payment endpoints**: 20 requests per 15 minutes per user

---

## Webhooks

### M-Pesa Payment Callback
Your callback URL will receive POST requests with payment status updates:

```json
{
  "Body": {
    "stkCallback": {
      "MerchantRequestID": "29115-34620561-1",
      "CheckoutRequestID": "ws_CO_DMZ_123456789_12345678901234567890",
      "ResultCode": 0,
      "ResultDesc": "The service request is processed successfully.",
      "CallbackMetadata": {
        "Item": [
          {"Name": "Amount", "Value": 1500},
          {"Name": "MpesaReceiptNumber", "Value": "NLJ7RT61SV"},
          {"Name": "TransactionDate", "Value": 20191219102115},
          {"Name": "PhoneNumber", "Value": 254712345678}
        ]
      }
    }
  }
}
```

