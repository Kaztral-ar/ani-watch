#!/bin/sh

aw_validate_url() {
    case "$1" in
        http://*|https://*) ;;
        *) aw_die "expected an http(s) URL" ;;
    esac
}

aw_quality_format() {
    case "$1" in
        best) printf '%s' 'bestvideo*+bestaudio/best' ;;
        worst) printf '%s' 'worstvideo*+worstaudio/worst' ;;
        360p|480p|720p|1080p) printf 'bestvideo[height<=%s]+bestaudio/best[height<=%s]/best' "${1%p}" "${1%p}" ;;
        *) aw_die "quality must be best, worst, 360p, 480p, 720p, or 1080p" ;;
    esac
}

aw_audio_language() {
    case "$1" in
        sub) printf '%s' 'ja,jp,jpn,original,und' ;;
        dub) printf '%s' 'en,eng' ;;
        *) aw_die "mode must be sub or dub" ;;
    esac
}

aw_prepare_media() {
    aw_url=$1
    aw_validate_url "$aw_url"
    aw_format=$(aw_quality_format "$2")
    aw_audio=$(aw_audio_language "$3")
    aw_require yt-dlp
    aw_resolved=$(yt-dlp --no-warnings --no-playlist --format "$aw_format" --get-url "$aw_url") ||
        aw_die "could not resolve media URL; check source support and access"
    [ -n "$aw_resolved" ] || aw_die "source returned no playable media"
}

aw_history_add() {
    aw_url=$1
    aw_title=$2
    mkdir -p "$ANIWATCH_STATE_DIR" || aw_die "cannot create state directory"
    aw_now=$(date '+%Y-%m-%dT%H:%M:%S%z')
    aw_safe_title=$(printf '%s' "$aw_title" | tr '\t\r\n' '   ')
    aw_safe_url=$(printf '%s' "$aw_url" | tr '\t\r\n' '   ')
    printf '%s\t%s\t%s\n' "$aw_now" "$aw_safe_title" "$aw_safe_url" >> "$ANIWATCH_HISTORY"
}

aw_play_url() {
    aw_url=$1
    aw_quality=${2:-$ANIWATCH_QUALITY}
    aw_mode=${3:-$ANIWATCH_MODE}
    aw_prepare_media "$aw_url" "$aw_quality" "$aw_mode"
    aw_audio=$(aw_audio_language "$aw_mode")
    aw_history_add "$aw_url" "$aw_url"
    case "$ANIWATCH_PLAYER" in
        mpv)
            mpv --force-media-title="$aw_url" --alang="$aw_audio" --slang="en,eng" "$aw_url"
            ;;
        *)
            "$ANIWATCH_PLAYER" "$aw_url"
            ;;
    esac
}

aw_download_url() {
    aw_url=$1
    aw_quality=${2:-$ANIWATCH_QUALITY}
    aw_mode=${3:-$ANIWATCH_MODE}
    aw_validate_url "$aw_url"
    aw_format=$(aw_quality_format "$aw_quality")
    aw_audio=$(aw_audio_language "$aw_mode")
    aw_require yt-dlp
    mkdir -p "$ANIWATCH_DOWNLOAD_DIR" || aw_die "cannot create download directory"
    yt-dlp --no-playlist --format "$aw_format" \
        --extractor-args "generic:impersonate" \
        --embed-subs --write-subs --sub-langs "en,eng" \
        --output "$ANIWATCH_DOWNLOAD_DIR/%(title).180B [%(id)s].%(ext)s" "$aw_url"
}

aw_history_list() {
    [ -f "$ANIWATCH_HISTORY" ] || {
        printf '%s\n' "No watch history yet."
        return 0
    }
    awk -F '\t' 'BEGIN { printf "%-24s %-48s %s\n", "WATCHED AT", "TITLE", "URL" } { printf "%-24s %-48.48s %s\n", $1, $2, $3 }' "$ANIWATCH_HISTORY"
}

aw_history_continue() {
    [ -s "$ANIWATCH_HISTORY" ] || aw_die "watch history is empty"
    aw_last=$(tail -n 1 "$ANIWATCH_HISTORY")
    aw_url=$(printf '%s\n' "$aw_last" | cut -f 3-)
    [ -n "$aw_url" ] || aw_die "last history entry has no URL"
    aw_play_url "$aw_url"
}

aw_history_clear() {
    if [ -f "$ANIWATCH_HISTORY" ]; then
        : > "$ANIWATCH_HISTORY" || aw_die "cannot clear watch history"
    fi
    printf '%s\n' "Watch history cleared."
}

aw_syncplay_url() {
    aw_url=$1
    aw_validate_url "$aw_url"
    aw_require syncplay
    aw_require "$ANIWATCH_PLAYER"
    syncplay --no-gui --player-path "$ANIWATCH_PLAYER" --host "$ANIWATCH_SYNCPLAY_SERVER" "$aw_url"
}
