# Kenyan Food Delivery Backend

A comprehensive Go backend for a food delivery platform specifically designed for the Kenyan market, featuring M-Pesa integration, local cuisine support, and county-based delivery zones.

## Features

### Core Features
- **User Management**: Customer, restaurant owner, delivery driver, and admin roles
- **Restaurant Management**: Restaurant registration, menu management, and order processing
- **Order Management**: Complete order lifecycle from creation to delivery
- **Real-time Tracking**: GPS-based delivery tracking
- **Review System**: Customer reviews and ratings

### Kenyan-Specific Features
- **M-Pesa Integration**: STK Push payments and callback handling
- **County Support**: All 47 Kenyan counties with delivery zones
- **Local Cuisines**: Traditional Kenyan, Swahili, and popular international cuisines
- **Multi-language**: English and Swahili support
- **Local Delivery Zones**: Pre-configured zones for Nairobi, Mombasa, and Kisumu

## Technology Stack

- **Language**: Go 1.21
- **Framework**: Gin (HTTP web framework)
- **Database**: PostgreSQL with GORM ORM
- **Authentication**: JWT tokens
- **Payment**: M-Pesa API integration
- **Security**: bcrypt password hashing, CORS middleware

## Project Structure

```
kenyan-food-delivery-backend/
├── cmd/
│   └── main.go                 # Application entry point
├── internal/
│   ├── auth/                   # Authentication utilities
│   │   ├── jwt.go             # JWT token management
│   │   └── password.go        # Password hashing
│   ├── config/                 # Configuration management
│   │   └── config.go          # Environment configuration
│   ├── database/              # Database layer
│   │   ├── database.go        # Database connection
│   │   └── seeder.go          # Data seeding
│   ├── handlers/              # HTTP handlers
│   │   ├── handler.go         # Main handler struct
│   │   ├── auth.go            # Authentication endpoints
│   │   ├── user.go            # User management endpoints
│   │   └── restaurant.go      # Restaurant endpoints
│   ├── middleware/            # HTTP middleware
│   │   └── middleware.go      # CORS, auth, logging middleware
│   ├── models/                # Database models
│   │   ├── user.go            # User and address models
│   │   ├── restaurant.go      # Restaurant and menu models
│   │   └── order.go           # Order and payment models
│   └── services/              # Business logic layer
│       ├── services.go        # Service container
│       ├── auth.go            # Authentication service
│       ├── user.go            # User service
│       └── restaurant.go      # Restaurant service
├── pkg/
│   ├── mpesa/                 # M-Pesa integration
│   │   └── client.go          # M-Pesa API client
│   └── location/              # Kenyan location utilities
│       └── kenya.go           # Counties and delivery zones
├── migrations/                # Database migrations
├── docs/                      # API documentation
├── scripts/                   # Deployment scripts
├── .env.example              # Environment variables template
├── go.mod                    # Go module dependencies
└── README.md                 # This file
```

## Installation

### Prerequisites
- Go 1.21 or higher
- PostgreSQL 12 or higher
- M-Pesa developer account (for payment integration)

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd kenyan-food-delivery-backend
   ```

2. **Install dependencies**
   ```bash
   go mod download
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Set up PostgreSQL database**
   ```sql
   CREATE DATABASE kenyan_food_delivery;
   CREATE USER your_user WITH PASSWORD 'your_password';
   GRANT ALL PRIVILEGES ON DATABASE kenyan_food_delivery TO your_user;
   ```

5. **Update database configuration in .env**
   ```env
   DATABASE_URL=postgres://your_user:your_password@localhost/kenyan_food_delivery?sslmode=disable
   ```

6. **Run the application**
   ```bash
   go run cmd/main.go
   ```

The server will start on `http://localhost:8080`

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `ENVIRONMENT` | Application environment | `development` |
| `PORT` | Server port | `8080` |
| `DATABASE_URL` | PostgreSQL connection string | Required |
| `JWT_SECRET` | JWT signing secret | Required |
| `MPESA_CONSUMER_KEY` | M-Pesa consumer key | Required |
| `MPESA_CONSUMER_SECRET` | M-Pesa consumer secret | Required |
| `MPESA_PASSKEY` | M-Pesa passkey | Required |
| `MPESA_SHORTCODE` | M-Pesa shortcode | `174379` |
| `MPESA_ENVIRONMENT` | M-Pesa environment | `sandbox` |

## API Endpoints

### Authentication
- `POST /api/v1/auth/register` - User registration
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/refresh` - Refresh access token
- `POST /api/v1/auth/logout` - User logout

### User Management
- `GET /api/v1/users/profile` - Get user profile
- `PUT /api/v1/users/profile` - Update user profile
- `POST /api/v1/users/address` - Add user address
- `GET /api/v1/users/addresses` - Get user addresses
- `PUT /api/v1/users/addresses/:id` - Update address
- `DELETE /api/v1/users/addresses/:id` - Delete address

### Restaurants
- `GET /api/v1/restaurants` - Get all restaurants
- `GET /api/v1/restaurants/:id` - Get restaurant details
- `GET /api/v1/restaurants/:id/menu` - Get restaurant menu
- `GET /api/v1/restaurants/search` - Search restaurants
- `GET /api/v1/restaurants/cuisine/:cuisine` - Get restaurants by cuisine
- `GET /api/v1/restaurants/location/:county` - Get restaurants by county

### Orders
- `POST /api/v1/orders` - Create order
- `GET /api/v1/orders` - Get user orders
- `GET /api/v1/orders/:id` - Get order details
- `PUT /api/v1/orders/:id/cancel` - Cancel order
- `GET /api/v1/orders/:id/track` - Track order

### Payments
- `POST /api/v1/payments/mpesa/stk-push` - Initiate M-Pesa payment
- `POST /api/v1/payments/mpesa/callback` - M-Pesa callback
- `GET /api/v1/payments/methods` - Get payment methods

### Delivery
- `GET /api/v1/delivery/zones` - Get delivery zones
- `GET /api/v1/delivery/fee` - Calculate delivery fee

## User Roles

The platform supports four distinct user roles with specific permissions:

### 1. **Customer** (`customer`)
- Browse restaurants and menus
- Place orders
- Make payments
- Track deliveries
- Leave reviews
- Manage addresses

### 2. **Restaurant Owner** (`restaurant_owner`)
- Register and manage restaurants
- Create and update menus
- Process orders
- Update order status
- View analytics

### 3. **Delivery Driver** (`delivery_driver`)
- Accept delivery requests
- Update delivery status
- Track location
- Manage availability

### 4. **Admin** (`admin`)
- Manage all users
- Approve restaurants
- View system analytics
- Manage platform settings
- Full access to all features

## M-Pesa Integration

The platform integrates with Safaricom's M-Pesa API for seamless mobile payments:

### Features
- **STK Push**: Merchant-initiated payments
- **Payment Callbacks**: Real-time payment notifications
- **Transaction Status**: Query payment status
- **Sandbox Support**: Testing environment

### Usage Example
```go
// Initialize M-Pesa client
mpesaClient := mpesa.NewClient(
    consumerKey,
    consumerSecret,
    "sandbox", // or "production"
    passkey,
    shortcode,
)

// Initiate STK Push
response, err := mpesaClient.STKPush(
    "254712345678",    // Phone number
    "100",             // Amount
    "ORDER123",        // Account reference
    "Food delivery payment", // Description
    "https://yourdomain.com/callback", // Callback URL
)
```

## Kenyan Counties and Delivery Zones

The platform supports all 47 Kenyan counties with pre-configured delivery zones for major cities:

### Supported Counties
- **Coast**: Mombasa, Kwale, Kilifi, Tana River, Lamu, Taita Taveta
- **North Eastern**: Garissa, Wajir, Mandera
- **Eastern**: Marsabit, Isiolo, Meru, Tharaka Nithi, Embu, Kitui, Machakos, Makueni
- **Central**: Nyandarua, Nyeri, Kirinyaga, Murang'a, Kiambu, Nairobi
- **Rift Valley**: Turkana, West Pokot, Samburu, Trans Nzoia, Uasin Gishu, Elgeyo Marakwet, Nandi, Baringo, Laikipia, Nakuru, Narok, Kajiado, Kericho, Bomet
- **Western**: Kakamega, Vihiga, Bungoma, Busia
- **Nyanza**: Siaya, Kisumu, Homa Bay, Migori, Kisii, Nyamira

### Delivery Zones
- **Nairobi**: 15 zones including CBD, Westlands, Karen, Eastlands
- **Mombasa**: 6 zones including Island, Nyali, Bamburi
- **Kisumu**: 4 zones including Central, Milimani

## Local Cuisine Support

The platform includes comprehensive support for Kenyan and popular international cuisines:

### Kenyan Cuisines
- **Traditional Kenyan**: Ugali, Nyama Choma, Sukuma Wiki, Githeri
- **Swahili**: Biryani, Coconut Rice, Fish Curry, Samaki wa Nazi
- **Popular Dishes**: Pilau, Chapati, Mandazi, Samosa

### International Cuisines
- Indian, Chinese, Italian, American, Ethiopian, Lebanese, Continental

## Database Schema

The database includes comprehensive models for:

### User Management
- Users (customers, restaurant owners, drivers, admins)
- Addresses with Kenyan location support
- User verification and status management

### Restaurant Management
- Restaurant profiles with business information
- Menu categories and items
- Cuisine classifications
- Restaurant ratings and reviews

### Order Management
- Complete order lifecycle
- Order items and customizations
- Payment tracking
- Delivery management

### Location Services
- County and region mapping
- Delivery zones with pricing
- GPS coordinate support

## Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: bcrypt for secure password storage
- **Role-based Access**: Different access levels for user types
- **CORS Protection**: Cross-origin request handling
- **Rate Limiting**: API rate limiting middleware
- **Input Validation**: Request validation and sanitization

## Development

### Running Tests
```bash
go test ./...
```

### Building for Production
```bash
go build -o kenyan-food-delivery cmd/main.go
```

### Database Migrations
The application automatically runs migrations on startup. To seed initial data:
```bash
# The seeder runs automatically and includes:
# - All 47 Kenyan counties
# - Popular cuisine types
# - Restaurant categories
# - Delivery zones for major cities
```

## Deployment

### Docker Deployment
```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o main cmd/main.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/main .
EXPOSE 8080
CMD ["./main"]
```

### Environment Setup
1. Set up PostgreSQL database
2. Configure M-Pesa credentials
3. Set environment variables
4. Deploy to your preferred platform

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Email: support@kenyanfooddelivery.com
- Documentation: [API Docs](./docs/)
- Issues: GitHub Issues

## Roadmap

### Upcoming Features
- Real-time order tracking with WebSockets
- Push notifications
- Advanced analytics dashboard
- Multi-restaurant ordering
- Loyalty program integration
- Advanced search and filtering
- Restaurant performance analytics
- Customer behavior insights

### Planned Integrations
- Additional payment methods (Airtel Money, Equitel)
- SMS notifications
- Email marketing integration
- Social media login
- Third-party delivery services

