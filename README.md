<div align="center">

# AniWatch

**Anime discovery and playback from your terminal.**

Search HiAnime · Browse episodes · Play · Download

[![CI](https://github.com/Kaztral-ar/ani-watch/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Kaztral-ar/ani-watch/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

</div>

---

## Features

- Search anime and browse episode/server listings on HiAnime
- Interactive anime, episode and server selection with `fzf`
- Play supported media with MPV or VLC
- Download supported media and accessible HLS playlists
- Choose quality: `best`, `worst`, `360p`, `480p`, `720p`, or `1080p`
- Select Japanese-audio (`sub`) or English-audio (`dub`) preference
- Watch history, continue watching, and Syncplay support
- Optional MPV intro/outro skipping with `ani-skip`

## Installation

### 1. Install dependencies

**Android (Termux)**

```sh
pkg update
pkg install git make curl jq fzf yt-dlp mpv
```

**Ubuntu / Debian**

```sh
sudo apt update
sudo apt install git make curl jq fzf yt-dlp mpv
```

**macOS (Homebrew)**

```sh
brew install git make curl jq fzf yt-dlp mpv
```

VLC can be used instead of MPV. Install `ffmpeg` for HLS fallback/remux and subtitle embedding. `syncplay` and `ani-skip` are optional.

### 2. Install AniWatch

```sh
git clone https://github.com/Kaztral-ar/ani-watch.git
cd ani-watch
make install PREFIX="$HOME/.local"
```

Make sure `$HOME/.local/bin` is in your `PATH`. Then run:

```sh
aniwatch
```

To install system-wide instead:

```sh
sudo make install
```

To uninstall:

```sh
make uninstall PREFIX="$HOME/.local"
```

### Run without installing

```sh
git clone https://github.com/Kaztral-ar/ani-watch.git
cd ani-watch
./bin/aniwatch
```

## Usage

### Interactive mode

Start AniWatch and follow the prompts to search for an anime, select an episode, and choose a listed server:

```sh
aniwatch
```

### Search and browse

```sh
# Search HiAnime
aniwatch search "Frieren"

# List episodes for an anime slug
aniwatch episodes <anime-slug>

# List available server entries for an episode ID
aniwatch servers <episode-id>
```

### Play and download

```sh
# Play a supported media URL
aniwatch watch "<media-url>" 1080p sub

# Download a supported media URL
aniwatch download "<media-url>" 720p dub

# Play an accessible HLS playlist
aniwatch hls "<playlist.m3u8>" 720p

# Download an accessible HLS playlist
aniwatch hls-download "<playlist.m3u8>" best

# Download episodes 1–12 when direct stream URLs are available
aniwatch bulk-download <anime-slug> 1-12 sub 720p
```

### History and watch together

```sh
aniwatch history
aniwatch continue
aniwatch history-clear
aniwatch syncplay "<media-url>"
```

### Metadata discovery

AniWatch also provides anime metadata through Jikan:

```sh
aniwatch metadata-search "Frieren"
aniwatch top
aniwatch random
aniwatch season 2026 fall
aniwatch info <mal-id>
```

### Help

```sh
aniwatch help
aniwatch version
```

## Configuration

Set environment variables before launching AniWatch.

| Variable | Default | Purpose |
|---|---|---|
| `ANIWATCH_PLAYER` | `mpv` | Playback program: `mpv` or `vlc` |
| `ANIWATCH_QUALITY` | `best` | Default playback/download quality |
| `ANIWATCH_MODE` | `sub` | Audio preference: `sub` or `dub` |
| `ANIWATCH_SKIP_INTRO` | `0` | Set to `1` to enable MPV Ani-Skip integration |
| `ANIWATCH_DOWNLOAD_DIR` | `.` | Download destination |
| `ANIWATCH_STATE_DIR` | `~/.local/state/aniwatch` | History and state directory |
| `ANIWATCH_HIANIME_BASE` | `https://hianime.at` | HiAnime base URL |
| `ANIWATCH_API_URL` | `https://api.jikan.moe/v4` | Jikan API base URL |

Examples:

```sh
ANIWATCH_PLAYER=vlc aniwatch
ANIWATCH_QUALITY=720p ANIWATCH_MODE=dub aniwatch
ANIWATCH_SKIP_INTRO=1 aniwatch
ANIWATCH_DOWNLOAD_DIR="$HOME/Videos/Anime" aniwatch
```

## Notes and limitations

- Playback requires a direct media URL or an HLS playlist that the installed player or `yt-dlp` can access.
- A server appearing in the HiAnime listing does not guarantee that it exposes a playable URL.
- Opaque embed IDs and protected/obfuscated stream sources are not resolved. AniWatch does not bypass DRM or access controls.
- HiAnime is an unofficial provider integration; its website structure and endpoints may change without notice.
- Use the service and media sources in accordance with applicable laws and provider terms.

## Development

Run the regression tests and build the standalone executable:

```sh
make test
make build
```

The CI workflow checks POSIX shell syntax, ShellCheck, tests under `sh`, `dash`, and BusyBox `ash`, and the standalone build.

---

<div align="center">

MIT License · [Report an issue](https://github.com/Kaztral-ar/ani-watch/issues) · [Source](https://github.com/Kaztral-ar/ani-watch)

</div>
