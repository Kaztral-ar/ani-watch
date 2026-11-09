#!/bin/sh

aw_get() {
    aw_url=$1
    curl --fail --silent --show-error --location \
        --connect-timeout 10 --max-time 30 --retry 2 --retry-delay 1 \
        -H 'Accept: application/json' \
        -H 'User-Agent: AniWatch-CLI/1.0' \
        "$aw_url"
}

aw_get_html() {
    aw_url=$1
    curl --fail --silent --show-error --location \
        --connect-timeout 10 --max-time 30 \
        -H 'Accept: text/html,application/xhtml+xml' \
        -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/124.0 Safari/537.36' \
        "$aw_url"
}

aw_encode() {
    jq -rn --arg value "$1" '$value|@uri'
}
