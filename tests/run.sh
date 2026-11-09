#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BIN="$ROOT/bin/aniwatch"
OUT=$(sh "$BIN" help)
printf '%s\n' "$OUT" | grep -q 'anime discovery'
printf '%s\n' "$OUT" | grep -q 'ANIWATCH_API_URL'
if sh "$BIN" info abc >/dev/null 2>&1; then
    echo "Expected invalid anime ID to fail" >&2
    exit 1
fi
if sh "$BIN" play not-a-url >/dev/null 2>&1; then
    echo "Expected invalid media URL to fail" >&2
    exit 1
fi
echo "All AniWatch smoke tests passed."
