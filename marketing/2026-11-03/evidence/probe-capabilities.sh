#!/usr/bin/env bash
# Reproduce the capability + music-envelope measurements quoted in
# marketing/2026-11-03/PRODUCTION-PLAN.md. Read-only against OpenMontage;
# the only outbound calls are the two free music searches (no keys used).
set -u
OM=/Users/macbookm1pro/tools/OpenMontage
PY="$OM/.venv/bin/python"
cd "$OM" || exit 1

echo "## OpenMontage HEAD"
git -C "$OM" log --oneline -1

echo
echo "## Tools actually available, per capability (registry.discover() then get_status())"
"$PY" - <<'EOF'
from tools.tool_registry import ToolRegistry
from tools.base_tool import ToolStatus
r = ToolRegistry(); r.discover()
for cap in ['music_search', 'music_library', 'music_generation', 'screen_capture',
            'subtitle', 'tts', 'image_generation', 'video_generation',
            'video_post', 'analysis', 'enhancement', 'publish']:
    ts = r.get_by_capability(cap)
    av = sorted(t.name for t in ts if t.get_status() == ToolStatus.AVAILABLE)
    print(f"{cap:<18} total={len(ts):<3} available={av}")
EOF

echo
echo "## Render runtimes"
"$PY" - <<'EOF'
from tools.tool_registry import ToolRegistry
r = ToolRegistry()
print(r.provider_menu_summary().get('composition_runtimes'))
EOF

echo
echo "## Control: esbuild inside remotion-composer really runs (npm warned postinstall was unapproved)"
( cd remotion-composer && node -e "require('esbuild').transformSync('const a=1'); console.log('esbuild OK')" )

echo
echo "## Music plan probe — both sources, no credentials supplied"
"$PY" - <<'EOF'
from tools.tool_registry import ToolRegistry
r = ToolRegistry(); r.discover()
for name in ['pixabay_music', 'freesound_music']:
    t = r.get(name)
    res = t.execute({'operation': 'search', 'query': 'corporate motivational minimal', 'limit': 3})
    n = len((res.data or {}).get('results', []))
    print(f"{name:<15} status={t.get_status().value:<11} success={res.success} results={n} err={res.error}")
import os
print('music_library drop path exists:', os.path.isdir('music_library'))
EOF

echo
echo "## HyperFrames runtime (optional-dependency warnings are expected)"
make hyperframes-doctor 2>&1 | grep -E "Memory|Disk|npm_package_version|whisper|Kokoro|MusicGen|FFmpeg " | head -8
