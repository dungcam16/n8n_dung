# ./ytdlp-full-runner/Dockerfile
FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir fastapi uvicorn[standard] yt-dlp

WORKDIR /app
ENV DATA_DIR=/data
VOLUME ["/data"]
EXPOSE 8080

COPY app.py .

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
