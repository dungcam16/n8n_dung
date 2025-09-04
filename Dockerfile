# Nền chính thức của n8n
FROM n8nio/n8n:latest

# Cài ffmpeg + python3 + pip, rồi cài yt-dlp qua pip
USER root
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ffmpeg python3 python3-pip ca-certificates; \
    pip3 install --no-cache-dir yt-dlp; \
    rm -rf /var/lib/apt/lists/*; \
    ln -sf /usr/bin/python3 /usr/local/bin/python
    
# Trả quyền chạy về user node như mặc định của n8n
USER node
