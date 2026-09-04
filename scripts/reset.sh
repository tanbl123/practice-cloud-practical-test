#!/usr/bin/env bash
# Wipe ALL simulated AWS resources and start clean (like resetting a lab).
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"$REPO/scripts/stop.sh" >/dev/null 2>&1 || true
sleep 1
"$REPO/scripts/start.sh"
echo "Lab environment reset — all resources cleared."
