#!/bin/sh

aw_header() {
    printf '\n\033[1;36m'
    cat <<'BANNER'
     _       _  __        __       _       _
    /_\\  _ __(_)/ /  ___  / /____ _| |_ ___| |__
   //  \\| '__| | | |/ _ \\/ __/ _` | __/ __| '_ \\
  / ___ \\ |  | | |_|  __/ || (_| | || (__| | | |
 /_/   \\_\\_|  |_|\\__,\\___|\\__\\__,_|\\__\\___|_| |_|
BANNER
    printf '\033[0m\n'
}

aw_show_results() {
    aw_data=$1
    printf '%s\n' "$aw_data" | aw_print_results | awk -F '\t' 'BEGIN { printf "%-8s %-48s %-16s %-12s %s\n", "ID", "TITLE", "SCORE", "EPISODES", "TYPE"; print "-----------------------------------------------------------------------------------------------" } { printf "%-8s %-48.48s %-16s %-12s %s\n", $1, $2, $3, $4, $5 }'
}

aw_pick_search_result() {
    aw_data=$1
    command -v fzf >/dev/null 2>&1 || aw_die "interactive selection requires fzf; install it or use 'aniwatch search QUERY'"
    aw_choice=$(printf '%s\n' "$aw_data" | jq -r '.data[]? | [(.mal_id|tostring),(.title_english // .title // "Untitled"),("Score: " + ((.score // "N/A")|tostring))] | @tsv' | fzf --with-nth=2,3 --delimiter="$(printf '\t')" --prompt='Select anime> ') || return 1
    [ -n "$aw_choice" ] || return 1
    aw_id=$(printf '%s\n' "$aw_choice" | cut -f 1)
    aw_details=$(aw_info_by_id "$aw_id") || aw_die "could not retrieve selected anime details"
    printf '%s\n' "$aw_details" | aw_print_info
}
