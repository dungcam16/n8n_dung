# Dockerfile (dungcam16/ytdlp)
FROM docker.n8n.io/n8nio/n8n:latest

USER root
SHELL ["/bin/sh","-euxo","pipefail","-c"]

RUN apk add --no-cache \
      python3 python3-dev py3-pip build-base git \
      ffmpeg sox ca-certificates curl imagemagick \
      libsndfile-dev fftw-dev libsamplerate-dev \
      alsa-lib-dev cmake pkgconfig

RUN python3 -m venv /opt/fxnorm-venv \
  && /opt/fxnorm-venv/bin/pip install --upgrade pip setuptools wheel

# Cài PyTorch + torchvision + torchaudio
RUN /opt/fxnorm-venv/bin/pip install \
      --index-url https://download.pytorch.org/whl/cpu \
      torch torchvision torchaudio

# Cài các thư viện audio core
RUN /opt/fxnorm-venv/bin/pip install \
      librosa scipy soundfile psutil tensorboard sty pyloudnorm

# Clone và cài FxNorm-Automix
WORKDIR /opt
RUN git clone https://github.com/sony/FxNorm-automix.git
WORKDIR /opt/FxNorm-automix
RUN /opt/fxnorm-venv/bin/pip install -r requirements.txt \
  && /opt/fxnorm-venv/bin/python setup.py install

# Copy wrapper
WORKDIR /
COPY fxnorm_wrapper.py /opt/audio_workspace/fxnorm_wrapper.py
RUN chmod +x /opt/audio_workspace/fxnorm_wrapper.py \
  && ln -sf "$(command -v python3)" /usr/local/bin/python

USER node
