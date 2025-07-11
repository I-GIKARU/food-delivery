#!/bin/bash

# Kenyan Food Delivery Backend - Google Cloud Run Deployment Script
# This script deploys the application to Google Cloud Run with all necessary configurations

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

# Configuration
PROJECT_ID="food-delivery-328cc"
SERVICE_NAME="kenyan-food-delivery-backend"
REGION="us-central1"
IMAGE_NAME="us-central1-docker.pkg.dev/${PROJECT_ID}/kenyan-food-delivery/${SERVICE_NAME}"

echo "🚀 Starting deployment to Google Cloud Run..."
echo "=================================================================="
echo "Project: ${PROJECT_ID}"
echo "Service: ${SERVICE_NAME}"
echo "Region: ${REGION}"
echo "Image: ${IMAGE_NAME}"
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

# Set the project
print_status "Setting GCP project..."
gcloud config set project ${PROJECT_ID}

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_error ".env file not found. Please create it with your configuration."
    exit 1
fi

# Source environment variables
print_status "Loading environment variables..."
set -a  # automatically export all variables
source .env
set +a  # stop automatically exporting

# Enable required services
print_status "Enabling required GCP services..."
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable artifactregistry.googleapis.com

# Create Artifact Registry repository if it doesn't exist
print_status "Setting up Artifact Registry..."
gcloud artifacts repositories create kenyan-food-delivery \
    --repository-format=docker \
    --location=${REGION} \
    --description="Kenyan Food Delivery Docker repository" || true

# Build and push the Docker image
print_status "Building and pushing Docker image..."
gcloud builds submit --tag ${IMAGE_NAME}

# Deploy to Cloud Run
print_status "Deploying to Cloud Run..."
gcloud run deploy ${SERVICE_NAME} \
  --image ${IMAGE_NAME} \
  --platform managed \
  --region ${REGION} \
  --allow-unauthenticated \
  --port 8080 \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10 \
  --timeout 300 \
  --set-env-vars "ENVIRONMENT=production" \
  --set-env-vars "DATABASE_URL=${DATABASE_URL}" \
  --set-env-vars "JWT_SECRET=${JWT_SECRET}" \
  --set-env-vars "EMAIL_HOST=${EMAIL_HOST}" \
  --set-env-vars "EMAIL_PORT=${EMAIL_PORT}" \
  --set-env-vars "EMAIL_USERNAME=${EMAIL_USERNAME}" \
  --set-env-vars "EMAIL_PASSWORD=${EMAIL_PASSWORD}" \
  --set-env-vars "EMAIL_FROM=${EMAIL_FROM}" \
  --set-env-vars "EMAIL_FROM_NAME=${EMAIL_FROM_NAME}" \
  --set-env-vars "MPESA_CONSUMER_KEY=${MPESA_CONSUMER_KEY}" \
  --set-env-vars "MPESA_CONSUMER_SECRET=${MPESA_CONSUMER_SECRET}" \
  --set-env-vars "MPESA_PASSKEY=${MPESA_PASSKEY}" \
  --set-env-vars "MPESA_SHORTCODE=${MPESA_SHORTCODE}" \
  --set-env-vars "MPESA_ENVIRONMENT=${MPESA_ENVIRONMENT}" \
  --set-env-vars "CLOUDINARY_CLOUD_NAME=${CLOUDINARY_CLOUD_NAME}" \
  --set-env-vars "CLOUDINARY_API_KEY=${CLOUDINARY_API_KEY}" \
  --set-env-vars "CLOUDINARY_API_SECRET=${CLOUDINARY_API_SECRET}" \
  --set-env-vars "CLOUDINARY_FOLDER=${CLOUDINARY_FOLDER}" \
  --set-env-vars "MAX_FILE_SIZE=${MAX_FILE_SIZE}" \
  --set-env-vars "UPLOAD_PATH=${UPLOAD_PATH}" \
  --set-env-vars "RATE_LIMIT_REQUESTS=${RATE_LIMIT_REQUESTS}" \
  --set-env-vars "RATE_LIMIT_WINDOW=${RATE_LIMIT_WINDOW}" \
  --set-env-vars "DEFAULT_DELIVERY_FEE=${DEFAULT_DELIVERY_FEE}" \
  --set-env-vars "MAX_DELIVERY_RADIUS=${MAX_DELIVERY_RADIUS}"

# Get the service URL
print_status "Getting service URL..."
SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} --region=${REGION} --format="value(status.url)")

echo ""
echo "=================================================================="
echo "🎉 Deployment completed successfully!"
echo "=================================================================="
echo "🌐 Service URL: ${SERVICE_URL}"
echo "🔍 Health Check: ${SERVICE_URL}/health"
echo "📚 API Documentation: ${SERVICE_URL}/api/v1/"
echo "=================================================================="
echo ""

# Test the health endpoint
print_status "Testing health endpoint..."
if curl -f -s "${SERVICE_URL}/health" > /dev/null; then
    print_status "✅ Health check passed!"
else
    print_warning "❌ Health check failed. Please check the logs."
fi

echo ""
print_info "Deployment Summary:"
print_info "- Project: ${PROJECT_ID}"
print_info "- Service: ${SERVICE_NAME}"
print_info "- Region: ${REGION}"
print_info "- Image: ${IMAGE_NAME}"
print_info "- URL: ${SERVICE_URL}"
echo ""
print_info "Next steps:"
print_info "1. Test API endpoints using the service URL"
print_info "2. Check Cloud Run logs for any issues"
print_info "3. Set up monitoring and alerting"
print_info "4. Configure custom domain if needed"
echo ""
print_status "🚀 Your Kenyan Food Delivery Backend is now live!"
