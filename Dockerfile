# n8n with Puppeteer/Chromium support
FROM n8nio/n8n:latest

USER root

# Install Chromium and dependencies for Puppeteer (Debian-based)
RUN apt-get update && apt-get install -y --no-install-recommends \
    chromium \
    libnss3 \
    libfreetype6 \
    libfreetype6-dev \
    libharfbuzz0b \
    ca-certificates \
    fonts-freefont-ttf \
    fonts-noto \
    fonts-noto-color-emoji \
    dumb-init \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Turkish font support (optional)
RUN apt-get update && apt-get install -y --no-install-recommends \
    fonts-noto-extra \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set Puppeteer environment variables
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    CHROME_PATH=/usr/bin/chromium \
    CHROMIUM_PATH=/usr/bin/chromium

# Create directories for n8n
RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n

USER node

WORKDIR /home/node
