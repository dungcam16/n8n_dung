FROM docker.n8n.io/n8nio/n8n:latest

USER root
SHELL ["/bin/sh","-euxo","pipefail","-c"]

# Cài system tools & yt-dlp
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

# Tạo folder riêng để cài module JS
RUN mkdir -p /home/node/custom_node_modules \
  && cd /home/node/custom_node_modules \
  && npm init -y \
  && npm install cheerio ethers moment

# Cho Node.js biết load module từ folder này
ENV NODE_PATH=/home/node/custom_node_modules/node_modules

USER node
