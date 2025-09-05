FROM docker.n8n.io/n8nio/n8n:latest

USER root
SHELL ["/bin/sh","-euxo","pipefail","-c"]

# Cài python3, ffmpeg, sox với định dạng MP3, curl, ImageMagick trên Alpine
RUN apk add --no-cache \
      python3 \
      ffmpeg \
      sox \
      sox-lame \
      ca-certificates \
      curl \
      imagemagick && \
    # Tải yt-dlp dạng binary (không cần pip)
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
      -o /usr/local/bin/yt-dlp && \
    chmod a+rx /usr/local/bin/yt-dlp && \
    # (tuỳ chọn) alias python
    ln -sf "$(command -v python3)" /usr/local/bin/python

USER node
