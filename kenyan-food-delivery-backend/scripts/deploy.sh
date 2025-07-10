#!/bin/bash

# Kenyan Food Delivery Backend Deployment Script

set -e

echo "🚀 Starting deployment of Kenyan Food Delivery Backend..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Go is installed
if ! command -v go &> /dev/null; then
    print_error "Go is not installed. Please install Go 1.21 or higher."
    exit 1
fi

# Check Go version
GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
REQUIRED_VERSION="1.21"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$GO_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    print_error "Go version $GO_VERSION is too old. Please install Go $REQUIRED_VERSION or higher."
    exit 1
fi

print_status "Go version $GO_VERSION detected ✓"

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_warning ".env file not found. Creating from template..."
    cp .env.example .env
    print_warning "Please edit .env file with your configuration before running the application."
fi

# Install dependencies
print_status "Installing dependencies..."
go mod download
go mod tidy

# Run tests (if any exist)
print_status "Running tests..."
go test ./... || print_warning "Some tests failed or no tests found"

# Build the application
print_status "Building application..."
go build -ldflags="-s -w" -o kenyan-food-delivery cmd/main.go

# Check if build was successful
if [ -f "kenyan-food-delivery" ]; then
    print_status "Build successful ✓"
    
    # Make executable
    chmod +x kenyan-food-delivery
    
    # Get file size
    SIZE=$(du -h kenyan-food-delivery | cut -f1)
    print_status "Binary size: $SIZE"
else
    print_error "Build failed"
    exit 1
fi

# Create systemd service file (optional)
create_systemd_service() {
    print_status "Creating systemd service file..."
    
    cat > kenyan-food-delivery.service << EOF
[Unit]
Description=Kenyan Food Delivery Backend
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=$(pwd)
ExecStart=$(pwd)/kenyan-food-delivery
Restart=always
RestartSec=5
Environment=ENVIRONMENT=production

[Install]
WantedBy=multi-user.target
EOF

    print_status "Systemd service file created: kenyan-food-delivery.service"
    print_status "To install: sudo cp kenyan-food-delivery.service /etc/systemd/system/"
    print_status "To enable: sudo systemctl enable kenyan-food-delivery"
    print_status "To start: sudo systemctl start kenyan-food-delivery"
}

# Create Docker files
create_docker_files() {
    print_status "Creating Docker files..."
    
    # Dockerfile
    cat > Dockerfile << EOF
# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Install git (required for some Go modules)
RUN apk add --no-cache git

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o kenyan-food-delivery cmd/main.go

# Final stage
FROM alpine:latest

# Install ca-certificates for HTTPS requests
RUN apk --no-cache add ca-certificates tzdata

WORKDIR /root/

# Copy the binary from builder stage
COPY --from=builder /app/kenyan-food-delivery .

# Copy environment file template
COPY --from=builder /app/.env.example .

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1

# Run the application
CMD ["./kenyan-food-delivery"]
EOF

    # Docker Compose
    cat > docker-compose.yml << EOF
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - ENVIRONMENT=production
      - DATABASE_URL=postgres://postgres:password@db:5432/kenyan_food_delivery?sslmode=disable
    depends_on:
      - db
    restart: unless-stopped
    volumes:
      - ./uploads:/root/uploads

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=kenyan_food_delivery
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    restart: unless-stopped

volumes:
  postgres_data:
EOF

    # Database initialization script
    cat > init.sql << EOF
-- Create database if not exists
CREATE DATABASE IF NOT EXISTS kenyan_food_delivery;

-- Create user if not exists
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'app_user') THEN
        CREATE USER app_user WITH PASSWORD 'app_password';
    END IF;
END
\$\$;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE kenyan_food_delivery TO app_user;
EOF

    print_status "Docker files created ✓"
    print_status "To build: docker-compose build"
    print_status "To run: docker-compose up -d"
}

# Create nginx configuration
create_nginx_config() {
    print_status "Creating Nginx configuration..."
    
    cat > nginx.conf << EOF
server {
    listen 80;
    server_name your-domain.com;

    # Redirect HTTP to HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com;

    # SSL configuration (update paths to your certificates)
    ssl_certificate /path/to/your/certificate.crt;
    ssl_certificate_key /path/to/your/private.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";

    # Rate limiting
    limit_req_zone \$binary_remote_addr zone=api:10m rate=10r/s;
    limit_req zone=api burst=20 nodelay;

    # Proxy to Go application
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Static files (if any)
    location /static/ {
        alias /path/to/static/files/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Health check endpoint
    location /health {
        access_log off;
        proxy_pass http://127.0.0.1:8080;
    }
}
EOF

    print_status "Nginx configuration created: nginx.conf"
}

# Main deployment options
echo ""
echo "Select deployment option:"
echo "1) Build only"
echo "2) Build + Create systemd service"
echo "3) Build + Create Docker files"
echo "4) Build + Create Nginx config"
echo "5) Create all deployment files"
echo ""

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        print_status "Build completed successfully!"
        ;;
    2)
        create_systemd_service
        ;;
    3)
        create_docker_files
        ;;
    4)
        create_nginx_config
        ;;
    5)
        create_systemd_service
        create_docker_files
        create_nginx_config
        ;;
    *)
        print_warning "Invalid choice. Build completed successfully!"
        ;;
esac

echo ""
print_status "🎉 Deployment preparation completed!"
echo ""
print_status "Next steps:"
echo "1. Configure your .env file with production values"
echo "2. Set up your PostgreSQL database"
echo "3. Configure M-Pesa API credentials"
echo "4. Set up SSL certificates for production"
echo "5. Configure your domain and DNS"
echo ""
print_status "To run the application:"
echo "./kenyan-food-delivery"
echo ""
print_status "The application will be available at http://localhost:8080"
print_status "API documentation: http://localhost:8080/api/v1"
print_status "Health check: http://localhost:8080/health"

