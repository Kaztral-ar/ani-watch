#!/bin/sh

: "${ANIWATCH_API_URL:=https://api.jikan.moe/v4}"
: "${ANIWATCH_LIMIT:=10}"
: "${ANIWATCH_PLAYER:=mpv}"
: "${ANIWATCH_MENU:=fzf}"
export ANIWATCH_API_URL ANIWATCH_LIMIT ANIWATCH_PLAYER ANIWATCH_MENU

aw_check_deps() {
    aw_require curl
    aw_require jq
    case "$ANIWATCH_LIMIT" in
        ''|*[!0-9]*|0) aw_die "ANIWATCH_LIMIT must be a positive integer" ;;
    esac
}
