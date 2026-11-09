#!/bin/sh
# HiAnime provider adapter. The site endpoints are unofficial and may change.
# This module lists titles, episodes and server labels. It does not decode
# obfuscated embed-player payloads or bypass access controls.

aw_hianime_validate_slug() {
    case "$1" in
        ''|*[!a-zA-Z0-9_-]*) aw_die "anime ID must be a valid HiAnime slug" ;;
    esac
}

aw_hianime_validate_episode_id() {
    case "$1" in
        ''|*[!0-9]*|0) aw_die "episode ID must be a positive integer" ;;
    esac
}

aw_hianime_search() {
    [ -n "$1" ] || aw_die "search query cannot be empty"
    aw_hq=$(aw_encode "$1")
    aw_page=$(aw_get_html "${ANIWATCH_HIANIME_BASE}/search?keyword=${aw_hq}") || return 1
    printf '%s' "$aw_page" | tr '\n' ' ' |
        sed 's|<div class="film-detail">|\n<div class="film-detail">|g' |
        sed -nE 's|.*<a href="[^"]*/([^"/?]+)"[^>]*title="([^"]*)".*|\1\t\2|p' |
        sed -e "s|&#039;|'|g" -e 's|&quot;|"|g' -e 's|&amp;|\&|g'
}

aw_hianime_response_html() {
    jq -r 'if type == "object" then (.html // .data.html // .result.html // empty) else empty end' 2>/dev/null
}

aw_hianime_episodes() {
    aw_hianime_validate_slug "$1"
    aw_json=$(aw_get "${ANIWATCH_HIANIME_BASE}/api/theme/episode/list/$1") || return 1
    aw_html=$(printf '%s' "$aw_json" | aw_hianime_response_html)
    [ -n "$aw_html" ] || return 1
    aw_hianime_parse_episodes "$aw_html"
}

aw_hianime_parse_episodes() {
    printf '%s\n' "$1" | sed 's|ep-item|\nep-item|g' |
    while IFS= read -r aw_item; do
        aw_number=$(printf '%s' "$aw_item" | sed -nE 's|.*data-number="([^"]*)".*|\1|p')
        aw_id=$(printf '%s' "$aw_item" | sed -nE 's|.*data-id="([0-9]+)".*|\1|p')
        if [ -n "$aw_number" ] && [ -n "$aw_id" ]; then
            printf '%s\t%s\n' "$aw_id" "$aw_number"
        fi
    done
}

aw_hianime_servers() {
    aw_hianime_validate_episode_id "$1"
    aw_json=$(aw_get "${ANIWATCH_HIANIME_BASE}/api/theme/episode/servers?episodeId=$1") || return 1
    aw_html=$(printf '%s' "$aw_json" | aw_hianime_response_html)
    [ -n "$aw_html" ] || return 1
    aw_hianime_parse_servers "$aw_html"
}

aw_hianime_parse_servers() {
    printf '%s\n' "$1" | sed 's|server-item|\nserver-item|g' |
    while IFS= read -r aw_item; do
        aw_type=$(printf '%s' "$aw_item" | sed -nE 's|.*data-type="([^"]*)".*|\1|p')
        aw_name=$(printf '%s' "$aw_item" | sed -nE 's|.*data-server-name="([^"]*)".*|\1|p')
        aw_id=$(printf '%s' "$aw_item" | sed -nE 's|.*data-id="([^"]*)".*|\1|p')
        aw_url=$(printf '%s' "$aw_item" | sed -nE 's~.*data-(link|url|src)="(https?://[^"]+)".*~\2~p')
        if [ -n "$aw_type" ] && [ -n "$aw_name" ]; then
            aw_name=$(printf '%s' "$aw_name" | sed -e "s|&#039;|'|g" -e 's|&amp;|\&|g')
            aw_url=$(printf '%s' "$aw_url" | sed 's|&amp;|\&|g')
            printf '%s\t%s\t%s\t%s\n' "$aw_type" "$aw_name" "$aw_id" "$aw_url"
        fi
    done
}

aw_hianime_print_search() {
    if [ -z "$1" ]; then printf '%s\n' "No HiAnime search results found."; return 0; fi
    printf '%s\n' "$1" | awk -F '\t' 'BEGIN { printf "%-42s %s\n", "ANIME ID", "TITLE"; print "----------------------------------------------------------------" } { printf "%-42s %s\n", $1, $2 }'
}

aw_hianime_print_episodes() {
    if [ -z "$1" ]; then printf '%s\n' "No episodes found."; return 0; fi
    printf '%s\n' "$1" | awk -F '\t' 'BEGIN { printf "%-14s %s\n", "EPISODE ID", "EPISODE"; print "--------------------------------" } { printf "%-14s %s\n", $1, $2 }'
}

aw_hianime_print_servers() {
    if [ -z "$1" ]; then printf '%s\n' "No server entries found."; return 0; fi
    printf '%s\n' "$1" | awk -F '\t' 'BEGIN { printf "%-8s %-24s %s\n", "TYPE", "SERVER", "ID"; print "-----------------------------------------------" } { printf "%-8s %-24s %s\n", $1, $2, $3 }'
}
