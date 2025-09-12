FROM docker.n8n.io/n8nio/n8n:latest

USER root
SHELL ["/bin/sh","-euxo","pipefail","-c"]

# Hệ thống tools
RUN apk add --no-cache \
      python3 \
      ffmpeg \
      sox \
      ca-certificates \
      curl \
      imagemagick \
      chromium \
      nss \
      freetype \
      harfbuzz \
      ttf-freefont \
  && curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
      -o /usr/local/bin/yt-dlp \
  && chmod a+rx /usr/local/bin/yt-dlp \
  && ln -sf "$(command -v python3)" /usr/local/bin/python

# Tạo folder module riêng
RUN mkdir -p /home/node/custom_node_modules \
  && cd /home/node/custom_node_modules \
  && npm init -y \
  && npm install cheerio ethers moment puppeteer --no-save

# Thiết lập NODE_PATH và cho phép require external libs
ENV NODE_PATH=/home/node/custom_node_modules/node_modules \
    N8N_FUNCTION_ALLOW_EXTERNAL=cheerio,ethers,moment,puppeteer

USER node
