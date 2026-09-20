#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
PORT=4173
python3 "$ROOT/build_preview.py"
cp /home/ubuntu/upload/CaramelWaterlilyLogo.png "$ROOT/CaramelWaterlilyLogo.png"
python3 -m http.server "$PORT" --bind 127.0.0.1 --directory "$ROOT" >/tmp/caramel-http.log 2>&1 &
PID=$!
trap 'kill "$PID" 2>/dev/null || true' EXIT
sleep 1
python3 - "$ROOT" "$PORT" <<'PY'
import sys, urllib.request
from pathlib import Path
root=Path(sys.argv[1]); port=sys.argv[2]
pages=['index.html','about.html','services.html','winter-special.html','blog.html','contact.html']
base=f'http://127.0.0.1:{port}/'
fail=[]
for page in pages:
    data=urllib.request.urlopen(base+page).read().decode()
    if '<title>' not in data or 'style.css' not in data or 'CaramelWaterlilyLogo.png' not in data: fail.append(page+' missing title/style/logo')
    import re
    for href in re.findall(r'href=["\']([^"\']+)["\']',data):
        if href.startswith(('mailto:','tel:','#','http:','https:')): continue
        try: urllib.request.urlopen(base+href).read(64)
        except Exception as e: fail.append(f'{page} -> {href}: {e}')
print('LINK_TEST pages=',len(pages),'status=', 'PASS' if not fail else 'FAIL')
if fail:
    print('\n'.join(fail)); raise SystemExit(1)
PY
chromium --headless --no-sandbox --disable-gpu --hide-scrollbars --window-size=1440,1200 --screenshot="$ROOT/preview-desktop.png" "http://127.0.0.1:$PORT/" >/tmp/chromium-desktop.log 2>&1
chromium --headless --no-sandbox --disable-gpu --hide-scrollbars --window-size=390,844 --screenshot="$ROOT/preview-mobile.png" "http://127.0.0.1:$PORT/" >/tmp/chromium-mobile.log 2>&1
file "$ROOT/preview-desktop.png" "$ROOT/preview-mobile.png"
printf 'RESPONSIVE_SCREENSHOTS desktop=%s mobile=%s\n' "$ROOT/preview-desktop.png" "$ROOT/preview-mobile.png"
