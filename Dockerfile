# n8n with Browserless support
# Using base n8n image - Chromium handled by separate Browserless container
FROM n8nio/n8n:latest

# No additional setup needed - Browserless provides browser functionality
# via WebSocket connection (ws://browserless:3000)
