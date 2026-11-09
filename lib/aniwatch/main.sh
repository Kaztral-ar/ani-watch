#!/bin/sh

aw_search_command() {
    [ "$#" -gt 0 ] || aw_die "search requires a query; run 'aniwatch help'"
    aw_check_deps
    aw_data=$(aw_hianime_search "$*") || aw_die "HiAnime search request failed"
    aw_hianime_print_search "$aw_data"
}
aw_metadata_search_command() {
    [ "$#" -gt 0 ] || aw_die "metadata-search requires a query"
    aw_check_deps
    aw_data=$(aw_search "$*") || aw_die "Jikan metadata search request failed"
    aw_show_results "$aw_data"
}
aw_top_command() {
    aw_check_deps
    aw_data=$(aw_top) || aw_die "could not retrieve popular anime"
    aw_show_results "$aw_data"
}
aw_random_command() {
    aw_check_deps
    aw_data=$(aw_random) || aw_die "could not retrieve a random anime"
    aw_print_info <<EOF
$aw_data
EOF
}
aw_season_command() {
    aw_check_deps
    if [ "$#" -eq 0 ]; then aw_data=$(aw_season_now) || aw_die "could not retrieve current season"
    elif [ "$#" -eq 2 ]; then aw_data=$(aw_season "$1" "$2") || aw_die "could not retrieve requested season"
    else aw_die "season accepts either no arguments or YEAR SEASON"; fi
    aw_show_results "$aw_data"
}
aw_info_command() {
    [ "$#" -eq 1 ] || aw_die "info requires one numeric anime ID"
    case "$1" in ''|*[!0-9]*|0) aw_die "anime ID must be a positive integer" ;; esac
    aw_check_deps
    aw_data=$(aw_info_by_id "$1") || aw_die "could not retrieve anime details"
    printf '%s\n' "$aw_data" | aw_print_info
}
aw_hianime_episodes_command() {
    [ "$#" -eq 1 ] || aw_die "episodes requires one HiAnime anime ID/slug"
    aw_check_deps
    aw_data=$(aw_hianime_episodes "$1") || aw_die "could not retrieve HiAnime episodes"
    aw_hianime_print_episodes "$aw_data"
}
aw_hianime_servers_command() {
    [ "$#" -eq 1 ] || aw_die "servers requires one numeric episode ID"
    aw_check_deps
    aw_data=$(aw_hianime_servers "$1") || aw_die "could not retrieve HiAnime server list"
    aw_hianime_print_servers "$aw_data"
}
aw_interactive() {
    aw_check_deps
    command -v fzf >/dev/null 2>&1 || aw_die "interactive mode requires fzf; install it or use 'aniwatch search QUERY'"
    aw_header
    printf 'Search HiAnime: '
    IFS= read -r aw_query || exit 0
    [ -n "$aw_query" ] || aw_die "search query cannot be empty"
    aw_data=$(aw_hianime_search "$aw_query") || aw_die "HiAnime search request failed"
    [ -n "$aw_data" ] || aw_die "no HiAnime results found"
    aw_choice=$(printf '%s\n' "$aw_data" | fzf --with-nth=2 --delimiter="$(printf '\t')" --prompt='Select anime> ') || return 1
    aw_slug=$(printf '%s\n' "$aw_choice" | cut -f 1)
    aw_title=$(printf '%s\n' "$aw_choice" | cut -f 2)
    aw_data=$(aw_hianime_episodes "$aw_slug") || aw_die "could not retrieve episodes"
    [ -n "$aw_data" ] || aw_die "no episodes found"
    aw_episode=$(printf '%s\n' "$aw_data" | fzf --with-nth=2 --delimiter="$(printf '\t')" --prompt='Select episode> ') || return 1
    aw_episode_id=$(printf '%s\n' "$aw_episode" | cut -f 1)
    aw_episode_no=$(printf '%s\n' "$aw_episode" | cut -f 2)
    aw_data=$(aw_hianime_servers "$aw_episode_id") || aw_die "could not retrieve servers"
    [ -n "$aw_data" ] || aw_die "no servers found"
    aw_server=$(printf '%s\n' "$aw_data" | fzf --with-nth=1,2 --delimiter="$(printf '\t')" --prompt='Select sub/dub server> ') || return 1
    aw_mode=$(printf '%s\n' "$aw_server" | cut -f 1)
    aw_server_name=$(printf '%s\n' "$aw_server" | cut -f 2)
    aw_stream=$(printf '%s\n' "$aw_server" | cut -f 4)
    [ -n "$aw_stream" ] || aw_die "selected server ($aw_server_name) exposes no direct stream URL; AniWatch will not decode protected embeds or bypass access controls"
    aw_media_title="$aw_title Episode $aw_episode_no"
    case "$aw_stream" in
        *.m3u8*|*.m3u*) aw_play_hls "$aw_stream" "$ANIWATCH_QUALITY" "$ANIWATCH_HIANIME_BASE" "$aw_media_title" ;;
        *) aw_play_url "$aw_stream" "$ANIWATCH_QUALITY" "$aw_mode" ;;
    esac
}
aw_hls_command() {
    [ "$#" -ge 1 ] || aw_die "hls requires a manifest URL"
    aw_manifest=$1; shift
    aw_quality=${1:-$ANIWATCH_QUALITY}
    aw_referer=${2:-}
    aw_title=${3:-AniWatch}
    aw_hls_select_variant "$aw_manifest" "$aw_quality" "$aw_referer" >/dev/null || aw_die "HLS manifest resolution failed"
    aw_play_hls "$aw_manifest" "$aw_quality" "$aw_referer" "$aw_title"
}
aw_hls_download_command() {
    [ "$#" -ge 1 ] || aw_die "hls-download requires a manifest URL"
    aw_manifest=$1; shift
    aw_quality=${1:-$ANIWATCH_QUALITY}
    aw_referer=${2:-}
    aw_download_hls "$aw_manifest" "$aw_quality" "$aw_referer"
}
aw_media_command() {
    [ "$#" -ge 1 ] || aw_die "watch requires a URL"
    aw_url=$1; shift
    aw_quality=${1:-$ANIWATCH_QUALITY}
    aw_mode=${2:-$ANIWATCH_MODE}
    aw_quality_format "$aw_quality" "$aw_mode" >/dev/null
    aw_play_url "$aw_url" "$aw_quality" "$aw_mode"
}
aw_download_command() {
    [ "$#" -ge 1 ] || aw_die "download requires a URL"
    aw_url=$1; shift
    aw_quality=${1:-$ANIWATCH_QUALITY}
    aw_mode=${2:-$ANIWATCH_MODE}
    aw_quality_format "$aw_quality" "$aw_mode" >/dev/null
    aw_download_url "$aw_url" "$aw_quality" "$aw_mode"
}
aniwatch_main() {
    case "${1:-}" in
        search) shift; aw_search_command "$@" ;;
        metadata-search) shift; aw_metadata_search_command "$@" ;;
        episodes) shift; aw_hianime_episodes_command "$@" ;;
        servers) shift; aw_hianime_servers_command "$@" ;;
        top) shift; aw_top_command ;;
        random) shift; aw_random_command ;;
        season) shift; aw_season_command "$@" ;;
        info) shift; aw_info_command "$@" ;;
        watch|play) shift; aw_media_command "$@" ;;
        hls) shift; aw_hls_command "$@" ;;
        hls-download) shift; aw_hls_download_command "$@" ;;
        download) shift; aw_download_command "$@" ;;
        history) shift; [ "$#" -eq 0 ] || aw_die "history takes no arguments"; aw_history_list ;;
        continue) shift; [ "$#" -eq 0 ] || aw_die "continue takes no arguments"; aw_history_continue ;;
        history-clear) shift; [ "$#" -eq 0 ] || aw_die "history-clear takes no arguments"; aw_history_clear ;;
        syncplay) shift; [ "$#" -eq 1 ] || aw_die "syncplay requires one URL"; aw_syncplay_url "$1" ;;
        help|-h|--help) aw_usage ;;
        version|-V|--version) printf '%s\n' "AniWatch 1.3.0" ;;
        '') aw_interactive ;;
        *) aw_usage >&2; aw_die "unknown command: $1" ;;
    esac
}
