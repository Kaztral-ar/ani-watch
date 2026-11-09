#!/bin/sh

aw_validate_url() {
    case "$1" in
        http://*|https://*) ;;
        *) aw_die "expected an http(s) URL" ;;
    esac
}

aw_quality_format() {
    aw_quality=$1
    aw_mode=$2
    case "$aw_mode" in
        sub) aw_lang='ja' ;;
        dub) aw_lang='en' ;;
        *) aw_die "mode must be sub or dub" ;;
    esac
    case "$aw_quality" in
        best) printf 'bestvideo*+bestaudio[language^=%s]/best' "$aw_lang" ;;
        worst) printf 'worstvideo*+worstaudio[language^=%s]/worst' "$aw_lang" ;;
        360p|480p|720p|1080p)
            aw_height=${aw_quality%p}
            printf 'bestvideo[height<=%s]+bestaudio[language^=%s]/best[height<=%s]' "$aw_height" "$aw_lang" "$aw_height"
            ;;
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

aw_history_add() {
    aw_url=$1
    aw_title=$2
    aw_anime_id=${3:-}
    aw_episode=${4:-}
    aw_referer=${5:-}
    mkdir -p "$ANIWATCH_STATE_DIR" || aw_die "cannot create state directory"
    aw_now=$(date '+%Y-%m-%dT%H:%M:%S%z')
    aw_safe_title=$(printf '%s' "$aw_title" | tr '\t\r\n' '   ')
    aw_safe_url=$(printf '%s' "$aw_url" | tr '\t\r\n' '   ')
    aw_safe_anime=$(printf '%s' "$aw_anime_id" | tr '\t\r\n' '   ')
    aw_safe_episode=$(printf '%s' "$aw_episode" | tr '\t\r\n' '   ')
    aw_safe_referer=$(printf '%s' "$aw_referer" | tr '\t\r\n' '   ')
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$aw_now" "$aw_safe_anime" "$aw_safe_episode" "$aw_safe_title" "$aw_safe_url" "$aw_safe_referer" >> "$ANIWATCH_HISTORY"
}

aw_play_url() {
    aw_url=$1
    aw_quality=${2:-$ANIWATCH_QUALITY}
    aw_mode=${3:-$ANIWATCH_MODE}
    aw_validate_url "$aw_url"
    aw_require yt-dlp
    aw_require mpv
    aw_format=$(aw_quality_format "$aw_quality" "$aw_mode")
    aw_audio=$(aw_audio_language "$aw_mode")
    aw_history_add "$aw_url" "$aw_url"
    mpv --ytdl-format="$aw_format" --alang="$aw_audio" --slang="en,eng" "$aw_url"
}

aw_download_url() {
    aw_url=$1
    aw_quality=${2:-$ANIWATCH_QUALITY}
    aw_mode=${3:-$ANIWATCH_MODE}
    aw_validate_url "$aw_url"
    aw_require yt-dlp
    aw_format=$(aw_quality_format "$aw_quality" "$aw_mode")
    mkdir -p "$ANIWATCH_DOWNLOAD_DIR" || aw_die "cannot create download directory"
    yt-dlp --no-playlist --format "$aw_format" \
        --write-subs --write-auto-subs --sub-langs "en,eng" --embed-subs \
        --output "$ANIWATCH_DOWNLOAD_DIR/%(title).180B [%(id)s].%(ext)s" "$aw_url"
}

aw_history_list() {
    [ -f "$ANIWATCH_HISTORY" ] || {
        printf '%s\n' "No watch history yet."
        return 0
    }
    awk -F '\t' 'BEGIN { printf "%-24s %-10s %-8s %-38s %s\n", "WATCHED AT", "ANIME ID", "EPISODE", "TITLE", "URL" } NF >= 5 { printf "%-24s %-10s %-8s %-38.38s %s\n", $1, $2, $3, $4, $5; next } { printf "%-24s %-10s %-8s %-38.38s %s\n", $1, "-", "-", $2, $3 }' "$ANIWATCH_HISTORY"
}

aw_history_continue() {
    [ -s "$ANIWATCH_HISTORY" ] || aw_die "watch history is empty"
    aw_last=$(tail -n 1 "$ANIWATCH_HISTORY")
    aw_fields=$(printf '%s\n' "$aw_last" | awk -F '\t' '{print NF}')
    if [ "$aw_fields" -ge 5 ]; then
        aw_url=$(printf '%s\n' "$aw_last" | cut -f 5)
        aw_referer=$(printf '%s\n' "$aw_last" | cut -f 6)
    else
        aw_url=$(printf '%s\n' "$aw_last" | cut -f 3-)
        aw_referer=
    fi
    [ -n "$aw_url" ] || aw_die "last history entry has no URL"
    if [ -n "$aw_referer" ]; then aw_play_hls "$aw_url" "$ANIWATCH_QUALITY" "$aw_referer" "Continue watching"; else aw_play_url "$aw_url"; fi
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
    aw_require mpv
    syncplay --no-gui --player-path "$(command -v mpv)" --host "$ANIWATCH_SYNCPLAY_SERVER" "$aw_url"
}
