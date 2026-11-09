#!/bin/sh
set -eu
ROOT=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
BIN="$ROOT/bin/aniwatch"
TEST_SHELL=${TEST_SHELL:-sh}
run_cli() {
    "$TEST_SHELL" "$BIN" "$@"
}

OUT=$(run_cli help)
printf '%s\n' "$OUT" | grep -q 'anime discovery and playback'
printf '%s\n' "$OUT" | grep -q 'search <query>'
printf '%s\n' "$OUT" | grep -q 'download <url>'
printf '%s\n' "$OUT" | grep -q 'metadata-search <query>'
[ "$(run_cli version)" = "AniWatch 1.3.0" ]
if run_cli info abc >/dev/null 2>&1; then echo "Expected invalid anime ID to fail" >&2; exit 1; fi
if run_cli season 2026 monsoon >/dev/null 2>&1; then echo "Expected invalid season to fail" >&2; exit 1; fi
if ANIWATCH_LIMIT=zero run_cli top >/dev/null 2>&1; then echo "Expected invalid result limit to fail" >&2; exit 1; fi
if run_cli play not-a-url >/dev/null 2>&1; then echo "Expected invalid media URL to fail" >&2; exit 1; fi
if run_cli watch https://example.com/video.mp4 ultra >/dev/null 2>&1; then echo "Expected invalid quality to fail" >&2; exit 1; fi
if run_cli watch https://example.com/video.mp4 best raw >/dev/null 2>&1; then echo "Expected invalid audio mode to fail" >&2; exit 1; fi
if run_cli syncplay not-a-url >/dev/null 2>&1; then echo "Expected invalid Syncplay URL to fail" >&2; exit 1; fi
if run_cli bulk-download demo invalid >/dev/null 2>&1; then echo "Expected invalid bulk episode range to fail" >&2; exit 1; fi
if run_cli bulk-download demo 5-2 >/dev/null 2>&1; then echo "Expected reversed bulk episode range to fail" >&2; exit 1; fi

. "$ROOT/lib/aniwatch/core.sh"
. "$ROOT/lib/aniwatch/config.sh"
. "$ROOT/lib/aniwatch/http.sh"
. "$ROOT/lib/aniwatch/provider_jikan.sh"
. "$ROOT/lib/aniwatch/provider_hianime.sh"
. "$ROOT/lib/aniwatch/player.sh"
. "$ROOT/lib/aniwatch/resolver_hls.sh"
. "$ROOT/lib/aniwatch/main.sh"

[ "$(aw_hianime_validate_episode_id 123 2>/dev/null; printf ok)" = "ok" ]
if (aw_hianime_validate_episode_id nope) >/dev/null 2>&1; then echo "Expected invalid episode ID to fail" >&2; exit 1; fi
if (aw_hianime_validate_slug 'bad/slug') >/dev/null 2>&1; then echo "Expected invalid anime slug to fail" >&2; exit 1; fi

sample='<div class="ep-item" data-id="98765" data-number="1"><a href="/watch/demo-123?ep=98765"></a></div>'
[ "$(aw_hianime_parse_episodes "$sample")" = "$(printf '98765\t1')" ]
servers='<div class="server-item" data-id="22" data-server-name="Example" data-type="sub"></div>'
[ "$(aw_hianime_parse_servers "$servers")" = "$(printf 'sub\tExample\t22\t')" ]
linked_server='<div class="server-item" data-type="dub" data-server-name="Public" data-id="23" data-link="https://cdn.example.test/master.m3u8"></div>'
[ "$(aw_hianime_parse_servers "$linked_server")" = "$(printf 'dub\tPublic\t23\thttps://cdn.example.test/master.m3u8')" ]

# Search cards with poster and title anchors must produce one row per anime slug.
aw_encode() { printf '%s' "$1"; }
aw_get_html() {
    cat <<'HTML'
<div class="film-detail"><a href="/poster/frieren" title="Frieren"></a><a href="/watch/frieren" title="Frieren"></a></div>
<div class="film-detail"><a href="/watch/frieren" title="Frieren"></a></div>
<div class="film-detail"><a href="/watch/another" title="Another"></a></div>
HTML
}
search_rows=$(aw_hianime_search demo)
[ "$(printf '%s\n' "$search_rows" | wc -l | tr -d ' ')" -eq 2 ]

[ "$(aw_hls_resolve_uri "https://cdn.example.test/path/master.m3u8" "720/index.m3u8")" = "https://cdn.example.test/path/720/index.m3u8" ]
[ "$(aw_hls_resolve_uri "https://cdn.example.test/path/master.m3u8" "/hls/720.m3u8")" = "https://cdn.example.test/hls/720.m3u8" ]
[ "$(aw_hls_resolve_uri "https://cdn.example.test/path/master.m3u8" "//media.example.test/v/720.m3u8")" = "https://media.example.test/v/720.m3u8" ]
[ "$(aw_hls_resolve_uri "https://cdn.example.test/path/master.m3u8" "https://other.example.test/a.m3u8")" = "https://other.example.test/a.m3u8" ]
[ "$(aw_hls_resolve_uri "https://cdn.example.test/path/master.m3u8?token=a/b" "720/index.m3u8")" = "https://cdn.example.test/path/720/index.m3u8" ]
[ "$(aw_hls_resolve_uri "https://cdn.example.test/path/master.m3u8?token=a/b" "?token=next")" = "https://cdn.example.test/path/master.m3u8?token=next" ]

curl() {
    cat <<'HLS'
#EXTM3U
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio",NAME="Japanese",DEFAULT=YES,URI="audio/ja.m3u8"
#EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=640x360,AUDIO="audio"
low/index.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=1800000,RESOLUTION=1280x720,AUDIO="audio"
high/index.m3u8
HLS
}
[ "$(aw_hls_select_variant "https://cdn.example.test/master.m3u8" best)" = "https://cdn.example.test/high/index.m3u8" ]
[ "$(aw_hls_select_variant "https://cdn.example.test/master.m3u8" 480p)" = "https://cdn.example.test/low/index.m3u8" ]

curl() {
    cat <<'HLS'
#EXTM3U
#EXT-X-STREAM-INF:BANDWIDTH=800000
unknown/index.m3u8
HLS
}
if aw_hls_select_variant "https://cdn.example.test/master.m3u8" 360p >/dev/null 2>&1; then
    echo "Expected unknown-resolution variant to be rejected by a resolution cap" >&2
    exit 1
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT HUP INT TERM
mkdir -p "$tmpdir/bin"
cat > "$tmpdir/bin/mpv" <<'MOCK'
#!/bin/sh
printf '%s\n' "$@" > "$MOCK_MPV_ARGS"
exit "${MOCK_MPV_EXIT:-0}"
MOCK
cat > "$tmpdir/bin/ffmpeg" <<'MOCK'
#!/bin/sh
printf '%s\\n' "$@" > "$MOCK_FFMPEG_ARGS"
exit 0
MOCK
cat > "$tmpdir/bin/yt-dlp" <<'MOCK'
#!/bin/sh
last=
for arg do last=$arg; done
case "$last" in *fail*|*.m3u8*) exit 7 ;; *) exit 0 ;; esac
MOCK
chmod +x "$tmpdir/bin/mpv" "$tmpdir/bin/yt-dlp" "$tmpdir/bin/ffmpeg"
PATH="$tmpdir/bin:$PATH"
export PATH
MOCK_MPV_ARGS="$tmpdir/mpv.args"
MOCK_FFMPEG_ARGS="$tmpdir/ffmpeg.args"
export MOCK_MPV_ARGS MOCK_FFMPEG_ARGS
ANIWATCH_STATE_DIR="$tmpdir/state"
ANIWATCH_HISTORY="$ANIWATCH_STATE_DIR/history.tsv"
ANIWATCH_DOWNLOAD_DIR="$tmpdir/downloads"
export ANIWATCH_STATE_DIR ANIWATCH_HISTORY ANIWATCH_DOWNLOAD_DIR

# History helper must not overwrite caller-owned interactive state.
aw_title=Frieren
aw_episode=Episode\ 2
aw_history_add "https://cdn.example.test/episode.mp4" "$aw_title" "frieren" "2"
[ "$aw_title" = "Frieren" ]
[ "$aw_episode" = "Episode 2" ]

# Invalid player configuration must fail before a history record is written.
rm -f "$ANIWATCH_HISTORY"
if ( export ANIWATCH_PLAYER=invalid; aw_play_url "https://cdn.example.test/no.mp4" ) >/dev/null 2>&1; then
    echo "Expected invalid player configuration to fail" >&2
    exit 1
fi
[ ! -s "$ANIWATCH_HISTORY" ]

# Successful playback logs only after the player returns successfully.
ANIWATCH_PLAYER=mpv
export ANIWATCH_PLAYER
aw_play_url "https://cdn.example.test/episode.mp4" best sub "Frieren Episode 2" "123" "2" "https://hianime.at"
grep -q 'Frieren Episode 2' "$ANIWATCH_HISTORY"
grep -q -- '--referrer=https://hianime.at' "$MOCK_MPV_ARGS"
grep -q -- '--' "$MOCK_MPV_ARGS"
grep -q 'https://cdn.example.test/episode.mp4' "$MOCK_MPV_ARGS"

# Continue must resume a direct media URL with its Referer, not treat it as HLS.
aw_history_add "https://cdn.example.test/direct.mp4" "Frieren Episode 3" "frieren" "3" "https://hianime.at" "dub"
aw_history_continue
grep -q -- '--referrer=https://hianime.at' "$MOCK_MPV_ARGS"
grep -q 'https://cdn.example.test/direct.mp4' "$MOCK_MPV_ARGS"
grep -q -- '--alang=en,eng' "$MOCK_MPV_ARGS"

# HLS playback receives the master playlist (including alternate audio metadata).
aw_play_hls "https://cdn.example.test/master.m3u8" 720p "https://hianime.at" "Frieren" "frieren" "3" "" dub
grep -q 'https://cdn.example.test/master.m3u8' "$MOCK_MPV_ARGS"
if grep -q 'https://cdn.example.test/high/index.m3u8' "$MOCK_MPV_ARGS"; then
    echo "HLS playback should retain the master playlist, not a video-only variant" >&2
    exit 1
fi
grep -q -- '--ytdl-format=' "$MOCK_MPV_ARGS"

# ffmpeg receives a real CRLF-terminated Referer header when yt-dlp falls back.
if MOCK_YTDLP_EXIT=1 aw_download_hls "https://cdn.example.test/fallback.m3u8" 720p "https://hianime.at" "Fallback"; then
    :
fi
grep -F "Referer: https://hianime.at" "$MOCK_FFMPEG_ARGS" >/dev/null
grep -F "$(printf '\\r')" "$MOCK_FFMPEG_ARGS" >/dev/null

# The master URL's separate audio rendition remains in the source manifest.
# Bulk failures are isolated to their own episode and only successful downloads count.
aw_require() {
    if [ "$1" = ffmpeg ]; then aw_die "required command not found: ffmpeg"; fi
    command -v "$1" >/dev/null 2>&1 || aw_die "required command not found: $1"
}
aw_check_deps() { :; }
aw_hianime_episodes() { printf '101\t1\n102\t2\n103\t3\n'; }
aw_hianime_servers() {
    case "$1" in
        101) printf 'sub\tMock\t1\thttps://cdn.example.test/ep1.m3u8\n' ;;
        102) printf 'sub\tMock\t2\thttps://cdn.example.test/ep2.mp4\n' ;;
        103) printf 'sub\tMock\t3\thttps://cdn.example.test/fail.mp4\n' ;;
    esac
}
bulk_output=$(aw_download_range_command demo 1-3 sub 720p 2>&1)
printf '%s\n' "$bulk_output" | grep -q '1 downloaded, 2 failed, 0 skipped'

# Jikan's API uses "fall"; accept "autumn" as an alias.
aw_get() { printf '%s' "$1"; }
case "$(aw_season 2026 fall)" in *'/seasons/2026/fall?limit='*) ;; *) echo "fall season mapping failed" >&2; exit 1 ;; esac
case "$(aw_season 2026 autumn)" in *'/seasons/2026/fall?limit='*) ;; *) echo "autumn alias mapping failed" >&2; exit 1 ;; esac

# Install must deploy the bundled standalone executable, not the source-tree launcher.
make -C "$ROOT" install DESTDIR="$tmpdir/install" PREFIX=/usr/local >/dev/null
[ -x "$tmpdir/install/usr/local/bin/aniwatch" ]
"$TEST_SHELL" "$tmpdir/install/usr/local/bin/aniwatch" help >/dev/null

echo "All AniWatch regression tests passed."
