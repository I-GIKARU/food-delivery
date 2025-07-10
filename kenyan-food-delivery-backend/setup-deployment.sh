#!/bin/bash

# Kenyan Food Delivery Backend - GitHub Actions Setup Script
# This script helps you set up deployment to Google Cloud Run via GitHub Actions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

echo "🚀 Setting up GitHub Actions deployment for Kenyan Food Delivery Backend"
echo "=================================================================="

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    print_error "gcloud CLI is not installed. Please install it first:"
    print_info "https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if user is logged in to gcloud
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    print_warning "Please login to gcloud first:"
    print_info "gcloud auth login"
    exit 1
fi

# Get current project
PROJECT_ID=$(gcloud config get-value project)
if [ -z "$PROJECT_ID" ]; then
    print_error "No project set. Please set your project:"
    print_info "gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

print_status "Using project: $PROJECT_ID"

# Enable required APIs
print_status "Enabling required Google Cloud APIs..."
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable secretmanager.googleapis.com

# Create service account for GitHub Actions
SERVICE_ACCOUNT_NAME="github-actions-sa"
SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"

print_status "Creating service account for GitHub Actions..."
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --display-name="GitHub Actions Service Account" \
    --description="Service account for GitHub Actions deployment" || true

# Grant necessary roles
print_status "Granting required roles to service account..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/run.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/secretmanager.secretAccessor"

# Create and download service account key
print_status "Creating service account key..."
gcloud iam service-accounts keys create key.json \
    --iam-account=$SERVICE_ACCOUNT_EMAIL

# Create secrets in Secret Manager
print_status "Setting up Secret Manager..."

# Function to create secret
create_secret() {
    local secret_name=$1
    local secret_value=$2
    
    if gcloud secrets describe $secret_name &> /dev/null; then
        print_info "Secret $secret_name already exists, updating..."
        echo -n "$secret_value" | gcloud secrets versions add $secret_name --data-file=-
    else
        print_info "Creating secret $secret_name..."
        echo -n "$secret_value" | gcloud secrets create $secret_name --data-file=-
    fi
}

# Prompt for secrets
echo ""
print_info "Please provide the following secrets for your application:"
echo "Press Enter to skip if you want to set them later in GitHub secrets or Secret Manager"

read -p "Database URL: " DATABASE_URL
read -p "JWT Secret: " JWT_SECRET
read -p "M-Pesa Consumer Key: " MPESA_CONSUMER_KEY
read -p "M-Pesa Consumer Secret: " MPESA_CONSUMER_SECRET
read -p "M-Pesa Passkey: " MPESA_PASSKEY
read -p "M-Pesa Business Short Code: " MPESA_BUSINESS_SHORT_CODE

# Create secrets if provided
if [ ! -z "$DATABASE_URL" ]; then
    create_secret "DATABASE_URL" "$DATABASE_URL"
fi

if [ ! -z "$JWT_SECRET" ]; then
    create_secret "JWT_SECRET" "$JWT_SECRET"
fi

if [ ! -z "$MPESA_CONSUMER_KEY" ]; then
    create_secret "MPESA_CONSUMER_KEY" "$MPESA_CONSUMER_KEY"
fi

if [ ! -z "$MPESA_CONSUMER_SECRET" ]; then
    create_secret "MPESA_CONSUMER_SECRET" "$MPESA_CONSUMER_SECRET"
fi

if [ ! -z "$MPESA_PASSKEY" ]; then
    create_secret "MPESA_PASSKEY" "$MPESA_PASSKEY"
fi

if [ ! -z "$MPESA_BUSINESS_SHORT_CODE" ]; then
    create_secret "MPESA_BUSINESS_SHORT_CODE" "$MPESA_BUSINESS_SHORT_CODE"
fi

# Update service.yaml with correct project ID
sed -i "s/PROJECT_ID/$PROJECT_ID/g" service.yaml

echo ""
print_status "🎉 Setup completed successfully!"
echo ""
print_info "Next steps:"
print_info "1. Add the following secrets to your GitHub repository:"
print_info "   - Go to your GitHub repository settings"
print_info "   - Navigate to Settings > Secrets and variables > Actions"
print_info "   - Add the following secrets:"
echo ""
print_info "   GCP_PROJECT_ID: $PROJECT_ID"
print_info "   GCP_SA_KEY: $(cat key.json | base64 -w 0)"
echo ""
print_info "2. If you skipped entering secrets earlier, add them as GitHub secrets:"
print_info "   - DATABASE_URL"
print_info "   - JWT_SECRET"
print_info "   - MPESA_CONSUMER_KEY"
print_info "   - MPESA_CONSUMER_SECRET"
print_info "   - MPESA_PASSKEY"
print_info "   - MPESA_BUSINESS_SHORT_CODE"
echo ""
print_info "3. Push your code to GitHub:"
print_info "   git add ."
print_info "   git commit -m 'Add GitHub Actions deployment'"
print_info "   git push origin main"
echo ""
print_info "4. The deployment will automatically trigger on push to main branch"
echo ""
print_warning "Security Note: Delete the key.json file after copying its content to GitHub secrets!"
print_warning "rm key.json"
echo ""
print_status "Your service will be available at:"
print_status "https://kenyan-food-delivery-[hash]-uc.a.run.app"
