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

aw_info_command() {
    [ "$#" -eq 1 ] || aw_die "info requires one numeric anime ID"
    case "$1" in ''|*[!0-9]*|0) aw_die "anime ID must be a positive integer" ;; esac
    aw_check_deps
    aw_data=$(aw_info_by_id "$1") || aw_die "could not retrieve anime details"
    aw_print_info <<EOF
$aw_data
EOF
}

aw_interactive() {
    aw_header
    printf '%s\n' '1) Search anime' '2) Popular anime' '3) Exit'
    printf 'Choose: '
    IFS= read -r aw_choice || exit 0
    case "$aw_choice" in
        1)
            printf 'Search query: '
            IFS= read -r aw_query || exit 0
            aw_search_command "$aw_query"
            ;;
        2) aw_top_command ;;
        3) exit 0 ;;
        *) aw_die "invalid menu choice" ;;
    esac
}

aniwatch_main() {
    case "${1:-}" in
        search) shift; aw_search_command "$@" ;;
        top) shift; aw_top_command ;;
        info) shift; aw_info_command "$@" ;;
        play) shift; [ "$#" -eq 1 ] || aw_die "play requires one URL"; aw_play_url "$1" ;;
        help|-h|--help) aw_usage ;;
        '') aw_interactive ;;
        *) aw_usage >&2; aw_die "unknown command: $1" ;;
    esac
}
