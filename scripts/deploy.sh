#!/bin/bash
# ===========================================
# n8n Deployment Script
# ===========================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

echo "🚀 Starting n8n deployment..."

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "Please copy .env.example to .env and configure it."
    exit 1
fi

# Load environment variables
source .env

# Validate required variables
REQUIRED_VARS=("N8N_HOST" "POSTGRES_PASSWORD" "N8N_BASIC_AUTH_PASSWORD" "N8N_ENCRYPTION_KEY")
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "❌ Error: $var is not set in .env"
        exit 1
    fi
done

# Pull latest images
echo "📥 Pulling latest images..."
docker compose pull

# Build custom n8n image
echo "🔨 Building n8n image with Puppeteer..."
docker compose build --no-cache n8n

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker compose down

# Start services
echo "▶️  Starting services..."
docker compose up -d

# Wait for services to be healthy
echo "⏳ Waiting for services to start..."
sleep 10

# Check service status
echo "📊 Service status:"
docker compose ps

# Show logs
echo ""
echo "📋 Recent logs:"
docker compose logs --tail=20

echo ""
echo "✅ Deployment complete!"
echo "🌐 n8n is available at: https://${N8N_HOST}"
