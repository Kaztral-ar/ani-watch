#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BIN="$ROOT/bin/aniwatch"
OUT=$(sh "$BIN" help)
printf '%s\n' "$OUT" | grep -q 'anime discovery and playback'
printf '%s\n' "$OUT" | grep -q 'download <url>'
printf '%s\n' "$OUT" | grep -q 'hianime-search <query>'
[ "$(sh "$BIN" version)" = "AniWatch 1.3.0" ]
if sh "$BIN" info abc >/dev/null 2>&1; then echo "Expected invalid anime ID to fail" >&2; exit 1; fi
if sh "$BIN" season 2026 monsoon >/dev/null 2>&1; then echo "Expected invalid season to fail" >&2; exit 1; fi
if ANIWATCH_LIMIT=zero sh "$BIN" top >/dev/null 2>&1; then echo "Expected invalid result limit to fail" >&2; exit 1; fi
if sh "$BIN" play not-a-url >/dev/null 2>&1; then echo "Expected invalid media URL to fail" >&2; exit 1; fi
if sh "$BIN" watch https://example.com/video.mp4 ultra >/dev/null 2>&1; then echo "Expected invalid quality to fail" >&2; exit 1; fi
if sh "$BIN" watch https://example.com/video.mp4 best raw >/dev/null 2>&1; then echo "Expected invalid audio mode to fail" >&2; exit 1; fi
if sh "$BIN" syncplay not-a-url >/dev/null 2>&1; then echo "Expected invalid Syncplay URL to fail" >&2; exit 1; fi

. "$ROOT/lib/aniwatch/core.sh"
. "$ROOT/lib/aniwatch/config.sh"
. "$ROOT/lib/aniwatch/http.sh"
. "$ROOT/lib/aniwatch/provider_hianime.sh"
. "$ROOT/lib/aniwatch/player.sh"
[ "$(aw_hianime_validate_episode_id 123 2>/dev/null; printf ok)" = "ok" ]
if (aw_hianime_validate_episode_id nope) >/dev/null 2>&1; then echo "Expected invalid episode ID to fail" >&2; exit 1; fi
if (aw_hianime_validate_slug 'bad/slug') >/dev/null 2>&1; then echo "Expected invalid anime slug to fail" >&2; exit 1; fi
sample='<div class="ep-item" data-id="98765" data-number="1"><a href="/watch/demo-123?ep=98765"></a></div>'
[ "$(aw_hianime_parse_episodes "$sample")" = "$(printf '98765\t1')" ]
servers='<div class="server-item" data-id="22" data-server-name="Example" data-type="sub"></div>'
[ "$(aw_hianime_parse_servers "$servers")" = "$(printf 'sub\tExample\t22')" ]
tmpdir=$(mktemp -d)
ANIWATCH_STATE_DIR=$tmpdir/state
ANIWATCH_HISTORY=$ANIWATCH_STATE_DIR/history.tsv
aw_history_add 'https://example.com/episode1' 'Test Episode'
[ -s "$ANIWATCH_HISTORY" ]
grep -q 'Test Episode' "$ANIWATCH_HISTORY"
rm -rf "$tmpdir"
echo "All AniWatch smoke tests passed."
