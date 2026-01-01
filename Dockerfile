# n8n with Browserless support
# Using base n8n image - Chromium handled by separate Browserless container
FROM n8nio/n8n:latest

# Create directories with correct permissions for node user (UID 1000)
USER root
RUN mkdir -p /home/node/.n8n/files /files && \
    chown -R node:node /home/node/.n8n /files
USER node

# No additional setup needed - Browserless provides browser functionality
# via WebSocket connection (ws://browserless:3000)
