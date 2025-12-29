# n8n Docker Deployment with Puppeteer

Production-ready n8n deployment with Puppeteer support for Digital Ocean.

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────┐
│              Digital Ocean Droplet                │
│  ┌──────────────────────────────────────────────┐│
│  │              Docker Network                   ││
│  │  ┌────────┐  ┌────────┐  ┌────────────────┐ ││
│  │  │ Caddy  │  │Postgres│  │n8n + Puppeteer │ ││
│  │  │(SSL)   │  │  (DB)  │  │                │ ││
│  │  └────────┘  └────────┘  └────────────────┘ ││
│  └──────────────────────────────────────────────┘│
└──────────────────────────────────────────────────┘
```

## ✨ Features

- **Puppeteer/Chromium support** - Web scraping, screenshots, PDF generation
- **Automatic SSL** - Let's Encrypt via Caddy
- **PostgreSQL** - Production-grade database
- **Backup/Restore** - Automated backup scripts
- **Security** - Basic auth, encryption, firewall

## 🚀 Quick Start

### 1. Create Droplet

Create a Digital Ocean Droplet:
- **Image:** Ubuntu 22.04 LTS
- **Size:** 4GB RAM / 2 vCPU (minimum)
- **Region:** Choose closest to your users

### 2. Initial Setup

SSH into your droplet and run:

```bash
# Download setup script
curl -O https://raw.githubusercontent.com/your-repo/n8n-docker/main/scripts/setup.sh
chmod +x setup.sh
./setup.sh
```

### 3. Deploy

```bash
cd /opt/n8n

# Clone repository (or upload files)
git clone https://github.com/your-repo/n8n-docker.git .

# Configure environment
cp .env.example .env
nano .env  # Edit with your values

# Generate encryption key
openssl rand -hex 32

# Deploy
./scripts/deploy.sh
```

### 4. DNS Configuration

Point your domain to your Droplet's IP:

```
Type: A
Name: n8n (or @ for root)
Value: YOUR_DROPLET_IP
TTL: 300
```

## 📁 Project Structure

```
n8n-docker/
├── Dockerfile           # Custom n8n + Puppeteer image
├── docker-compose.yml   # Service orchestration
├── Caddyfile           # Reverse proxy config
├── .env.example        # Environment template
├── scripts/
│   ├── setup.sh        # Initial server setup
│   ├── deploy.sh       # Deployment script
│   ├── backup.sh       # Backup script
│   └── restore.sh      # Restore script
└── README.md
```

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `N8N_HOST` | Your domain (e.g., n8n.example.com) | Yes |
| `POSTGRES_PASSWORD` | Database password | Yes |
| `N8N_BASIC_AUTH_USER` | Admin username | Yes |
| `N8N_BASIC_AUTH_PASSWORD` | Admin password | Yes |
| `N8N_ENCRYPTION_KEY` | 32-char encryption key | Yes |
| `TIMEZONE` | Server timezone | No |

### Generate Secure Passwords

```bash
# Encryption key
openssl rand -hex 32

# Random password
openssl rand -base64 24
```

## 🔧 Management

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f n8n
docker compose logs -f postgres
docker compose logs -f caddy
```

### Restart Services

```bash
docker compose restart
docker compose restart n8n
```

### Update n8n

```bash
# Pull latest base image and rebuild
docker compose build --no-cache n8n
docker compose up -d
```

## 💾 Backup & Restore

### Manual Backup

```bash
./scripts/backup.sh
```

### Automated Backup (Cron)

```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * /opt/n8n/scripts/backup.sh >> /var/log/n8n-backup.log 2>&1
```

### Restore

```bash
# List available backups
./scripts/restore.sh

# Restore specific backup
./scripts/restore.sh 20250101_120000
```

## 🔒 Security Recommendations

1. **Change default passwords** in `.env`
2. **Enable 2FA** in n8n settings
3. **Regular updates:** `docker compose pull && docker compose up -d`
4. **Monitor logs** for suspicious activity
5. **Limit SSH access** with key-based authentication

## 🐛 Troubleshooting

### Puppeteer Issues

```bash
# Check Chromium is available
docker compose exec n8n chromium-browser --version

# Test with a simple script
docker compose exec n8n node -e "console.log(process.env.PUPPETEER_EXECUTABLE_PATH)"
```

### SSL Certificate Issues

```bash
# Check Caddy logs
docker compose logs caddy

# Force certificate renewal
docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile
```

### Database Connection Issues

```bash
# Check PostgreSQL health
docker compose exec postgres pg_isready

# View PostgreSQL logs
docker compose logs postgres
```

## 📊 Resource Requirements

| Droplet Size | RAM | vCPU | Recommended For |
|--------------|-----|------|-----------------|
| Basic | 2GB | 1 | Testing only |
| **Standard** | 4GB | 2 | Production |
| Premium | 8GB | 4 | Heavy workloads |

## 📝 License

MIT License
