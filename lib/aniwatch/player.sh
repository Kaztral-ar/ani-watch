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
    aw_h_url=$1
    aw_h_title=$2
    aw_h_anime_id=${3:-}
    aw_h_episode=${4:-}
    aw_h_referer=${5:-}
    aw_h_mode=${6:-}
    umask 077
    mkdir -p "$ANIWATCH_STATE_DIR" || aw_die "cannot create state directory"
    aw_h_now=$(date '+%Y-%m-%dT%H:%M:%S%z')
    aw_h_safe_title=$(printf '%s' "$aw_h_title" | tr '\t\r\n' '   ')
    aw_h_safe_url=$(printf '%s' "$aw_h_url" | tr '\t\r\n' '   ')
    aw_h_safe_anime=$(printf '%s' "$aw_h_anime_id" | tr '\t\r\n' '   ')
    aw_h_safe_episode=$(printf '%s' "$aw_h_episode" | tr '\t\r\n' '   ')
    aw_h_safe_referer=$(printf '%s' "$aw_h_referer" | tr '\t\r\n' '   ')
    aw_h_safe_mode=$(printf '%s' "$aw_h_mode" | tr '\t\r\n' '   ')
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$aw_h_now" "$aw_h_safe_anime" "$aw_h_safe_episode" "$aw_h_safe_title" "$aw_h_safe_url" "$aw_h_safe_referer" "$aw_h_safe_mode" >> "$ANIWATCH_HISTORY"
    chmod 600 "$ANIWATCH_HISTORY" 2>/dev/null || :
    aw_h_tmp="$ANIWATCH_HISTORY.tmp"
    if [ "$(wc -l < "$ANIWATCH_HISTORY" | tr -d ' ')" -gt 500 ]; then
        tail -n 500 "$ANIWATCH_HISTORY" > "$aw_h_tmp" && mv "$aw_h_tmp" "$ANIWATCH_HISTORY"
        chmod 600 "$ANIWATCH_HISTORY" 2>/dev/null || :
    fi
}

aw_aniskip_flags() {
    aw_skip_mal_id=$1
    aw_skip_episode_no=$2
    [ "$ANIWATCH_SKIP_INTRO" = "1" ] || return 1
    [ -n "$aw_skip_mal_id" ] && [ -n "$aw_skip_episode_no" ] || return 1
    command -v ani-skip >/dev/null 2>&1 || return 1
    ani-skip -i "$aw_skip_mal_id" -e "$aw_skip_episode_no" 2>/dev/null
}

aw_play_url() {
    aw_play_url_value=$1
    aw_play_quality=${2:-$ANIWATCH_QUALITY}
    aw_play_mode=${3:-$ANIWATCH_MODE}
    aw_play_title=${4:-AniWatch}
    aw_play_mal_id=${5:-}
    aw_play_episode_no=${6:-}
    aw_play_referer=${7:-}
    aw_validate_url "$aw_play_url_value"
    case "$ANIWATCH_PLAYER" in
        mpv)
            aw_require mpv
            aw_require yt-dlp
            aw_play_format=$(aw_quality_format "$aw_play_quality" "$aw_play_mode")
            aw_play_audio=$(aw_audio_language "$aw_play_mode")
            aw_play_skip_flags=$(aw_aniskip_flags "$aw_play_mal_id" "$aw_play_episode_no" || :)
            if [ -n "$aw_play_skip_flags" ]; then
                # ani-skip emits MPV options. Disable pathname expansion while splitting them.
                case $- in
                    *f*) aw_play_noglob=1 ;;
                    *) aw_play_noglob=0; set -f ;;
                esac
                if [ -n "$aw_play_referer" ]; then
                    # shellcheck disable=SC2086
                    mpv 
                    # shellcheck disable=SC2086
                    mpv $aw_
 --referrer="$aw_play_referer" --force-media-title="$aw_play_title" --ytdl-format="$aw_play_format" --alang="$aw_play_audio" --slang="en,eng" -- "$aw_play_url_value"
                    aw_play_status=$?
                else
                    # shellcheck disable=SC2086
                    mpv 
                    # shellcheck disable=SC2086
                    mpv $aw_
 --force-media-title="$aw_play_title" --ytdl-format="$aw_play_format" --alang="$aw_play_audio" --slang="en,eng" -- "$aw_play_url_value"
                    aw_play_status=$?
                fi
                [ "$aw_play_noglob" -eq 1 ] || set +f
            else
                [ "$ANIWATCH_SKIP_INTRO" != "1" ] || aw_info "Ani-Skip unavailable or no skip data for this episode"
                if [ -n "$aw_play_referer" ]; then
                    mpv --referrer="$aw_play_referer" --force-media-title="$aw_play_title" --ytdl-format="$aw_play_format" --alang="$aw_play_audio" --slang="en,eng" -- "$aw_play_url_value"
                    aw_play_status=$?
                else
                    mpv --force-media-title="$aw_play_title" --ytdl-format="$aw_play_format" --alang="$aw_play_audio" --slang="en,eng" -- "$aw_play_url_value"
                    aw_play_status=$?
                fi
            fi
            ;;
        vlc)
            aw_require vlc
            [ "$ANIWATCH_SKIP_INTRO" != "1" ] || aw_info "Ani-Skip integration is MPV-only"
            if [ -n "$aw_play_referer" ]; then
                vlc --http-referrer="$aw_play_referer" --meta-title="$aw_play_title" -- "$aw_play_url_value"
                aw_play_status=$?
            else
                vlc --meta-title="$aw_play_title" -- "$aw_play_url_value"
                aw_play_status=$?
            fi
            ;;
        *) aw_die "ANIWATCH_PLAYER must be mpv or vlc" ;;
    esac
    if [ "$aw_play_status" -eq 0 ]; then
        aw_history_add "$aw_play_url_value" "$aw_play_title" "$aw_play_mal_id" "$aw_play_episode_no" "$aw_play_referer" "$aw_play_mode"
    fi
    return "$aw_play_status"
}

aw_download_url() {
    aw_download_url_value=$1
    aw_download_quality=${2:-$ANIWATCH_QUALITY}
    aw_download_mode=${3:-$ANIWATCH_MODE}
    aw_validate_url "$aw_download_url_value"
    aw_require yt-dlp
    aw_download_format=$(aw_quality_format "$aw_download_quality" "$aw_download_mode")
    mkdir -p "$ANIWATCH_DOWNLOAD_DIR" || aw_die "cannot create download directory"
    if command -v ffmpeg >/dev/null 2>&1; then
        yt-dlp --no-playlist --format "$aw_download_format" \
            --write-subs --write-auto-subs --sub-langs "en,eng" --embed-subs \
            --output "$ANIWATCH_DOWNLOAD_DIR/%(title).180B [%(id)s].%(ext)s" -- "$aw_download_url_value"
    else
        aw_info "ffmpeg not found; subtitles will be downloaded but not embedded"
        yt-dlp --no-playlist --format "$aw_download_format" \
            --write-subs --write-auto-subs --sub-langs "en,eng" \
            --output "$ANIWATCH_DOWNLOAD_DIR/%(title).180B [%(id)s].%(ext)s" -- "$aw_download_url_value"
    fi
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
    aw_continue_last=$(tail -n 1 "$ANIWATCH_HISTORY")
    aw_continue_fields=$(printf '%s\n' "$aw_continue_last" | awk -F '\t' '{print NF}')
    if [ "$aw_continue_fields" -ge 5 ]; then
        aw_continue_url=$(printf '%s\n' "$aw_continue_last" | cut -f 5)
        aw_continue_referer=$(printf '%s\n' "$aw_continue_last" | cut -f 6)
        aw_continue_title=$(printf '%s\n' "$aw_continue_last" | cut -f 4)
        aw_continue_mode=$(printf '%s\n' "$aw_continue_last" | cut -f 7)
        case "$aw_continue_mode" in sub|dub) ;; *) aw_continue_mode=$ANIWATCH_MODE ;; esac
    else
        aw_continue_url=$(printf '%s\n' "$aw_continue_last" | cut -f 3-)
        aw_continue_referer=
        aw_continue_title="Continue watching"
        aw_continue_mode=$ANIWATCH_MODE
    fi
    [ -n "$aw_continue_url" ] || aw_die "last history entry has no URL"
    case "$aw_continue_url" in
        *.m3u8*|*.m3u*) aw_play_hls "$aw_continue_url" "$ANIWATCH_QUALITY" "$aw_continue_referer" "$aw_continue_title" "" "" "" "$aw_continue_mode" ;;
        *) aw_play_url "$aw_continue_url" "$ANIWATCH_QUALITY" "$aw_continue_mode" "$aw_continue_title" "" "" "$aw_continue_referer" ;;
    esac
}

aw_history_clear() {
    if [ -f "$ANIWATCH_HISTORY" ]; then
        : > "$ANIWATCH_HISTORY" || aw_die "cannot clear watch history"
    fi
    printf '%s\n' "Watch history cleared."
}

aw_syncplay_url() {
    aw_sync_url=$1
    aw_validate_url "$aw_sync_url"
    aw_require syncplay
    aw_require mpv
    syncplay --no-gui --player-path "$(command -v mpv)" --host "$ANIWATCH_SYNCPLAY_SERVER" -- "$aw_sync_url"
}
