#!/bin/sh
# Generic HLS manifest inspection and variant selection.
# This module only handles manifests and streams the caller can access.

aw_hls_origin() {
    printf '%s\n' "$1" | sed -nE 's|^(https?://[^/]+).*|\1|p'
}

aw_hls_resolve_uri() {
    aw_hls_base=$1
    aw_hls_item=$2
    aw_hls_base_path=${aw_hls_base%%\?*}
    case "$aw_hls_item" in
        http://*|https://*) printf '%s\n' "$aw_hls_item" ;;
        //*) aw_hls_scheme=$(printf '%s' "$aw_hls_base" | sed -nE 's|^(https?):.*|\1|p'); printf '%s:%s\n' "$aw_hls_scheme" "$aw_hls_item" ;;
        /*) printf '%s%s\n' "$(aw_hls_origin "$aw_hls_base")" "$aw_hls_item" ;;
        \?*) printf '%s%s\n' "$aw_hls_base_path" "$aw_hls_item" ;;
        *) printf '%s\n' "${aw_hls_base_path%/*}/$aw_hls_item" ;;
    esac
}

aw_hls_variants() {
    aw_hls_manifest=$1
    aw_hls_referer=${2:-}
    aw_validate_url "$aw_hls_manifest"
    aw_require curl
    if [ -n "$aw_hls_referer" ]; then
        aw_hls_playlist=$(curl --fail --silent --show-error --location --max-time 30 -H "Referer: $aw_hls_referer" "$aw_hls_manifest") || return 1
    else
        aw_hls_playlist=$(curl --fail --silent --show-error --location --max-time 30 "$aw_hls_manifest") || return 1
    fi
    printf '%s\n' "$aw_hls_playlist" | awk '
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
    ' | while IFS="$(printf '\t')" read -r aw_hls_height aw_hls_bandwidth aw_hls_uri; do
        [ -n "$aw_hls_uri" ] || continue
        aw_hls_resolved=$(aw_hls_resolve_uri "$aw_hls_manifest" "$aw_hls_uri")
        printf '%s\t%s\t%s\n' "${aw_hls_height:-0}" "${aw_hls_bandwidth:-0}" "$aw_hls_resolved"
    done
}

aw_hls_select_variant() {
    aw_hls_manifest=$1
    aw_hls_quality=${2:-best}
    aw_hls_referer=${3:-}
    case "$aw_hls_quality" in
        best|worst|360p|480p|720p|1080p) ;;
        *) aw_die "quality must be best, worst, 360p, 480p, 720p, or 1080p" ;;
    esac
    aw_hls_variants_list=$(aw_hls_variants "$aw_hls_manifest" "$aw_hls_referer") || return 1
    [ -n "$aw_hls_variants_list" ] || { printf '%s\n' "$aw_hls_manifest"; return 0; }
    case "$aw_hls_quality" in
        best)
            aw_hls_pick=$(printf '%s\n' "$aw_hls_variants_list" | sort -t "$(printf '\t')" -k1,1nr -k2,2nr | head -n 1)
            ;;
        worst)
            aw_hls_pick=$(printf '%s\n' "$aw_hls_variants_list" | sort -t "$(printf '\t')" -k1,1n -k2,2n | head -n 1)
            ;;
        360p|480p|720p|1080p)
            aw_hls_limit=${aw_hls_quality%p}
            aw_hls_pick=$(printf '%s\n' "$aw_hls_variants_list" | awk -F '\t' -v max="$aw_hls_limit" '$1 > 0 && $1 <= max {print}' | sort -t "$(printf '\t')" -k1,1nr -k2,2nr | head -n 1)
            ;;
    esac
    [ -n "$aw_hls_pick" ] || return 1
    printf '%s\n' "$aw_hls_pick" | awk -F '\t' 'NF >= 3 {print $3}'
}

aw_play_hls() {
    aw_hls_play_manifest=$1
    aw_hls_play_quality=${2:-$ANIWATCH_QUALITY}
    aw_hls_play_referer=${3:-}
    aw_hls_play_title=${4:-AniWatch}
    aw_hls_play_mal_id=${5:-}
    aw_hls_play_episode=${6:-}
    aw_hls_play_aniskip_id=${7:-}
    aw_hls_play_mode=${8:-$ANIWATCH_MODE}
    aw_validate_url "$aw_hls_play_manifest"
    case "$aw_hls_play_quality" in best|worst|360p|480p|720p|1080p) ;; *) aw_die "invalid HLS quality: $aw_hls_play_quality" ;; esac
    case "$ANIWATCH_PLAYER" in
        mpv)
            aw_require mpv
            aw_require yt-dlp
            aw_hls_play_format=$(aw_quality_format "$aw_hls_play_quality" "$aw_hls_play_mode")
            aw_hls_play_audio=$(aw_audio_language "$aw_hls_play_mode")
            aw_hls_play_skip=$(aw_aniskip_flags "$aw_hls_play_aniskip_id" "$aw_hls_play_episode" || :)
            if [ -n "$aw_hls_play_skip" ]; then
                case $- in *f*) aw_hls_play_noglob=1 ;; *) aw_hls_play_noglob=0; set -f ;; esac
                if [ -n "$aw_hls_play_referer" ]; then
                    mpv $aw_hls_play_skip --referrer="$aw_hls_play_referer" --force-media-title="$aw_hls_play_title" --ytdl-format="$aw_hls_play_format" --alang="$aw_hls_play_audio" -- "$aw_hls_play_manifest"
                    aw_hls_play_status=$?
                else
                    mpv $aw_hls_play_skip --force-media-title="$aw_hls_play_title" --ytdl-format="$aw_hls_play_format" --alang="$aw_hls_play_audio" -- "$aw_hls_play_manifest"
                    aw_hls_play_status=$?
                fi
                [ "$aw_hls_play_noglob" -eq 1 ] || set +f
            else
                if [ -n "$aw_hls_play_referer" ]; then
                    mpv --referrer="$aw_hls_play_referer" --force-media-title="$aw_hls_play_title" --ytdl-format="$aw_hls_play_format" --alang="$aw_hls_play_audio" -- "$aw_hls_play_manifest"
                    aw_hls_play_status=$?
                else
                    mpv --force-media-title="$aw_hls_play_title" --ytdl-format="$aw_hls_play_format" --alang="$aw_hls_play_audio" -- "$aw_hls_play_manifest"
                    aw_hls_play_status=$?
                fi
            fi
            ;;
        vlc)
            aw_require vlc
            [ "$ANIWATCH_SKIP_INTRO" != "1" ] || aw_info "Ani-Skip integration is MPV-only"
            if [ -n "$aw_hls_play_referer" ]; then
                vlc --http-referrer="$aw_hls_play_referer" --meta-title="$aw_hls_play_title" -- "$aw_hls_play_manifest"
                aw_hls_play_status=$?
            else
                vlc --meta-title="$aw_hls_play_title" -- "$aw_hls_play_manifest"
                aw_hls_play_status=$?
            fi
            ;;
        *) aw_die "ANIWATCH_PLAYER must be mpv or vlc" ;;
    esac
    if [ "$aw_hls_play_status" -eq 0 ]; then
        aw_history_add "$aw_hls_play_manifest" "$aw_hls_play_title" "$aw_hls_play_mal_id" "$aw_hls_play_episode" "$aw_hls_play_referer" "$aw_hls_play_mode"
    fi
    return "$aw_hls_play_status"
}

aw_download_hls() {
    aw_hls_download_manifest=$1
    aw_hls_download_quality=${2:-$ANIWATCH_QUALITY}
    aw_hls_download_referer=${3:-}
    aw_hls_download_title=${4:-AniWatch}
    aw_hls_download_mode=${5:-$ANIWATCH_MODE}
    aw_validate_url "$aw_hls_download_manifest"
    aw_require yt-dlp
    aw_hls_download_format=$(aw_quality_format "$aw_hls_download_quality" "$aw_hls_download_mode")
    mkdir -p "$ANIWATCH_DOWNLOAD_DIR" || aw_die "cannot create download directory"
    if [ -n "$aw_hls_download_referer" ]; then
        yt-dlp --no-playlist --referer "$aw_hls_download_referer" --format "$aw_hls_download_format" --output "$ANIWATCH_DOWNLOAD_DIR/%(title).180B [%(id)s].%(ext)s" -- "$aw_hls_download_manifest" && return 0
    else
        yt-dlp --no-playlist --format "$aw_hls_download_format" --output "$ANIWATCH_DOWNLOAD_DIR/%(title).180B [%(id)s].%(ext)s" -- "$aw_hls_download_manifest" && return 0
    fi
    aw_require ffmpeg
    aw_hls_safe_title=$(printf '%s' "$aw_hls_download_title" | tr '/\\:*?"<>|' '_________')
    if [ -n "$aw_hls_download_referer" ]; then
        aw_hls_ffmpeg_headers=$(printf 'Referer: %s\r\nX' "$aw_hls_download_referer")
        aw_hls_ffmpeg_headers=${aw_hls_ffmpeg_headers%X}
        ffmpeg -nostdin -y -headers "$aw_hls_ffmpeg_headers" -i "$aw_hls_download_manifest" -c copy "$ANIWATCH_DOWNLOAD_DIR/$aw_hls_safe_title.mp4"
    else
        ffmpeg -nostdin -y -i "$aw_hls_download_manifest" -c copy "$ANIWATCH_DOWNLOAD_DIR/$aw_hls_safe_title.mp4"
    fi
}
