FROM n8nio/n8n:latest

USER root
SHELL ["/bin/sh", "-euxo", "pipefail", "-c"]

# Cài ffmpeg + python + pip + yt-dlp cho cả Alpine (apk) và Debian/Ubuntu (apt)
RUN if [ -f /etc/alpine-release ]; then \
      apk add --no-cache ffmpeg python3 py3-pip ca-certificates && \
      pip3 install --no-cache-dir --upgrade pip && \
      pip3 install --no-cache-dir yt-dlp ; \
    else \
      apt-get update && \
      apt-get install -y --no-install-recommends ffmpeg python3 python3-pip ca-certificates && \
      pip3 install --no-cache-dir --upgrade pip && \
      pip3 install --no-cache-dir yt-dlp && \
      rm -rf /var/lib/apt/lists/* ; \
    fi && \
    ln -sf "$(command -v python3)" /usr/local/bin/python

USER node
