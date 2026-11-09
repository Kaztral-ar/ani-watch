#!/bin/sh
aw_usage() {
    cat <<'EOF'
AniWatch — modular anime discovery and playback CLI

Discovery:
  aniwatch search <query>           Search Jikan anime metadata
  aniwatch hianime-search <query>    Search HiAnime titles
  aniwatch episodes <anime_id>      List HiAnime episodes
  aniwatch servers <episode_id>     List available server labels
  aniwatch top                      Show popular anime
  aniwatch random                   Discover a random anime
  aniwatch season [YEAR SEASON]     Browse seasonal anime
  aniwatch info <id>                Show anime details

Playback (URL must be supported by yt-dlp):
  aniwatch watch <url> [quality] [sub|dub]
  aniwatch play <url> [quality] [sub|dub]
  aniwatch download <url> [quality] [sub|dub]
  aniwatch syncplay <url>
  aniwatch history                  Show watch history
  aniwatch continue                 Resume last history URL
  aniwatch history-clear            Clear watch history

Quality: best, worst, 360p, 480p, 720p, 1080p
Mode:    sub (Japanese audio preference), dub (English audio preference)

Dependencies:
  curl, jq        Metadata and provider requests
  fzf             Interactive selection
  yt-dlp          Stream extraction and downloads
  mpv             Playback and Syncplay player
  syncplay        Synchronized viewing (optional)

Configuration:
  ANIWATCH_API_URL=https://api.jikan.moe/v4
  ANIWATCH_HIANIME_BASE=https://hianime.at
  ANIWATCH_QUALITY=best
  ANIWATCH_MODE=sub
  ANIWATCH_DOWNLOAD_DIR=.
  ANIWATCH_STATE_DIR=$HOME/.local/state/aniwatch
  ANIWATCH_SYNCPLAY_SERVER=syncplay.pl:8995

HiAnime search uses the site's HTML search page. Episode and server
commands use its page endpoints. These unofficial endpoints may change
or reject automated requests. Server listings are metadata, not direct
playable video URLs. AniWatch does not bypass DRM or access controls.
EOF
}
