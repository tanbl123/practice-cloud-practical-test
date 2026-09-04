#!/usr/bin/env bash
# Usage: ./scripts/grade.sh 01      (grade one lab)
#        ./scripts/grade.sh all     (grade every lab)
set -uo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO"

curl -s -o /dev/null http://127.0.0.1:5000 || { echo "Simulated AWS is not running. Run: ./scripts/start.sh"; exit 1; }

run_one() {
  local dir="$1"
  PYTHONPATH="$REPO/scripts" "$REPO/.venv/bin/python" "$dir/check.py"
}

target="${1:-all}"
if [ "$target" = "all" ]; then
  rc=0
  for d in labs/*/; do run_one "$d" || rc=1; done
  exit $rc
else
  d=$(ls -d labs/${target}-*/ 2>/dev/null | head -1)
  [ -z "$d" ] && { echo "No lab matching '$target'. Available:"; ls labs/; exit 1; }
  run_one "$d"
fi
