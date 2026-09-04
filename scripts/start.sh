#!/usr/bin/env bash
# Start the local simulated AWS endpoint.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if curl -s -o /dev/null "http://127.0.0.1:5000" 2>/dev/null; then
  echo "Simulated AWS already running on http://127.0.0.1:5000"; exit 0
fi
nohup "$REPO/.venv/bin/moto_server" -H 127.0.0.1 -p 5000 > "$REPO/moto.log" 2>&1 &
echo $! > "$REPO/.moto.pid"
for i in $(seq 1 30); do
  curl -s -o /dev/null "http://127.0.0.1:5000" && { echo "Simulated AWS ready on http://127.0.0.1:5000"; exit 0; }
  sleep 1
done
echo "Failed to start. See $REPO/moto.log" >&2; exit 1
