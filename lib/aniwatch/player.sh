#!/bin/sh

aw_play_url() {
    aw_url=$1
    case "$aw_url" in
        http://*|https://*) ;;
        *) aw_die "play expects a direct http(s) media URL" ;;
    esac
    if command -v "$ANIWATCH_PLAYER" >/dev/null 2>&1; then
        "$ANIWATCH_PLAYER" "$aw_url"
    elif command -v vlc >/dev/null 2>&1; then
        vlc "$aw_url"
    else
        aw_die "install mpv or VLC to play a direct media URL"
    fi
}
