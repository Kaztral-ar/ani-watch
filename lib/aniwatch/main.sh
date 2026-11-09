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
aw_lookup_mal_id() {
    aw_title=$1
    aw_json=$(aw_search "$aw_title" 2>/dev/null) || return 1
    printf '%s' "$aw_json" | jq -r '.data[0].mal_id // empty' 2>/dev/null
}
aw_play_selected_episode() {
    aw_ep_row=$1
    aw_ep_id=$(printf '%s\n' "$aw_ep_row" | cut -f 1)
    aw_ep_no=$(printf '%s\n' "$aw_ep_row" | cut -f 2)
    aw_servers=$(aw_hianime_servers "$aw_ep_id") || aw_die "could not retrieve servers for episode $aw_ep_no"
    [ -n "$aw_servers" ] || aw_die "no servers found for episode $aw_ep_no"
    aw_server=$(printf '%s\n' "$aw_servers" | fzf --with-nth=1,2 --delimiter="$(printf '\t')" --prompt="Episode $aw_ep_no server> ") || return 1
    aw_mode=$(printf '%s\n' "$aw_server" | cut -f 1)
    aw_server_name=$(printf '%s\n' "$aw_server" | cut -f 2)
    aw_stream=$(printf '%s\n' "$aw_server" | cut -f 4)
    [ -n "$aw_stream" ] || aw_die "server $aw_server_name exposes only an opaque ID; no direct accessible stream URL is available"
    aw_media_title="$aw_title Episode $aw_ep_no"
    case "$aw_stream" in
        *.m3u8*|*.m3u*) aw_play_hls "$aw_stream" "$ANIWATCH_QUALITY" "$ANIWATCH_HIANIME_BASE" "$aw_media_title" "$aw_slug" "$aw_ep_no" "$aw_mal_id" ;;
        *) aw_play_url "$aw_stream" "$ANIWATCH_QUALITY" "$aw_mode" "$aw_media_title" "$aw_mal_id" "$aw_ep_no" "$ANIWATCH_HIANIME_BASE" ;;
    esac
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
    aw_mal_id=$(aw_lookup_mal_id "$aw_title" || :)
    aw_episode_rows=$(aw_hianime_episodes "$aw_slug") || aw_die "could not retrieve episodes"
    [ -n "$aw_episode_rows" ] || aw_die "no episodes found"
    aw_episode=$(printf '%s\n' "$aw_episode_rows" | fzf --with-nth=2 --delimiter="$(printf '\t')" --prompt='Select episode> ') || return 1
    aw_index=$(printf '%s\n' "$aw_episode_rows" | awk -F '\t' -v id="$(printf '%s\n' "$aw_episode" | cut -f 1)" '$1==id {print NR; exit}')
    aw_total=$(printf '%s\n' "$aw_episode_rows" | wc -l | tr -d ' ')
    while [ -n "$aw_episode" ]; do
        aw_play_selected_episode "$aw_episode" || return 1
        printf '[n] next  [p] previous  [s] select episode  [q] quit: '
        IFS= read -r aw_nav || break
        case "$aw_nav" in
            n|N) [ "$aw_index" -lt "$aw_total" ] || { aw_info "Already at the last listed episode"; continue; }; aw_index=$((aw_index + 1)); aw_episode=$(printf '%s\n' "$aw_episode_rows" | sed -n "${aw_index}p") ;;
            p|P) [ "$aw_index" -gt 1 ] || { aw_info "Already at the first listed episode"; continue; }; aw_index=$((aw_index - 1)); aw_episode=$(printf '%s\n' "$aw_episode_rows" | sed -n "${aw_index}p") ;;
            s|S) aw_episode=$(printf '%s\n' "$aw_episode_rows" | fzf --with-nth=2 --delimiter="$(printf '\t')" --prompt='Select episode> ') || break; aw_index=$(printf '%s\n' "$aw_episode_rows" | awk -F '\t' -v id="$(printf '%s\n' "$aw_episode" | cut -f 1)" '$1==id {print NR; exit}') ;;
            *) break ;;
        esac
    done
}
aw_download_range_command() {
    [ "$#" -ge 2 ] || aw_die "bulk-download requires ANIME_SLUG and START-END"
    aw_slug=$1
    aw_range=$2
    aw_mode=${3:-$ANIWATCH_MODE}
    aw_quality=${4:-$ANIWATCH_QUALITY}
    case "$aw_range" in
        *-*) aw_start=${aw_range%-*}; aw_end=${aw_range#*-} ;;
        *) aw_start=$aw_range; aw_end=$aw_range ;;
    esac
    case "$aw_start:$aw_end" in *[!0-9:]*|:*|*:) aw_die "episode range must be numeric, for example 1-12" ;; esac
    [ "$aw_start" -gt 0 ] && [ "$aw_end" -ge "$aw_start" ] || aw_die "invalid episode range"
    case "$aw_mode" in sub|dub) ;; *) aw_die "mode must be sub or dub" ;; esac
    aw_check_deps
    aw_episode_rows=$(aw_hianime_episodes "$aw_slug") || aw_die "could not retrieve episodes"
    aw_selected=$(printf '%s\n' "$aw_episode_rows" | awk -F '\t' -v s="$aw_start" -v e="$aw_end" '$2 ~ /^[0-9]+$/ && $2+0 >= s && $2+0 <= e {print}')
    [ -n "$aw_selected" ] || aw_die "no numbered episodes found in requested range"
    mkdir -p "$ANIWATCH_DOWNLOAD_DIR" || aw_die "cannot create download directory"
    aw_downloaded=0
    while IFS="$(printf '\t')" read -r aw_ep_id aw_ep_no; do
        [ -n "$aw_ep_id" ] || continue
        aw_servers=$(aw_hianime_servers "$aw_ep_id") || { aw_info "Skipping episode $aw_ep_no: server lookup failed"; continue; }
        aw_server=$(printf '%s\n' "$aw_servers" | awk -F '\t' -v mode="$aw_mode" 'tolower($1)==mode && $4 ~ /^https?:\/\// {print; exit}')
        aw_stream=$(printf '%s\n' "$aw_server" | cut -f 4)
        if [ -z "$aw_stream" ]; then
            aw_info "Skipping episode $aw_ep_no: no direct accessible $aw_mode stream URL"
            continue
        fi
        aw_title="$aw_slug Episode $aw_ep_no"
        aw_info "Downloading episode $aw_ep_no"
        case "$aw_stream" in
            *.m3u8*|*.m3u*) aw_download_hls "$aw_stream" "$aw_quality" "$ANIWATCH_HIANIME_BASE" "$aw_title" ;;
            *) aw_require yt-dlp; yt-dlp --no-playlist --referer "$ANIWATCH_HIANIME_BASE" --format "best[height<=${aw_quality%p}]/best" --write-subs --write-auto-subs --sub-langs "en,eng" --embed-subs --output "$ANIWATCH_DOWNLOAD_DIR/%(title).180B [%(id)s].%(ext)s" "$aw_stream" ;;
        esac || aw_info "Download failed for episode $aw_ep_no"
        aw_downloaded=$((aw_downloaded + 1))
    done <<EOF
$aw_selected
EOF
    aw_info "Bulk download finished; processed $aw_downloaded accessible episode(s)"
}

aw_hls_command() {
    [ "$#" -ge 1 ] || aw_die "hls requires a manifest URL"
    aw_manifest=$1; shift
    aw_quality=${1:-$ANIWATCH_QUALITY}
    aw_referer=${2:-}
    aw_title=${3:-AniWatch}
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
        bulk-download|download-range) shift; aw_download_range_command "$@" ;;
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
