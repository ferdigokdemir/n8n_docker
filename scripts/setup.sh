#!/bin/bash
# ===========================================
# Digital Ocean Droplet Initial Setup Script
# Run this once on a fresh Ubuntu 22.04 droplet
# ===========================================

set -e

echo "🚀 Starting n8n server setup..."

# Update system
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install required packages
echo "📦 Installing dependencies..."
apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    ufw

# Install Docker
echo "🐳 Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    
    # Add current user to docker group
    usermod -aG docker $USER
fi

# Install Docker Compose
echo "🐳 Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    apt install -y docker-compose-plugin
fi

# Configure Firewall
echo "🔒 Configuring firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
ufw --force enable

# Create swap file (recommended for low memory droplets)
echo "💾 Creating swap file..."
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# Set timezone
echo "🕐 Setting timezone..."
timedatectl set-timezone Europe/Istanbul

# Create project directory
echo "📁 Creating project directory..."
mkdir -p /opt/n8n
cd /opt/n8n

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Clone your repository or copy files to /opt/n8n"
echo "2. Copy .env.example to .env and configure"
echo "3. Run: docker compose up -d"
echo ""
echo "⚠️  You may need to log out and back in for docker group changes to take effect."
