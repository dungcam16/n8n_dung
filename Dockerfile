# Dockerfile (dungcam16/ytdlp)
FROM docker.n8n.io/n8nio/n8n:latest

USER root
SHELL ["/bin/sh","-euxo","pipefail","-c"]

# Cài python3, ffmpeg, sox, curl, ImageMagick và dependencies cho FxNorm
RUN apk add --no-cache \
      python3 \
      python3-dev \
      py3-pip \
      build-base \
      git \
      ffmpeg \
      sox \
      ca-certificates \
      curl \
      imagemagick \
      libsndfile-dev \
      fftw-dev \
      libsamplerate-dev \
      alsa-lib-dev \
      cmake \
      pkgconfig

# Tạo virtual environment cho FxNorm
RUN python3 -m venv /opt/fxnorm-venv \
  && /opt/fxnorm-venv/bin/pip install --upgrade pip setuptools wheel

# Cài PyTorch CPU
RUN /opt/fxnorm-venv/bin/pip install \
      torch==1.9.0+cpu torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Cài các thư viện audio cần thiết
RUN /opt/fxnorm-venv/bin/pip install \
      librosa>=0.8.1 \
      scipy \
      soundfile \
      psutil \
      tensorboard \
      sty \
      git+https://github.com/csteinmetz1/pymixconsole \
      git+https://github.com/csteinmetz1/pyloudnorm \
      git+https://github.com/aubio/aubio

# Clone và cài FxNorm-Automix
WORKDIR /opt
RUN git clone https://github.com/sony/FxNorm-automix.git
WORKDIR /opt/FxNorm-automix
RUN /opt/fxnorm-venv/bin/pip install -r requirements.txt \
  && /opt/fxnorm-venv/bin/python setup.py install

# Copy wrapper script và cấp quyền
WORKDIR /
COPY fxnorm_wrapper.py /opt/audio_workspace/fxnorm_wrapper.py
RUN chmod +x /opt/audio_workspace/fxnorm_wrapper.py

# Alias python
RUN ln -sf "$(command -v python3)" /usr/local/bin/python

USER node
