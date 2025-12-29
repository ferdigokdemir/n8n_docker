#!/bin/bash
# ===========================================
# n8n Restore Script
# Restores from PostgreSQL and n8n data backups
# ===========================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Load environment variables
source .env

BACKUP_DIR="${BACKUP_DIR:-/opt/n8n/backups}"

# Check arguments
if [ -z "$1" ]; then
    echo "Usage: $0 <timestamp>"
    echo "Example: $0 20250101_120000"
    echo ""
    echo "Available backups:"
    ls -la "$BACKUP_DIR"/*.sql.gz 2>/dev/null | awk '{print $NF}' | sed 's/.*postgres_//' | sed 's/.sql.gz//'
    exit 1
fi

TIMESTAMP=$1
PG_BACKUP="$BACKUP_DIR/postgres_${TIMESTAMP}.sql.gz"
N8N_BACKUP="$BACKUP_DIR/n8n_data_${TIMESTAMP}.tar.gz"

# Verify backup files exist
if [ ! -f "$PG_BACKUP" ]; then
    echo "❌ PostgreSQL backup not found: $PG_BACKUP"
    exit 1
fi

if [ ! -f "$N8N_BACKUP" ]; then
    echo "❌ n8n data backup not found: $N8N_BACKUP"
    exit 1
fi

echo "⚠️  WARNING: This will overwrite current data!"
read -p "Are you sure you want to restore from ${TIMESTAMP}? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Restore cancelled."
    exit 0
fi

echo "🔄 Starting restore..."

# Stop n8n (keep postgres running)
echo "🛑 Stopping n8n..."
docker compose stop n8n

# Restore PostgreSQL
echo "📦 Restoring PostgreSQL database..."
gunzip -c "$PG_BACKUP" | docker compose exec -T postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"
echo "✅ PostgreSQL restored"

# Restore n8n data
echo "📦 Restoring n8n data..."
docker run --rm \
    -v n8n-docker_n8n_data:/data \
    -v "$BACKUP_DIR":/backup \
    alpine sh -c "rm -rf /data/* && tar xzf /backup/n8n_data_${TIMESTAMP}.tar.gz -C /data"
echo "✅ n8n data restored"

# Start services
echo "▶️  Starting services..."
docker compose up -d

echo ""
echo "✅ Restore completed!"
echo "🔗 Check your n8n instance at: https://${N8N_HOST}"
