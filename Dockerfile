# n8n with Browserless support
# Using base n8n image - Chromium handled by separate Browserless container
FROM n8nio/n8n:latest

# Create files directory with correct permissions
USER root
RUN mkdir -p /home/node/.n8n/files && \
    chown -R node:node /home/node/.n8n
USER node

# No additional setup needed - Browserless provides browser functionality
# via WebSocket connection (ws://browserless:3000)
