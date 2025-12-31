# n8n with Puppeteer/Chromium support
FROM n8nio/n8n:latest

USER root

# Install Chromium and dependencies for Puppeteer (Alpine-based)
RUN /sbin/apk add --no-cache \
    chromium \
    nss \
    freetype \
    freetype-dev \
    harfbuzz \
    ca-certificates \
    ttf-freefont \
    font-noto \
    font-noto-emoji \
    dumb-init

# Turkish font support (optional)
RUN /sbin/apk add --no-cache font-noto-extra

# Set Puppeteer environment variables
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    CHROME_PATH=/usr/bin/chromium-browser \
    CHROMIUM_PATH=/usr/bin/chromium-browser

# Create directories for n8n
RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n

USER node

WORKDIR /home/node
