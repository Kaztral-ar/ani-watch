#!/bin/sh

aw_usage() {
    cat <<'EOF'
AniWatch — modular anime discovery and playback CLI

Discovery:
  aniwatch search <query>           Search anime metadata
  aniwatch top                      Show popular anime
  aniwatch random                   Discover a random anime
  aniwatch season [YEAR SEASON]     Browse seasonal anime
  aniwatch info <id>                Show anime details

Playback (URL must be accessible to yt-dlp):
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
  curl, jq        Metadata commands
  fzf             Interactive selection
  yt-dlp          URL extraction and downloads
  mpv             Playback (default)
  syncplay        Synchronized viewing (optional)

Configuration:
  ANIWATCH_PLAYER=mpv
  ANIWATCH_QUALITY=best
  ANIWATCH_MODE=sub
  ANIWATCH_DOWNLOAD_DIR=.
  ANIWATCH_STATE_DIR=$HOME/.local/state/aniwatch
  ANIWATCH_SYNCPLAY_SERVER=syncplay.pl:8995

Jikan is a metadata provider, not a streaming provider. Playback depends
on the URL being supported by yt-dlp and accessible to your account.
No DRM or access-control bypass is performed.
EOF
}
