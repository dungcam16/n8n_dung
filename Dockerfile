FROM docker.n8n.io/n8nio/n8n:latest

# Switch to root to install system and Node.js dependencies
USER root
SHELL ["/bin/sh","-euxo","pipefail","-c"]

# Install system packages and yt-dlp
RUN apk add --no-cache \
      python3 \
      ffmpeg \
      sox \
      ca-certificates \
      curl \
      imagemagick \
  && curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
      -o /usr/local/bin/yt-dlp \
  && chmod a+rx /usr/local/bin/yt-dlp \
  && ln -sf "$(command -v python3)" /usr/local/bin/python

# Install global npm packages: cheerio, ethers, moment
RUN npm install -g \
      cheerio \
      ethers \
      moment

# Revert back to the default n8n user
USER node
