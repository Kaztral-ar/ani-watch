<!-- AniWatch README -->

<div align="center">

  <img src="https://img.shields.io/badge/✦-ANIWATCH-8b5cf6?style=for-the-badge&labelColor=111827" alt="AniWatch" />

  <h1>AniWatch</h1>

  <p><strong>Your anime corner, right in the terminal.</strong></p>
  <p>Discover anime on HiAnime · Explore episodes · Watch · Download</p>

  <p>
    <a href="https://github.com/Kaztral-ar/ani-watch/actions/workflows/ci.yml">
      <img src="https://github.com/Kaztral-ar/ani-watch/actions/workflows/ci.yml/badge.svg?branch=main" alt="Build status" />
    </a>
    <a href="LICENSE">
      <img src="https://img.shields.io/badge/license-MIT-8b5cf6.svg" alt="MIT License" />
    </a>
    <img src="https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Termux-64748b.svg" alt="Supported platforms" />
  </p>

  <p>
    <a href="#-features">Features</a> ·
    <a href="#-installation">Installation</a> ·
    <a href="#-quick-start">Quick start</a> ·
    <a href="#-commands">Commands</a> ·
    <a href="#-configuration">Configuration</a>
  </p>

</div>

---

## ✦ Features

| | Feature | What it does |
|:--:|---|---|
| 🔎 | **HiAnime search** | Find anime directly through HiAnime |
| 📺 | **Episode browsing** | Browse episodes and inspect available server listings |
| ▶️ | **Playback** | Open supported media streams with MPV or VLC |
| ⬇️ | **Downloads** | Download supported media and episode ranges |
| 🎞️ | **HLS support** | Select available stream quality and play or download accessible playlists |
| 📚 | **Watch history** | Review your history and continue from a saved entry |
| 🤝 | **Watch together** | Launch supported streams through Syncplay |
| ✨ | **Optional extras** | MPV intro/outro skip integration through ani-skip |

---

## ⚡ Quick start

Clone the project and launch AniWatch:

```sh
git clone https://github.com/Kaztral-ar/ani-watch.git
cd ani-watch
./bin/aniwatch
```

Open the interactive interface and search for your anime on HiAnime.

### Install as a system command (optional)

The install target builds a self-contained executable before installing it:

```sh
make install PREFIX="$HOME/.local"
```

Ensure `$HOME/.local/bin` is on your `PATH`. To uninstall:

```sh
make uninstall PREFIX="$HOME/.local"
```

---

## 📦 Installation

Install the required tools for your platform, then clone the repository using the quick-start steps above.

<details>
<summary><strong>Android · Termux</strong></summary>

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

**Player:** MPV is used by default. VLC is supported as an alternative.

**Optional tools:** `ffmpeg`, `syncplay`, and `ani-skip` are only needed for their respective optional features.

---

## 🎬 Quick start

### Search and browse on HiAnime

```sh
# Search for an anime
./bin/aniwatch search "Frieren"

# Browse episodes for a result
./bin/aniwatch episodes <anime-slug>

# Inspect available servers for an episode
./bin/aniwatch servers <episode-id>
```

---

## ⌨️ Commands

<details open>
<summary><strong>Playback and downloads</strong></summary>

```sh
# Play a supported media URL
./bin/aniwatch watch "<media-url>" 1080p sub

# Download a supported media URL
./bin/aniwatch download "<media-url>" 720p dub

# Play an accessible HLS playlist
./bin/aniwatch hls "<playlist.m3u8>" 720p

# Download an accessible HLS playlist
./bin/aniwatch hls-download "<playlist.m3u8>" best

# Download an episode range when direct stream URLs are available
./bin/aniwatch bulk-download <anime-slug> 1-12 sub 720p
```

</details>

<details>
<summary><strong>History and Syncplay</strong></summary>

```sh
# View watch history
./bin/aniwatch history

# Continue from saved history
./bin/aniwatch continue

# Clear watch history
./bin/aniwatch history-clear

# Start a synchronized session
./bin/aniwatch syncplay "<media-url>"
```

</details>

<details>
<summary><strong>Help</strong></summary>

```sh
./bin/aniwatch help
```

</details>

---

## ⚙️ Configuration

### Use VLC

Switch from the default MPV player:

```sh
ANIWATCH_PLAYER=vlc ./bin/aniwatch
```

### Enable intro/outro skip

If `ani-skip` is installed, enable its integration for MPV:

```sh
ANIWATCH_SKIP_INTRO=1 ./bin/aniwatch
```

---

## ℹ️ Important notes

- AniWatch uses **HiAnime** for anime search, episode browsing, and server listings.
- Playback supports **direct media URLs** and **accessible HLS playlists**.
- A server shown in a listing is not guaranteed to provide a directly playable stream.
- Opaque embed identifiers that require protected or obfuscated resolution are not decoded.
- Provider endpoints and website structures can change, which may temporarily affect search or server listings.
- AniWatch does not bypass DRM or other access controls.

---

<div align="center">

  **Enjoy your next episode. 🍿**

  If AniWatch is useful, consider giving the project a ⭐

  <a href="https://github.com/Kaztral-ar/ani-watch">GitHub Repository</a>
  ·
  <a href="https://github.com/Kaztral-ar/ani-watch/issues">Report a bug</a>
  ·
  <a href="LICENSE">MIT License</a>

</div>
