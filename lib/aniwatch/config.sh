#!/bin/sh

: "${ANIWATCH_API_URL:=https://api.jikan.moe/v4}"
: "${ANIWATCH_HIANIME_BASE:=https://hianime.at}"
: "${ANIWATCH_LIMIT:=10}"
: "${ANIWATCH_MENU:=fzf}"
: "${ANIWATCH_QUALITY:=best}"
: "${ANIWATCH_MODE:=sub}"
: "${ANIWATCH_DOWNLOAD_DIR:=.}"
: "${ANIWATCH_STATE_DIR:=${XDG_STATE_HOME:-$HOME/.local/state}/aniwatch}"
: "${ANIWATCH_HISTORY:=${ANIWATCH_STATE_DIR}/history.tsv}"
: "${ANIWATCH_SYNCPLAY_SERVER:=syncplay.pl:8995}"
export ANIWATCH_API_URL ANIWATCH_HIANIME_BASE ANIWATCH_LIMIT ANIWATCH_MENU
export ANIWATCH_QUALITY ANIWATCH_MODE ANIWATCH_DOWNLOAD_DIR
export ANIWATCH_STATE_DIR ANIWATCH_HISTORY ANIWATCH_SYNCPLAY_SERVER

aw_check_deps() {
    aw_require curl
    aw_require jq
    case "$ANIWATCH_LIMIT" in
        ''|*[!0-9]*|0) aw_die "ANIWATCH_LIMIT must be a positive integer" ;;
    esac
}

aw_check_media_deps() {
    aw_require yt-dlp
    aw_require mpv
}
