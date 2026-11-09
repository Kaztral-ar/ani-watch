#!/bin/sh
# Metadata provider adapter. Jikan exposes public MyAnimeList metadata;
# it does not provide video streams or episode playback URLs.

aw_search() {
    aw_query=$(aw_encode "$1")
    aw_get "${ANIWATCH_API_URL}/anime?q=${aw_query}&limit=${ANIWATCH_LIMIT}&sfw=true"
}

aw_top() {
    aw_get "${ANIWATCH_API_URL}/top/anime?limit=${ANIWATCH_LIMIT}&filter=bypopularity"
}

aw_info_by_id() {
    case "$1" in
        ''|*[!0-9]*) aw_die "anime ID must be a positive integer" ;;
    esac
    aw_get "${ANIWATCH_API_URL}/anime/$1/full"
}

aw_print_results() {
    jq -r '
      .data // [] |
      if length == 0 then "No anime found."
      else
        .[] |
        [
          (.mal_id|tostring),
          (.title_english // .title // "Untitled"),
          ("Score: " + ((.score // "N/A")|tostring)),
          ("Episodes: " + ((.episodes // "Unknown")|tostring)),
          (.type // "Unknown")
        ] | @tsv
      end
    '
}

aw_print_info() {
    jq -r '
      .data |
      "Title: " + (.title_english // .title // "Unknown") +
      "\nJapanese: " + (.title_japanese // "Unknown") +
      "\nType: " + (.type // "Unknown") +
      "\nEpisodes: " + ((.episodes // "Unknown")|tostring) +
      "\nStatus: " + (.status // "Unknown") +
      "\nScore: " + ((.score // "N/A")|tostring) +
      "\nSynopsis: " + ((.synopsis // "No synopsis available.")|gsub("\\r";""))
    '
}
