# Delivery record — 2026-11-03 campaign run

What actually rendered, what the gates caught, and how to re-run it.
Plan: [PRODUCTION-PLAN.md](PRODUCTION-PLAN.md) · Distribution: [site/MARKETING.md](../../site/MARKETING.md)

## Files

All nine in [`out/`](out/), copied from the OpenMontage project workspaces. Nothing was uploaded
anywhere — every `publish_log` entry is `exported`, and the last entry on each project is
`pending_review` because posting needs its own approval.

| File | Aspect | Duration | Size | Source project |
|---|---|---|---|---|
| `master-16x9.mp4` | 1920x1080 | 45.000s | 1.0 MB | hs-master-reel |
| `master-1x1.mp4` | 1080x1080 | 45.000s | 724 KB | hs-master-reel (centre crop, safe column verified) |
| `master-9x16.mp4` | 1080x1920 | 45.000s | 1.1 MB | hs-master-reel (native re-layout) |
| `clip-duas.mp4` | 1080x1920 | 15.06s | 1.1 MB | hs-app-clips |
| `clip-bulbvpn.mp4` | 1080x1920 | 14.06s | 1.0 MB | hs-app-clips |
| `clip-blankspace.mp4` | 1080x1920 | 13.06s | 1.0 MB | hs-app-clips |
| `clip-stoolap.mp4` | 1080x1920 | 15.06s | 1.2 MB | hs-app-clips |
| `consulting-1x1.mp4` | 1080x1080 | 20.000s | 588 KB | hs-consulting-cut |
| `consulting-9x16.mp4` | 1080x1920 | 20.000s | 708 KB | hs-consulting-cut |

Every one h264 at 30fps, silent, captions composited as type. Total ~8.4 MB.

## Pipelines run

| Project | Pipeline | Runtime | Stages | Cost |
|---|---|---|---|---|
| `hs-master-reel` | hybrid | HyperFrames 0.9.7 | idea → script → scene_plan → assets → edit → compose → publish, all completed | $0.00 |
| `hs-app-clips` | clip-factory (beta) | Remotion 4.0.484 | same seven stages | $0.00 |
| `hs-consulting-cut` | animation | HyperFrames 0.9.7 | research → proposal → script → scene_plan → assets → edit → compose → publish | $0.00 |

Gates were honoured under the owner's full-run pre-authorization, recorded as decision `d-001`
(`category: approval_policy`) in `hs-master-reel/decision_log.json`. `d-002` records the
render-runtime choice with both runtimes considered, `d-003` atelier mode, `d-004` the music
decision with all five sources scored, `d-005` the concept, `d-006` the claims source.

## What the gates caught — four defects, all fixed before delivery

1. **A stale claim that would have shipped.** The plan's claims gate said the Play rating had to be
   re-read live. It was: the listing returns `ratingValue 5`, `ratingCount 1063`, while `hasan.md`
   §5, the CMS row and the site's own `/apps` card all still said 4.9 / 1,058. The script was
   corrected before the first render, and `hasan.md` is now reconciled.
   Reproduce: `chrome-headless-shell --headless --dump-dom --virtual-time-budget=20000 <listing> | grep -o 'ratingCount[^,]*'`
2. **A receipt that does not exist.** Nakheel Marinas was planned around an App Store listing tile;
   the live CMS returns `links={}` for that slug. The beat now exhibits the published `/work/nakheel-marinas`
   case study and labels the figure CLIENT REPORTED.
3. **An end card that ate the whole clip.** In the Remotion clips the end card's opaque dark
   `AbsoluteFill` was the last sibling, so it painted over every earlier beat for the full duration —
   the first render of all four clips was nothing but the end card. Caught by the 15-frame contact
   sheets, fixed by gating the card's opacity to its own beat.
4. **A counter that lied.** The rating count interpolated 0→1,063 with only the left edge clamped, so
   it kept climbing past its own source (measured 1,240 at frame 180). Clamped both ends; it now
   lands on 1,063 and holds.

Also caught by the engine's own browser check before rendering: two text-occlusion errors, one
WCAG failure (`muted` on the ink ground measured 2.98:1), a blank first frame that would have become
the social thumbnail, and nine labels under the 28px legibility floor. All fixed; the final check
reports 0 errors and contrast 14/14.

## Honest limits of this delivery

- **`clip-factory` is beta.** Its batch-consistency gate was satisfied by hand, not by a tool.
- **The Remotion atelier review returns `status: revise` on every clip.** The two triggers are
  "mean volume −91 dB — effectively silent" and "no narration transcript to compare". Both are
  correct for a silent piece; recorded rather than suppressed.
- **Remotion writes a silent AAC track into each clip.** Harmless for upload, but the files are not
  audio-free the way the HyperFrames ones are.
- **`master-1x1.mp4` is a centre crop, not a second layout.** Nothing is cut, because the 16:9
  composition was authored inside a 1080px centre column — but the crop lands exactly on that column,
  so type sits flush against the left edge instead of on a margin. It reads as a choice, not a defect;
  a native square re-layout would be the better follow-up if the 1:1 cut matters. The two 9:16 pieces
  are native re-layouts, not crops.
- **The 9:16 consulting cut is a mechanical re-layout** of the 1:1 file (tops ×1.7778, type ×1.3),
  re-checked at 0 errors — not hand-arranged shot by shot.
- **Nothing was posted, deployed or uploaded.** The site's own `/apps` card still displays the stale
  4.9 (1,058); correcting CMS data is a repo-and-deploy action outside this run.

## Re-running it

```bash
cd /Users/macbookm1pro/tools/OpenMontage
for s in hs-master-reel hs-app-clips hs-consulting-cut; do
  .venv/bin/python -c "import sys;sys.path.insert(0,'projects');from authoring import init;init('$s')"
done
.venv/bin/python projects/hs-master-reel/stage_idea.py
.venv/bin/python projects/hs-master-reel/stage_script.py
.venv/bin/python projects/hs-master-reel/stage_scene_plan.py
.venv/bin/python projects/hs-master-reel/stage_remaining.py
.venv/bin/python projects/hs-consulting-cut/stages.py
.venv/bin/python projects/hs-app-clips/stages.py
```

Captures must be retaken before re-rendering (the claims gate is the point): see
[`evidence/live-claims.txt`](evidence/live-claims.txt) and
[`evidence/probe-capabilities.sh`](evidence/probe-capabilities.sh).
