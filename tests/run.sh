#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BIN="$ROOT/bin/aniwatch"
OUT=$(sh "$BIN" help)
printf '%s\n' "$OUT" | grep -q 'anime discovery and playback'
printf '%s\n' "$OUT" | grep -q 'download <url>'
[ "$(sh "$BIN" version)" = "AniWatch 1.2.1" ]
if sh "$BIN" info abc >/dev/null 2>&1; then echo "Expected invalid anime ID to fail" >&2; exit 1; fi
if sh "$BIN" season 2026 monsoon >/dev/null 2>&1; then echo "Expected invalid season to fail" >&2; exit 1; fi
if ANIWATCH_LIMIT=zero sh "$BIN" top >/dev/null 2>&1; then echo "Expected invalid result limit to fail" >&2; exit 1; fi
if sh "$BIN" play not-a-url >/dev/null 2>&1; then echo "Expected invalid media URL to fail" >&2; exit 1; fi
if sh "$BIN" watch https://example.com/video.mp4 ultra >/dev/null 2>&1; then echo "Expected invalid quality to fail" >&2; exit 1; fi
if sh "$BIN" watch https://example.com/video.mp4 best raw >/dev/null 2>&1; then echo "Expected invalid audio mode to fail" >&2; exit 1; fi
if sh "$BIN" syncplay not-a-url >/dev/null 2>&1; then echo "Expected invalid Syncplay URL to fail" >&2; exit 1; fi

# Unit checks for quality/audio selectors and persistent history.
. "$ROOT/lib/aniwatch/core.sh"
. "$ROOT/lib/aniwatch/config.sh"
. "$ROOT/lib/aniwatch/player.sh"
[ "$(aw_quality_format 720p sub)" = 'bestvideo[height<=720]+bestaudio[language^=ja]/best[height<=720]' ]
[ "$(aw_quality_format 1080p dub)" = 'bestvideo[height<=1080]+bestaudio[language^=en]/best[height<=1080]' ]
[ "$(aw_audio_language dub)" = 'en,eng' ]
tmpdir=$(mktemp -d)
ANIWATCH_STATE_DIR=$tmpdir/state
ANIWATCH_HISTORY=$ANIWATCH_STATE_DIR/history.tsv
aw_history_add 'https://example.com/episode1' 'Test Episode'
[ -s "$ANIWATCH_HISTORY" ]
grep -q 'Test Episode' "$ANIWATCH_HISTORY"
rm -rf "$tmpdir"
echo "All AniWatch smoke tests passed."
