#!/bin/sh

aw_usage() {
    cat <<'EOF'
AniWatch — modular anime discovery CLI

Usage:
  aniwatch search <query>       Search anime metadata
  aniwatch top                  Show popular anime
  aniwatch random               Discover a random anime
  aniwatch season               Show this season's anime
  aniwatch season YEAR SEASON   Browse a season (winter/spring/summer/autumn)
  aniwatch info <id>            Show full anime details by MAL ID
  aniwatch play <url>           Play a direct media URL with mpv/VLC
  aniwatch                      Interactive search (fzf required)

Dependencies:
  curl, jq                      Required for metadata commands
  fzf                           Required for interactive selection
  mpv or VLC                    Required only for direct URL playback

Configuration:
  ANIWATCH_API_URL              Metadata API base URL
  ANIWATCH_LIMIT                Result count (default: 10)
  ANIWATCH_PLAYER               Preferred player (default: mpv)

Metadata comes from Jikan (MyAnimeList). It does not provide streaming links.
AniWatch does not scrape or host video content.
EOF
}
