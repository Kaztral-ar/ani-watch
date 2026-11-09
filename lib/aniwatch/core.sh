#!/bin/sh

aw_die() {
    printf 'aniwatch: %s\n' "$*" >&2
    exit 1
}

aw_info() {
    printf 'AniWatch: %s\n' "$*"
}

aw_require() {
    command -v "$1" >/dev/null 2>&1 || aw_die "required command not found: $1"
}
