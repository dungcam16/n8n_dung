from fastapi import FastAPI, UploadFile, File
from fastapi.responses import FileResponse
import tempfile, shutil, os, uuid
from inference import run_inference

app = FastAPI()

@app.post("/mix")
async def mix(files: list[UploadFile] = File(...)):
    sid = uuid.uuid4().hex
    td = tempfile.mkdtemp()
    inp = os.path.join(td, "input"); os.makedirs(inp)
    for i,f in enumerate(files):
        p = os.path.join(inp, f"track_{i}.wav")
        with open(p,"wb") as o: o.write(await f.read())
    out = os.path.join(td, f"{sid}.wav")
    run_inference(
      multitrack_path=inp,
      output_path=out,
      model_path="/opt/FxNorm/training/results/ours_S_pretrained",
      config_path="/opt/FxNorm/configs/ISMIR/ours_S_pretrained/config.py"
    )
    return FileResponse(out, media_type="audio/wav", filename=f"{sid}.wav")
