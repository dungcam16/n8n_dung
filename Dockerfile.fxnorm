FROM python:3.12-slim

RUN apt update && apt install -y --no-install-recommends \
    git ffmpeg build-essential python3-dev && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
    torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

RUN git clone https://github.com/sony/FxNorm-automix.git /opt/FxNorm
WORKDIR /opt/FxNorm
RUN pip install --no-cache-dir -r requirements.txt && python setup.py install

RUN pip install --no-cache-dir fastapi uvicorn aiofiles

COPY fxnorm_service.py /opt/fxnorm_service.py

EXPOSE 8000
CMD ["uvicorn","/opt/fxnorm_service:app","--host","0.0.0.0","--port","8000"]
