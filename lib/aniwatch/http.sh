#!/bin/sh

aw_get() {
    aw_url=$1
    curl --fail --silent --show-error --location \
        --connect-timeout 10 --max-time 30 \
        -H 'Accept: application/json' \
        -H 'User-Agent: AniWatch-CLI/1.0' \
        "$aw_url"
}

aw_encode() {
    jq -rn --arg value "$1" '$value|@uri'
}
