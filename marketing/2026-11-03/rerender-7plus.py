"""Re-render hs-master-reel + hs-consulting-cut with the 7+ years caption (owner override 2026-11-12)."""
import json
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path("/Users/macbookm1pro/tools/OpenMontage")
sys.path.insert(0, str(ROOT))
from tools.video.hyperframes_compose import HyperFramesCompose  # noqa: E402

MASTER = ROOT / "projects/hs-master-reel"
CONSULT = ROOT / "projects/hs-consulting-cut"
OUT = Path("/Users/macbookm1pro/StudioProjects/portfolio/marketing/2026-11-03/out")

JOBS = [
    (MASTER, MASTER / "renders/master-16x9.mp4"),
    (MASTER / "vertical", MASTER / "renders/master-9x16.mp4"),
    (CONSULT / "square", CONSULT / "renders/consulting-1x1.mp4"),
    (CONSULT / "vertical", CONSULT / "renders/consulting-9x16.mp4"),
]

def run(cmd):
    p = subprocess.run(cmd, capture_output=True, text=True)
    if p.returncode != 0:
        raise RuntimeError(f"cmd failed: {cmd}\n{p.stdout[-2000:]}\n{p.stderr[-2000:]}")
    return p.stdout

def probe(path):
    out = run(["ffprobe", "-v", "error", "-select_streams", "v:0",
               "-show_entries", "stream=width,height,codec_name,nb_frames,r_frame_rate",
               "-show_entries", "format=duration,size", "-of", "json", str(path)])
    return json.loads(out)

results = []

# 1. back up the six-years renders before overwriting
for proj in (MASTER, CONSULT):
    bak = proj / "renders/pre-7plus"
    bak.mkdir(exist_ok=True)
    for f in (proj / "renders").glob("*.mp4"):
        shutil.copy2(f, bak / f.name)
    derived = proj / "renders/derived"
    if derived.is_dir():
        (bak / "derived").mkdir(exist_ok=True)
        for f in derived.glob("*.mp4"):
            shutil.copy2(f, bak / "derived" / f.name)
print("backup done", flush=True)

# 2. render the four authored workspaces
tool = HyperFramesCompose()
for ws, out_path in JOBS:
    print(f"rendering {ws.name} -> {out_path.name}", flush=True)
    r = tool.execute({"operation": "render_existing", "workspace_path": str(ws),
                      "output_path": str(out_path), "fps": 30})
    if not r.success:
        print(f"FAIL {ws}: {r.error}", flush=True)
        print(json.dumps(r.data, indent=2, default=str)[-4000:], flush=True)
        sys.exit(1)
    results.append({"workspace": str(ws), "output": str(out_path), "probe": probe(out_path)})
    print(f"ok {out_path.name}", flush=True)

# 3. 1:1 centre crop of the 16:9 master (1080px safe column, x=420)
sq = MASTER / "renders/derived/master-1x1.mp4"
run(["ffmpeg", "-y", "-i", str(MASTER / "renders/master-16x9.mp4"),
     "-vf", "crop=1080:1080:420:0", "-c:v", "libx264", "-preset", "slow",
     "-crf", "18", "-pix_fmt", "yuv420p", "-an", str(sq)])
results.append({"workspace": "ffmpeg centre crop", "output": str(sq), "probe": probe(sq)})
print("ok master-1x1.mp4 (crop)", flush=True)

# 4. QA frames: hook + caption beats, and the 15-frame contact sheet
qa = MASTER / "renders/qa"
for t in (0, 3, 8, 13, 19, 24, 28, 33, 38, 43):
    run(["ffmpeg", "-y", "-ss", str(t), "-i", str(MASTER / "renders/master-16x9.mp4"),
         "-frames:v", "1", str(qa / f"t{t}.png")])
run(["ffmpeg", "-y", "-i", str(MASTER / "renders/master-16x9.mp4"),
     "-vf", "fps=1/3,scale=480:-1,tile=5x3", "-frames:v", "1", str(qa / "contact.png")])
for name, t in (("master-9x16-hook", 2), ("consulting-1x1-c3", 12.5), ("consulting-9x16-c3", 12.5)):
    src = {"master-9x16-hook": MASTER / "renders/master-9x16.mp4",
           "consulting-1x1-c3": CONSULT / "renders/consulting-1x1.mp4",
           "consulting-9x16-c3": CONSULT / "renders/consulting-9x16.mp4"}[name]
    run(["ffmpeg", "-y", "-ss", str(t), "-i", str(src), "-frames:v", "1", str(qa / f"{name}.png")])
print("qa frames done", flush=True)

# 5. distribute to the marketing out dir
for _, out_path in JOBS + [(None, sq)]:
    shutil.copy2(out_path, OUT / out_path.name)
print("copied to marketing out/", flush=True)

print(json.dumps(results, indent=2))
print("ALL RENDERS OK")