# AniWatch

<p align="center">
  <img src="https://img.shields.io/badge/AniWatch-Anime%20in%20your%20terminal-7c3aed?style=for-the-badge" alt="AniWatch" />
</p>

<p align="center">
  <strong>Discover anime. Browse episodes. Watch from your terminal.</strong>
  <br />
  A lightweight anime discovery and playback CLI built with POSIX shell.
</p>

<p align="center">
  <a href="https://github.com/Kaztral-ar/ani-watch/actions/workflows/ci.yml"><img src="https://github.com/Kaztral-ar/ani-watch/actions/workflows/ci.yml/badge.svg?branch=main" alt="CI" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-22c55e.svg" alt="MIT License" /></a>
  <img src="https://img.shields.io/badge/shell-POSIX-2563eb.svg" alt="POSIX shell" />
  <img src="https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Termux-64748b.svg" alt="Linux, macOS and Termux" />
</p>

---

## Install

### 1. Install dependencies

<details>
<summary><strong>Termux · Android</strong></summary>

```sh
pkg update
pkg install git curl jq fzf yt-dlp mpv
```
</details>

<details>
<summary><strong>Ubuntu / Debian</strong></summary>

```sh
sudo apt update
sudo apt install git curl jq fzf yt-dlp mpv
```
</details>

<details>
<summary><strong>macOS · Homebrew</strong></summary>

```sh
brew install git curl jq fzf yt-dlp mpv
```
</details>

MPV is the default player. VLC can be used as an alternative. `ffmpeg`, `syncplay`, and `ani-skip` are optional.

### 2. Clone the repository

```sh
git clone https://github.com/Kaztral-ar/ani-watch.git
cd ani-watch
```

### 3. Launch AniWatch

```sh
./bin/aniwatch
```

---

## Usage

### Interactive mode

Launch the interactive terminal interface:

```sh
./bin/aniwatch
```

### Find anime and episodes

```sh
# Search anime
./bin/aniwatch search "Frieren"

# Browse episodes and available servers
./bin/aniwatch episodes <anime-slug>
./bin/aniwatch servers <episode-id>
```

### Discover anime

```sh
./bin/aniwatch metadata-search "Naruto"
./bin/aniwatch top
./bin/aniwatch random
./bin/aniwatch season
./bin/aniwatch info <mal-id>
```

### Watch and download

Use a direct media URL or an accessible stream URL:

```sh
# Play
./bin/aniwatch watch "<media-url>" 1080p sub

# Download
./bin/aniwatch download "<media-url>" 720p dub

# Play an HLS playlist
./bin/aniwatch hls "<playlist.m3u8>" 720p

# Download an HLS playlist
./bin/aniwatch hls-download "<playlist.m3u8>" best
```

### Bulk download

Download an episode range when direct stream URLs are available:

```sh
./bin/aniwatch bulk-download <anime-slug> 1-12 sub 720p
```

### History and watch together

```sh
./bin/aniwatch history
./bin/aniwatch continue
./bin/aniwatch history-clear
./bin/aniwatch syncplay "<media-url>"
```

### Player and optional features

Use VLC instead of MPV:

```sh
ANIWATCH_PLAYER=vlc ./bin/aniwatch
```

Enable optional intro/outro skip data with the separately installed `ani-skip` tool (MPV only):

```sh
ANIWATCH_SKIP_INTRO=1 ./bin/aniwatch
```

See the complete command list:

```sh
./bin/aniwatch help
```

---

## Notes

- **Supported playback:** direct media URLs and accessible HLS playlists.
- **Provider limitation:** a listed server is not always a playable stream. Opaque embed IDs that require protected or obfuscated resolution are not decoded.
- **Availability:** provider endpoints and site structure can change over time.
- **Playback:** DRM and access controls are not bypassed.

<p align="center">
  <sub>Made for anime fans who love the terminal.</sub>
  <br />
  <a href="https://github.com/Kaztral-ar/ani-watch">Star the project on GitHub</a>
  ·
  <a href="https://github.com/Kaztral-ar/ani-watch/issues">Report an issue</a>
</p>
