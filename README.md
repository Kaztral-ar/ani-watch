<div align="center">

# AniWatch

### Anime discovery. Episode browsing. Terminal playback.

A lightweight, modular anime CLI for **POSIX-compatible shells**.

[![CI](https://github.com/Kaztral-ar/ani-watch/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Kaztral-ar/ani-watch/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/Kaztral-ar/ani-watch?style=flat-square)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-POSIX%20sh-89e051?style=flat-square)](#)
[![Platform](https://img.shields.io/badge/platform-Termux%20%7C%20Linux%20%7C%20macOS-informational?style=flat-square)](#)

**Search** · **Browse** · **Watch** · **Download**

[Getting Started](#-getting-started) · [Commands](#-command-reference) · [Configuration](#-configuration) · [Limitations](#-important-notes)

</div>

---

## ✨ What is AniWatch?

AniWatch brings anime discovery and supported media playback into your terminal. Search titles through HiAnime, explore episode and server listings, discover anime metadata through Jikan, and play or download media URLs that your local tools can access.

It is designed to stay small, scriptable, and friendly to Termux, Linux, and macOS.

## 🚀 Features

| Area | Capabilities |
|---|---|
| Discovery | HiAnime title search, episode listings, server labels |
| Metadata | Jikan search, popular titles, random anime, seasonal listings, anime details |
| Interactive UI | Guided selection with `fzf`, episode navigation |
| Playback | MPV or VLC for supported direct media URLs |
| Downloads | `yt-dlp` downloads and accessible HLS playlists |
| Quality | `best`, `worst`, `360p`, `480p`, `720p`, `1080p` |
| Audio preference | Japanese (`sub`) or English (`dub`) preference where available |
| Watch history | History list, continue last URL, clear history |
| Extras | Syncplay and optional MPV Ani-Skip integration |

## 📦 Getting started

### 1. Install dependencies

Choose the command for your environment.

<details>
<summary><strong>Android · Termux</strong></summary>

```sh
pkg update
pkg install git make curl jq fzf yt-dlp mpv
```

</details>

<details>
<summary><strong>Ubuntu · Debian</strong></summary>

```sh
sudo apt update
sudo apt install git make curl jq fzf yt-dlp mpv
```

</details>

<details>
<summary><strong>macOS · Homebrew</strong></summary>

```sh
brew install git make curl jq fzf yt-dlp mpv
```

</details>

**Optional tools**

- `ffmpeg` — HLS fallback/remux and subtitle embedding.
- `vlc` — alternative media player.
- `syncplay` — synchronized viewing.
- `ani-skip` — intro/outro skipping with MPV.

### 2. Install AniWatch

```sh
git clone https://github.com/Kaztral-ar/ani-watch.git
cd ani-watch
make install PREFIX="$HOME/.local"
```

Ensure `$HOME/.local/bin` is included in your `PATH`, then launch:

```sh
aniwatch
```

For a system-wide installation, use `sudo make install` (default prefix: `/usr/local`).

<details>
<summary><strong>Run directly without installing</strong></summary>

```sh
git clone https://github.com/Kaztral-ar/ani-watch.git
cd ani-watch
./bin/aniwatch
```

</details>

<details>
<summary><strong>Uninstall</strong></summary>

Use the same prefix that you used during installation:

```sh
make uninstall PREFIX="$HOME/.local"
```

</details>

## ⌨️ Command reference

Run `aniwatch help` at any time for the built-in help.

### Discovery

```sh
# Open interactive mode
aniwatch

# Search HiAnime
aniwatch search "Frieren"

# List episodes and server labels
aniwatch episodes <anime-id-or-slug>
aniwatch servers <episode-id>

# Discover anime metadata through Jikan
aniwatch metadata-search "Frieren"
aniwatch top
aniwatch random
aniwatch season
aniwatch season 2026 fall
aniwatch info <mal-id>
```

### Playback and downloads

```sh
# Play a supported media URL
aniwatch watch "<media-url>" 1080p sub

# Download a supported media URL
aniwatch download "<media-url>" 720p dub

# Play or download an accessible HLS playlist
aniwatch hls "<playlist.m3u8>" 720p
aniwatch hls-download "<playlist.m3u8>" best

# Download a numbered episode range
aniwatch bulk-download <anime-slug> 1-12 sub 720p
```

Quality and audio preference are optional where noted by the command help. A server listing is not itself a playable stream: playback requires a direct URL accessible to MPV, VLC, or `yt-dlp`.

### History and synchronized viewing

```sh
aniwatch history
aniwatch continue
aniwatch history-clear
aniwatch syncplay "<media-url>"
```

## ⚙️ Configuration

Set environment variables before launching AniWatch. Values shown are the defaults.

| Variable | Default | Description |
|---|---|---|
| `ANIWATCH_PLAYER` | `mpv` | Player: `mpv` or `vlc` |
| `ANIWATCH_QUALITY` | `best` | Default quality preference |
| `ANIWATCH_MODE` | `sub` | Audio preference: `sub` or `dub` |
| `ANIWATCH_SKIP_INTRO` | `0` | Set to `1` to enable Ani-Skip with MPV |
| `ANIWATCH_DOWNLOAD_DIR` | `.` | Download destination |
| `ANIWATCH_STATE_DIR` | `~/.local/state/aniwatch` | Watch history and state |
| `ANIWATCH_HIANIME_BASE` | `https://hianime.at` | HiAnime base URL |
| `ANIWATCH_API_URL` | `https://api.jikan.moe/v4` | Jikan API base URL |
| `ANIWATCH_SYNCPLAY_SERVER` | `syncplay.pl:8995` | Syncplay server |

**Examples**

```sh
# Use VLC
ANIWATCH_PLAYER=vlc aniwatch

# Set default quality and audio preference
ANIWATCH_QUALITY=720p ANIWATCH_MODE=dub aniwatch

# Enable intro/outro skipping
ANIWATCH_SKIP_INTRO=1 aniwatch

# Save downloads to a dedicated folder
ANIWATCH_DOWNLOAD_DIR="$HOME/Videos/Anime" aniwatch
```

## 🧩 How it works

- **HiAnime** is used for title search, episode listings, and server labels.
- **Jikan** provides anime metadata and seasonal discovery.
- **fzf** powers interactive selection.
- **MPV / VLC** handle playback of supported media URLs.
- **yt-dlp / ffmpeg** handle supported downloads and HLS processing.

## ⚠️ Important notes

- Playback and downloads work only when a direct media URL or HLS playlist is accessible to the installed player or downloader.
- A server shown by the provider may expose only an opaque embed identifier, not a playable URL.
- AniWatch does **not** decrypt protected embeds, bypass DRM, defeat access controls, or circumvent provider protections.
- HiAnime is an unofficial provider integration. Its pages and endpoints may change or become unavailable without notice.
- Use the software and media sources responsibly and in accordance with applicable laws and provider terms.

## 🛠️ Development

Clone the repository and run the checks:

```sh
git clone https://github.com/Kaztral-ar/ani-watch.git
cd ani-watch

make test
make build
```

The CI workflow checks POSIX shell syntax, ShellCheck, regression tests under `sh`, `dash`, and BusyBox `ash`, and the standalone build.

## 🤝 Contributing

Bug reports and focused pull requests are welcome.

1. Check existing [issues](https://github.com/Kaztral-ar/ani-watch/issues).
2. Describe the problem or proposed change clearly.
3. Include reproduction steps or tests when possible.

## 📄 License

Released under the [MIT License](LICENSE).

<div align="center">

**[⬆ Back to top](#aniwatch)**

Made for the terminal.

</div>
