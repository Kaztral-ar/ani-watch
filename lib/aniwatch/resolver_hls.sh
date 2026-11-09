#!/bin/sh
# Generic HLS manifest inspection and variant selection.
# This module only handles manifests and streams the caller can access.

aw_hls_origin() {
    printf '%s\n' "$1" | sed -nE 's|^(https?://[^/]+).*|\1|p'
}

aw_hls_resolve_uri() {
    aw_base=$1
    aw_item=$2
    case "$aw_item" in
        http://*|https://*) printf '%s\n' "$aw_item" ;;
        //*) aw_scheme=$(printf '%s' "$aw_base" | sed -nE 's|^(https?):.*|\1|p'); printf '%s:%s\n' "$aw_scheme" "$aw_item" ;;
        /*) printf '%s%s\n' "$(aw_hls_origin "$aw_base")" "$aw_item" ;;
        *) printf '%s\n' "${aw_base%/*}/$aw_item" ;;
    esac
}

aw_hls_variants() {
    aw_manifest=$1
    aw_referer=${2:-}
    aw_validate_url "$aw_manifest"
    aw_require curl
    if [ -n "$aw_referer" ]; then
        aw_playlist=$(curl --fail --silent --show-error --location --max-time 30 -H "Referer: $aw_referer" "$aw_manifest") || return 1
    else
        aw_playlist=$(curl --fail --silent --show-error --location --max-time 30 "$aw_manifest") || return 1
    fi
    printf '%s\n' "$aw_playlist" | awk '
        /^#EXT-X-STREAM-INF:/ {
            line=$0
            height=0; bandwidth=0
            if (match(line, /RESOLUTION=[0-9]+x[0-9]+/)) {
                value=substr(line,RSTART,RLENGTH)
                sub(/^.*x/,"",value); height=value
            }
            if (match(line, /BANDWIDTH=[0-9]+/)) {
                value=substr(line,RSTART,RLENGTH); sub(/^BANDWIDTH=/,"",value); bandwidth=value
            }
            pending=1; next
        }
        pending && $0 !~ /^#/ && length($0) {
            printf "%s\t%s\t%s\n", height, bandwidth, $0
            pending=0
        }
    ' | while IFS="$(printf '\t')" read -r aw_height aw_bandwidth aw_uri; do
        [ -n "$aw_uri" ] || continue
        aw_resolved=$(aw_hls_resolve_uri "$aw_manifest" "$aw_uri")
        printf '%s\t%s\t%s\n' "${aw_height:-0}" "${aw_bandwidth:-0}" "$aw_resolved"
    done
}

aw_hls_select_variant() {
    aw_manifest=$1
    aw_quality=${2:-best}
    aw_referer=${3:-}
    aw_variants=$(aw_hls_variants "$aw_manifest" "$aw_referer") || return 1
    [ -n "$aw_variants" ] || { printf '%s\n' "$aw_manifest"; return 0; }
    case "$aw_quality" in
        best) printf '%s\n' "$aw_variants" | sort -t "$(printf '\t')" -k1,1nr -k2,2nr | head -n 1 ;;
        worst) printf '%s\n' "$aw_variants" | sort -t "$(printf '\t')" -k1,1n -k2,2n | head -n 1 ;;
        360p|480p|720p|1080p)
            aw_limit=${aw_quality%p}
            aw_pick=$(printf '%s\n' "$aw_variants" | awk -F '\t' -v max="$aw_limit" '$1 <= max {print}' | sort -t "$(printf '\t')" -k1,1nr -k2,2nr | head -n 1)
            [ -n "$aw_pick" ] || aw_pick=$(printf '%s\n' "$aw_variants" | sort -t "$(printf '\t')" -k1,1nr -k2,2nr | tail -n 1)
            printf '%s\n' "$aw_pick"
            ;;
        *) aw_die "quality must be best, worst, 360p, 480p, 720p, or 1080p" ;;
    esac | awk -F '\t' 'NF >= 3 {print $3}'
}

aw_play_hls() {
    aw_manifest=$1
    aw_quality=${2:-$ANIWATCH_QUALITY}
    aw_referer=${3:-}
    aw_title=${4:-AniWatch}
    aw_stream=$(aw_hls_select_variant "$aw_manifest" "$aw_quality" "$aw_referer") || aw_die "could not inspect HLS manifest"
    [ -n "$aw_stream" ] || aw_die "no playable HLS stream found"
    aw_require mpv
    if [ -n "$aw_referer" ]; then
        mpv --referrer="$aw_referer" --force-media-title="$aw_title" "$aw_stream"
    else
        mpv --force-media-title="$aw_title" "$aw_stream"
    fi
}

aw_download_hls() {
    aw_manifest=$1
    aw_quality=${2:-$ANIWATCH_QUALITY}
    aw_referer=${3:-}
    aw_title=${4:-AniWatch}
    aw_require yt-dlp
    mkdir -p "$ANIWATCH_DOWNLOAD_DIR" || aw_die "cannot create download directory"
    if [ -n "$aw_referer" ]; then
        yt-dlp --no-playlist --referer "$aw_referer" --format "best[height<=${aw_quality%p}]/best" --output "$ANIWATCH_DOWNLOAD_DIR/%(title).180B [%(id)s].%(ext)s" "$aw_manifest"
    else
        yt-dlp --no-playlist --output "$ANIWATCH_DOWNLOAD_DIR/%(title).180B [%(id)s].%(ext)s" "$aw_manifest"
    fi
}
