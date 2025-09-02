# ./ytdlp-full-runner/app.py
from fastapi import FastAPI, BackgroundTasks, Header, HTTPException
from pydantic import BaseModel
import os, shlex, subprocess, glob

app = FastAPI()
DATA_DIR = os.environ.get("DATA_DIR", "/data")
RUNNER_TOKEN = os.environ.get("RUNNER_TOKEN")  # optional

class Job(BaseModel):
    url: str | None = None
    cli: str | None = None        # ví dụ: -f "bv*+ba/b" -o "/data/%(title)s.%(ext)s" <URL>
    opts: dict | None = None      # không bắt buộc, nếu muốn build CLI từ JSON
    sync: bool = False

def check_token(auth: str | None):
    if RUNNER_TOKEN and (not auth or not auth.startswith("Bearer ") or auth.split(" ",1)[1] != RUNNER_TOKEN):
        raise HTTPException(status_code=401, detail="Unauthorized")

def to_cli_from_opts(o: dict) -> list[str]:
    args = []
    if "format" in o: args += ["-f", o["format"]]
    if "outtmpl" in o: args += ["-o", o["outtmpl"]]
    if o.get("merge_to_mp4", True): args += ["--merge-output-format", "mp4"]
    if o.get("noplaylist", True): args += ["--no-playlist"]
    if "proxy" in o: args += ["--proxy", o["proxy"]]
    if o.get("write_subtitles"): args += ["--write-subs"]
    if "sublangs" in o: args += ["--sub-langs", o["sublangs"]]
    if o.get("embed_subs"): args += ["--embed-subs"]
    if o.get("embed_thumbnail"): args += ["--embed-thumbnail"]
    if o.get("add_metadata", True): args += ["--add-metadata"]
    if o.get("sponsorblock_remove"): args += ["--sponsorblock-remove", o["sponsorblock_remove"]]
    if "cookies" in o: args += ["--cookies", o["cookies"]]
    if o.get("extract_audio"):
        args += ["-x"]
        if "audio_format" in o: args += ["--audio-format", o["audio_format"]]
        if "audio_quality" in o: args += ["--audio-quality", o["audio_quality"]]
    return args

def run_cli(cli_line: str):
    os.makedirs(DATA_DIR, exist_ok=True)
    base_args = ["yt-dlp", "--paths", f"home:{DATA_DIR}", "--no-progress"]
    args = base_args + shlex.split(cli_line)
    try:
        proc = subprocess.run(args, capture_output=True, text=True)
        code = proc.returncode
        stdout, stderr = proc.stdout, proc.stderr
    except Exception as e:
        return {"status":"error","error":str(e),"args":args}

    files = sorted(glob.glob(os.path.join(DATA_DIR, "**/*"), recursive=True), key=os.path.getmtime)
    latest = files[-1] if files else None
    return {
        "status": "ok" if code == 0 else "error",
        "exit_code": code,
        "stdout": (stdout or "")[-2000:],
        "stderr": (stderr or "")[-2000:],
        "last_file": latest
    }

@app.get("/health")
def health():
    return {"ok": True, "data_dir": DATA_DIR}

@app.post("/download")
def download(job: Job, background_tasks: BackgroundTasks, authorization: str | None = Header(default=None)):
    check_token(authorization)
    if not job.cli and not job.url and not job.opts:
        raise HTTPException(400, "Provide 'cli' or 'url/opts'")

    if not job.cli:
        o = job.opts or {}
        if "outtmpl" not in o:
            o["outtmpl"] = os.path.join(DATA_DIR, "%(title)s [%(id)s].%(ext)s")
        cli_parts = to_cli_from_opts(o)
        target = job.url or ""
        job.cli = " ".join(shlex.quote(x) for x in (cli_parts + [target]))

    if job.sync:
        return run_cli(job.cli)

    background_tasks.add_task(run_cli, job.cli)
    return {"status":"accepted","message":"Downloading in background","data_dir":DATA_DIR}
