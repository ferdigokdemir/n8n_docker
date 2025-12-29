#!/bin/bash
# ===========================================
# n8n Backup Script
# Backs up PostgreSQL database and n8n data
# ===========================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Load environment variables
source .env

# Configuration
BACKUP_DIR="${BACKUP_DIR:-/opt/n8n/backups}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p "$BACKUP_DIR"

echo "🔄 Starting backup at $(date)"

# Backup PostgreSQL
echo "📦 Backing up PostgreSQL database..."
docker compose exec -T postgres pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" > "$BACKUP_DIR/postgres_${TIMESTAMP}.sql"

if [ -f "$BACKUP_DIR/postgres_${TIMESTAMP}.sql" ]; then
    gzip "$BACKUP_DIR/postgres_${TIMESTAMP}.sql"
    echo "✅ PostgreSQL backup: postgres_${TIMESTAMP}.sql.gz"
else
    echo "❌ PostgreSQL backup failed!"
    exit 1
fi

# Backup n8n data volume
echo "📦 Backing up n8n data..."
docker run --rm \
    -v n8n-docker_n8n_data:/data:ro \
    -v "$BACKUP_DIR":/backup \
    alpine tar czf "/backup/n8n_data_${TIMESTAMP}.tar.gz" -C /data .

echo "✅ n8n data backup: n8n_data_${TIMESTAMP}.tar.gz"

# Remove old backups
echo "🗑️  Removing backups older than ${RETENTION_DAYS} days..."
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete

# List current backups
echo ""
echo "📋 Current backups:"
ls -lh "$BACKUP_DIR"

echo ""
echo "✅ Backup completed at $(date)"

# Calculate total backup size
TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
echo "💾 Total backup size: $TOTAL_SIZE"
