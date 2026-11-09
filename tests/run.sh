#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BIN="$ROOT/bin/aniwatch"
OUT=$(sh "$BIN" help)
printf '%s\n' "$OUT" | grep -q 'anime discovery'
printf '%s\n' "$OUT" | grep -q 'season YEAR SEASON'
[ "$(sh "$BIN" version)" = "AniWatch 1.1.0" ]
if sh "$BIN" info abc >/dev/null 2>&1; then
    echo "Expected invalid anime ID to fail" >&2
    exit 1
fi
if sh "$BIN" season 2026 monsoon >/dev/null 2>&1; then
    echo "Expected invalid season to fail" >&2
    exit 1
fi
if ANIWATCH_LIMIT=zero sh "$BIN" top >/dev/null 2>&1; then
    echo "Expected invalid result limit to fail" >&2
    exit 1
fi
if sh "$BIN" play not-a-url >/dev/null 2>&1; then
    echo "Expected invalid media URL to fail" >&2
    exit 1
fi
echo "All AniWatch smoke tests passed."
