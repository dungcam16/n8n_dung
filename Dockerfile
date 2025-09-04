FROM docker.n8n.io/n8nio/n8n:latest

USER root
SHELL ["/bin/sh","-euxo","pipefail","-c"]

# Cài ffmpeg + curl, rồi cài yt-dlp dạng binary để khỏi dính PEP 668/pip
RUN if [ -f /etc/alpine-release ]; then \
      apk add --no-cache ffmpeg ca-certificates curl; \
    else \
      apt-get update && apt-get install -y --no-install-recommends ffmpeg ca-certificates curl && \
      rm -rf /var/lib/apt/lists/*; \
    fi && \
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
      -o /usr/local/bin/yt-dlp && \
    chmod a+rx /usr/local/bin/yt-dlp && \
    yt-dlp --version

USER node
