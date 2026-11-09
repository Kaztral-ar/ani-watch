#!/bin/sh

aw_search_command() {
    [ "$#" -gt 0 ] || aw_die "search requires a query; run 'aniwatch help'"
    aw_check_deps
    aw_data=$(aw_search "$*") || aw_die "anime search request failed"
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
aw_hianime_search_command() {
    [ "$#" -gt 0 ] || aw_die "hianime-search requires a query"
    aw_check_deps
    aw_data=$(aw_hianime_search "$*") || aw_die "HiAnime search request failed"
    aw_hianime_print_search "$aw_data"
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
    command -v fzf >/dev/null 2>&1 || aw_die "interactive mode requires fzf; run 'aniwatch search QUERY' instead"
    aw_header
    printf 'Search anime metadata: '
    IFS= read -r aw_query || exit 0
    [ -n "$aw_query" ] || aw_die "search query cannot be empty"
    aw_data=$(aw_search "$aw_query") || aw_die "anime search request failed"
    aw_pick_search_result "$aw_data"
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
        hianime-search) shift; aw_hianime_search_command "$@" ;;
        episodes) shift; aw_hianime_episodes_command "$@" ;;
        servers) shift; aw_hianime_servers_command "$@" ;;
        top) shift; aw_top_command ;;
        random) shift; aw_random_command ;;
        season) shift; aw_season_command "$@" ;;
        info) shift; aw_info_command "$@" ;;
        watch|play) shift; aw_media_command "$@" ;;
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
