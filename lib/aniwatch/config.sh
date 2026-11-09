#!/bin/sh

: "${ANIWATCH_API_URL:=https://api.jikan.moe/v4}"
: "${ANIWATCH_LIMIT:=10}"
: "${ANIWATCH_PLAYER:=mpv}"
export ANIWATCH_API_URL ANIWATCH_LIMIT ANIWATCH_PLAYER

aw_check_deps() {
    aw_require curl
    aw_require jq
}
