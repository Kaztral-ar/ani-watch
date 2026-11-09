#!/bin/sh

aw_usage() {
    cat <<'EOF'
AniWatch — anime discovery from your terminal

Usage:
  aniwatch search <query>   Search anime titles
  aniwatch top              Show popular anime
  aniwatch info <id>        Show full anime details by MAL ID
  aniwatch play <url>       Play a direct media URL with mpv/VLC
  aniwatch                  Start interactive mode
  aniwatch help             Show this help

Dependencies:
  curl, jq                  Required for metadata commands
  mpv or VLC                Required only for the play command

Configuration:
  ANIWATCH_API_URL          Metadata API base URL
  ANIWATCH_LIMIT            Search/top result count (default: 10)
  ANIWATCH_PLAYER           Preferred player (default: mpv)

Metadata is provided by Jikan (MyAnimeList). Jikan does not provide
streaming links; AniWatch does not scrape or host video content.
EOF
}
