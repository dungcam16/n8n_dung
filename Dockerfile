FROM docker.n8n.io/n8nio/n8n:next

USER root
SHELL ["/bin/sh","-euxo","pipefail","-c"]

# Cài python3, ffmpeg, sox, curl, ImageMagick trên Alpine
RUN apk add --no-cache \
      python3 \
      ffmpeg \
      sox \
      ca-certificates \
      curl \
      imagemagick && \
    # Tải yt-dlp dạng binary (không cần pip)
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
      -o /usr/local/bin/yt-dlp && \
    chmod a+rx /usr/local/bin/yt-dlp && \
    # alias python
    ln -sf "$(command -v python3)" /usr/local/bin/python
USER node
