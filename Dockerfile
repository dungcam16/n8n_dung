FROM docker.n8n.io/n8nio/n8n:latest
USER root
SHELL ["/bin/sh","-euxo","pipefail","-c"]

# Giữ nguyên packages cũ + thêm FxNorm dependencies  
RUN apk add --no-cache \
      python3 python3-dev py3-pip py3-setuptools \
      ffmpeg sox sox-dev ca-certificates curl imagemagick \
      build-base git pkgconfig portaudio-dev libsndfile-dev \
      fftw-dev libsamplerate-dev alsa-lib-dev cmake \
      gcc g++ musl-dev libffi-dev openssl-dev \
      llvm llvm-dev clang && \
    # yt-dlp như cũ
    curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
      -o /usr/local/bin/yt-dlp && \
    chmod a+rx /usr/local/bin/yt-dlp && \
    ln -sf "$(command -v python3)" /usr/local/bin/python && \
    # Setup FxNorm
    python3 -m venv /opt/fxnorm-env && \
    /opt/fxnorm-env/bin/pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu && \
    git clone https://github.com/sony/FxNorm-automix.git /opt/FxNorm-automix && \
    cd /opt/FxNorm-automix && \
    sed -e '/pymixconsole/d' -e '/pyloudnorm/d' -e '/torch==/d' requirements.txt > requirements_clean.txt && \
    /opt/fxnorm-env/bin/pip install -r requirements_clean.txt && \
    /opt/fxnorm-env/bin/pip install -e . && \
    mkdir -p /opt/FxNorm-automix/{models,input,output} && \
    chown -R node:node /opt/fxnorm-env /opt/FxNorm-automix

# Tạo wrapper script dễ sử dụng
RUN cat > /usr/local/bin/fxnorm-mix << 'EOF'
#!/bin/sh
export PATH="/opt/fxnorm-env/bin:$PATH"
export PYTHONPATH="/opt/FxNorm-automix:$PYTHONPATH"

INPUT_FILE=""
OUTPUT_FILE=""
MODEL_NAME="ours_S_La"

while [ $# -gt 0 ]; do
    case $1 in
        --input) INPUT_FILE="$2"; shift 2 ;;
        --output) OUTPUT_FILE="$2"; shift 2 ;;
        --model) MODEL_NAME="$2"; shift 2 ;;
        *) echo "Unknown: $1" >&2; exit 1 ;;
    esac
done

if [ -z "$INPUT_FILE" ] || [ -z "$OUTPUT_FILE" ]; then
    echo '{"status":"error","message":"Missing --input or --output"}'
    exit 1
fi

mkdir -p "$(dirname "$OUTPUT_FILE")"
MODEL_PATH="/opt/FxNorm-automix/training/results/${MODEL_NAME}.pth"

# Fallback if no model
if [ ! -f "$MODEL_PATH" ]; then
    echo '{"status":"warning","message":"No model, copying input"}'
    cp "$INPUT_FILE" "$OUTPUT_FILE" 2>/dev/null || echo '{"status":"error","message":"Copy failed"}'
    exit 0
fi

# Run FxNorm
python3 -c "
import sys, json
sys.path.insert(0, '/opt/FxNorm-automix')
try:
    from scripts.inference import main
    class Args:
        input='$INPUT_FILE'; output='$OUTPUT_FILE'; model='$MODEL_PATH'
    main(Args())
    print(json.dumps({'status':'success','input':'$INPUT_FILE','output':'$OUTPUT_FILE'}))
except Exception as e:
    print(json.dumps({'status':'error','error':str(e)}))
    sys.exit(1)
"
EOF

RUN chmod +x /usr/local/bin/fxnorm-mix && chown node:node /usr/local/bin/fxnorm-mix
USER node
