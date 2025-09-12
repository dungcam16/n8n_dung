FROM docker.n8n.io/n8nio/n8n:latest

USER root
SHELL ["/bin/sh","-euxo","pipefail","-c"]

# Cài system packages & yt-dlp
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

# Cài JS libraries cho Function nodes
RUN cd /usr/local/lib/node_modules/n8n \
  && npm install cheerio ethers moment --no-save --ignore-workspace-root-check

USER node
