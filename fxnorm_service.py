# fxnorm_service.py (FastAPI wrapper for FxNorm-Automix)
from fastapi import FastAPI, UploadFile, File
from fastapi.responses import FileResponse
import tempfile, shutil, os, uuid
from inference import run_inference  # from FxNorm-Automix

app = FastAPI()

@app.post("/mix")
async def mix(files: list[UploadFile] = File(...)):
    session_id = uuid.uuid4().hex
    tmpdir = tempfile.mkdtemp()
    input_dir = os.path.join(tmpdir, "input")
    os.makedirs(input_dir, exist_ok=True)

    # Save uploaded files
    for i, f in enumerate(files):
        path = os.path.join(input_dir, f"track_{i}.wav")
        with open(path, "wb") as out:
            out.write(await f.read())

    output_path = os.path.join(tmpdir, f"{session_id}.wav")

    # Run FxNorm-Automix inference
    run_inference(
        multitrack_path=input_dir,
        output_path=output_path,
        model_path="/opt/FxNorm/training/results/ours_S_pretrained",
        config_path="/opt/FxNorm/configs/ISMIR/ours_S_pretrained/config.py"
    )

    return FileResponse(output_path, media_type="audio/wav", filename=f"{session_id}.wav")
