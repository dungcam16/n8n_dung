# Dockerfile (dungcam16/ytdlp)
FROM docker.n8n.io/n8nio/n8n:latest

USER root
SHELL ["/bin/sh","-euxo","pipefail","-c"]

# Install system dependencies
RUN apk add --no-cache \
      python3 python3-dev py3-pip build-base git \
      ffmpeg sox ca-certificates curl imagemagick \
      libsndfile-dev fftw-dev libsamplerate-dev \
      alsa-lib-dev cmake pkgconfig

# Create Python virtual environment
RUN python3 -m venv /opt/fxnorm-venv \
  && /opt/fxnorm-venv/bin/pip install --upgrade pip setuptools wheel

# Install PyTorch CPU packages
RUN /opt/fxnorm-venv/bin/pip install \
      --index-url https://download.pytorch.org/whl/cpu \
      torch torchvision torchaudio

# Clone and install FxNorm-Automix (includes all audio dependencies)
WORKDIR /opt
RUN git clone https://github.com/sony/FxNorm-automix.git
WORKDIR /opt/FxNorm-automix
RUN /opt/fxnorm-venv/bin/pip install -r requirements.txt \
  && /opt/fxnorm-venv/bin/python setup.py install

# Copy wrapper script and set permissions
WORKDIR /
COPY fxnorm_wrapper.py /opt/audio_workspace/fxnorm_wrapper.py
RUN chmod +x /opt/audio_workspace/fxnorm_wrapper.py \
  && ln -sf "$(command -v python3)" /usr/local/bin/python

USER node
