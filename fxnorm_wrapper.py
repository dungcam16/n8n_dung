from fastapi import FastAPI, UploadFile, File
from fastapi.responses import FileResponse
import tempfile, shutil, os, uuid
from inference import run_inference  # from FxNorm-Automix

app = FastAPI()

@app.post("/mix")
async def mix(files: list[UploadFile] = File(...)):
    session = uuid.uuid4().hex
    tempdir = tempfile.mkdtemp()
    input_dir = os.path.join(tempdir, "input")
    os.makedirs(input_dir)
    paths = []
    for i, f in enumerate(files):
        path = os.path.join(input_dir, f"track_{i}.wav")
        with open(path, "wb") as out:
            out.write(await f.read())
        paths.append(path)
    output = os.path.join(tempdir, f"{session}.wav")
    run_inference(
      multitrack_path=input_dir,
      output_path=output,
      model_path="/opt/FxNorm/training/results/ours_S_pretrained",
      config_path="/opt/FxNorm/configs/ISMIR/ours_S_pretrained/config.py"
    )
    return FileResponse(output, media_type="audio/wav", filename=f"{session}.wav")
