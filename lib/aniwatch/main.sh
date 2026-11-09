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
    if [ "$#" -eq 0 ]; then
        aw_data=$(aw_season_now) || aw_die "could not retrieve current season"
    elif [ "$#" -eq 2 ]; then
        aw_data=$(aw_season "$1" "$2") || aw_die "could not retrieve requested season"
    else
        aw_die "season accepts either no arguments or YEAR SEASON"
    fi
    aw_show_results "$aw_data"
}

aw_info_command() {
    [ "$#" -eq 1 ] || aw_die "info requires one numeric anime ID"
    case "$1" in ''|*[!0-9]*|0) aw_die "anime ID must be a positive integer" ;; esac
    aw_check_deps
    aw_data=$(aw_info_by_id "$1") || aw_die "could not retrieve anime details"
    printf '%s\n' "$aw_data" | aw_print_info
}

aw_interactive() {
    aw_check_deps
    command -v fzf >/dev/null 2>&1 || aw_die "interactive mode requires fzf; run 'aniwatch search QUERY' instead"
    aw_header
    printf 'Search anime: '
    IFS= read -r aw_query || exit 0
    [ -n "$aw_query" ] || aw_die "search query cannot be empty"
    aw_data=$(aw_search "$aw_query") || aw_die "anime search request failed"
    aw_pick_search_result "$aw_data"
}

aniwatch_main() {
    case "${1:-}" in
        search) shift; aw_search_command "$@" ;;
        top) shift; aw_top_command ;;
        random) shift; aw_random_command ;;
        season) shift; aw_season_command "$@" ;;
        info) shift; aw_info_command "$@" ;;
        play) shift; [ "$#" -eq 1 ] || aw_die "play requires one URL"; aw_play_url "$1" ;;
        help|-h|--help) aw_usage ;;
        version|-V|--version) printf '%s\n' "AniWatch 1.1.0" ;;
        '') aw_interactive ;;
        *) aw_usage >&2; aw_die "unknown command: $1" ;;
    esac
}
