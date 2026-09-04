#!/usr/bin/env bash
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
[ -f "$REPO/.moto.pid" ] && kill "$(cat "$REPO/.moto.pid")" 2>/dev/null && rm -f "$REPO/.moto.pid"
pkill -f moto_server 2>/dev/null
echo "Simulated AWS stopped."
