# AniWatch

<p align="center">
  <strong>A lightweight anime discovery and playback CLI</strong><br>
  Built with POSIX shell · Works on Linux, macOS and Termux
</p>

<p align="center">
  <a href="https://github.com/Kaztral-ar/ani-watch">GitHub</a> ·
  <a href="LICENSE">MIT License</a>
</p>

## Install

### 1. Install dependencies

**Termux (Android)**

```sh
pkg update
pkg install git curl jq fzf yt-dlp mpv
```

**Ubuntu / Debian**

```sh
sudo apt update
sudo apt install git curl jq fzf yt-dlp mpv
```

**macOS (Homebrew)**

```sh
brew install git curl jq fzf yt-dlp mpv
```

VLC can be used instead of MPV. Install `vlc` if you prefer it. `ffmpeg`, `syncplay` and `ani-skip` are optional.

### 2. Get AniWatch

```sh
git clone https://github.com/Kaztral-ar/ani-watch.git
cd ani-watch
```

### 3. Start

```sh
./bin/aniwatch
```

If execution permission is missing, run:

```sh
chmod +x bin/aniwatch
./bin/aniwatch
```

## How to use

Start the interactive interface:

```sh
./bin/aniwatch
```

Search for an anime:

```sh
./bin/aniwatch search "Frieren"
```

Use the anime slug shown in the search results to list episodes, then use an episode ID to view available servers:

```sh
./bin/aniwatch episodes <anime-slug>
./bin/aniwatch servers <episode-id>
```

Explore anime:

```sh
./bin/aniwatch metadata-search "Naruto"
./bin/aniwatch top
./bin/aniwatch random
./bin/aniwatch season
./bin/aniwatch info <mal-id>
```

Play or download a supported media URL:

```sh
./bin/aniwatch watch "<media-url>" 1080p sub
./bin/aniwatch download "<media-url>" 720p dub
```

Download an episode range when direct stream URLs are available:

```sh
./bin/aniwatch bulk-download <anime-slug> 1-12 sub 720p
```

Play or download an accessible HLS stream:

```sh
./bin/aniwatch hls "<playlist.m3u8>" 720p
./bin/aniwatch hls-download "<playlist.m3u8>" best
```

Watch together and manage history:

```sh
./bin/aniwatch syncplay "<media-url>"
./bin/aniwatch history
./bin/aniwatch continue
./bin/aniwatch history-clear
```

See all commands:

```sh
./bin/aniwatch help
```

## Optional settings

Choose VLC instead of the default MPV:

```sh
ANIWATCH_PLAYER=vlc ./bin/aniwatch
```

Enable opening/ending skip data with the separately installed `ani-skip` tool (MPV only):

```sh
ANIWATCH_SKIP_INTRO=1 ./bin/aniwatch
```

## What it uses

| Tool / service | Used for |
|---|---|
| POSIX shell | Main application |
| Jikan API | Anime information and discovery |
| HiAnime site endpoints | Anime search, episodes and server listings |
| curl + jq | HTTP requests and JSON processing |
| fzf | Interactive selection |
| yt-dlp | Media URL handling and downloads |
| MPV | Default video player |
| VLC | Optional alternative player |
| ffmpeg | Optional HLS download/remux fallback |
| Syncplay | Synchronized playback |
| ani-skip | Optional intro/outro skip data for MPV |

> **Stream note:** AniWatch can play and download direct media URLs and accessible HLS playlists. A server listing is not necessarily a playable stream: opaque server IDs that require protected or obfuscated embed resolution are not decoded. Provider endpoints may change. AniWatch does not bypass DRM or access controls.

---

<p align="center">Made for anime fans who love the terminal.</p>
