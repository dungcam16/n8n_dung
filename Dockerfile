# Dockerfile (for building the custom n8n image with yt-dlp, ffmpeg, Python)
FROM docker.n8n.io/n8nio/n8n:latest

USER root
SHELL ["/bin/sh","-euxo","pipefail","-c"]

# Install Python, ffmpeg, sox, curl, ImageMagick, and dependencies
RUN apk add --no-cache \
      python3 python3-dev py3-pip build-base git \
      ffmpeg sox ca-certificates curl imagemagick \
      libsndfile-dev fftw-dev libsamplerate-dev \
      alsa-lib-dev cmake pkgconfig

# Create Python virtual environment
RUN python3 -m venv /opt/fxnorm-venv \
  && /opt/fxnorm-venv/bin/pip install --upgrade pip setuptools wheel

# Alias python
RUN ln -sf "$(command -v python3)" /usr/local/bin/python

USER node
