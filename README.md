# AniWatch

AniWatch is a modular POSIX-shell anime discovery and playback CLI. It combines Jikan/MyAnimeList metadata with **yt-dlp-compatible URL extraction**, MPV playback, local watch history, downloads and optional Syncplay sessions.

> **Provider boundary:** Jikan is metadata-only. To watch or download, provide a media page URL supported by your installed yt-dlp version and accessible to your account. AniWatch does not scrape around authentication, bypass DRM, or host content.

## Features

- Search, popular, random and seasonal anime discovery through Jikan.
- Interactive title selection with fzf.
- Play supported media URLs using MPV and yt-dlp.
- Prefer Japanese audio (`sub`) or English audio (`dub`) when the source exposes language metadata.
- Select best, worst, 360p, 480p, 720p or 1080p formats when available.
- Download supported media with subtitles when supplied by the source.
- Record watch history and resume the last URL.
- Join a Syncplay room to synchronize playback with friends.
- Modular POSIX shell source, standalone build and offline tests.

## Requirements

- POSIX-compatible shell
- `curl` and `jq` for metadata
- `fzf` for interactive search
- `yt-dlp` and `mpv` for playback and downloads
- `syncplay` for synchronized sessions

Install dependencies using your platform's package manager. On Termux, package availability varies by repository; install compatible builds of yt-dlp and MPV.

## Install

```sh
git clone https://github.com/Kaztral-ar/ani-watch.git
cd ani-watch
sudo make install
```

Run from checkout:

```sh
sh bin/aniwatch help
```

## Usage

```sh
# Metadata discovery
aniwatch search "Frieren"
aniwatch top
aniwatch random
aniwatch season
aniwatch season 2025 autumn
aniwatch info 52991

# Play a supported episode/page URL
aniwatch watch "https://example.com/watch/episode" 1080p sub
aniwatch watch "https://example.com/watch/episode" 720p dub

# Download with chosen quality and audio preference
aniwatch download "https://example.com/watch/episode" 1080p sub

# Watch together (all participants need access to the same stream)
aniwatch syncplay "https://example.com/video.mp4"

# History
aniwatch history
aniwatch continue
aniwatch history-clear
```

### Audio and quality behavior

- `sub` prefers Japanese audio; `dub` prefers English audio.
- The source must expose audio-language metadata for yt-dlp to select the intended track reliably.
- Subtitle tracks are selected in MPV using English as the default preference. Downloads embed English subtitles when the source provides them.
- Quality is a maximum-height preference; if the requested resolution is unavailable, yt-dlp may choose a lower available format.
- MPV is used because it can hand supported sites to yt-dlp and consume the selected format. VLC is not currently the integrated yt-dlp playback backend.

### Watch history

History is stored locally at:

```text
$XDG_STATE_HOME/aniwatch/history.tsv
```

If `XDG_STATE_HOME` is unset, AniWatch uses `~/.local/state/aniwatch/`. Override the location with `ANIWATCH_STATE_DIR`. History contains timestamps, titles/URLs and media URLs; it is not uploaded.

### Syncplay

Syncplay synchronizes player state, not video files or provider access. Every participant must have access to a compatible stream and use a compatible player. Set a private or public server with `ANIWATCH_SYNCPLAY_SERVER`; the default is `syncplay.pl:8995`.

## Configuration

| Variable | Default | Purpose |
|---|---|---|
| `ANIWATCH_API_URL` | `https://api.jikan.moe/v4` | Metadata API |
| `ANIWATCH_LIMIT` | `10` | Search/season result count |
| `ANIWATCH_QUALITY` | `best` | Default playback/download quality |
| `ANIWATCH_MODE` | `sub` | Default audio preference |
| `ANIWATCH_DOWNLOAD_DIR` | `.` | Download destination |
| `ANIWATCH_STATE_DIR` | `~/.local/state/aniwatch` | Local state directory |
| `ANIWATCH_SYNCPLAY_SERVER` | `syncplay.pl:8995` | Syncplay server |

## Development

```sh
make test
make build
sh dist/aniwatch help
```

Source modules live in `lib/aniwatch/`; the standalone build is generated at `dist/aniwatch`.

## Comparison with upstream ani-cli

AniWatch is a separate implementation inspired by the terminal workflow of [pystardust/ani-cli](https://github.com/pystardust/ani-cli). It does not copy upstream source code.

| Capability | upstream ani-cli | AniWatch |
|---|---|---|
| Anime search and selection | Provider scraping + fzf/rofi/dmenu | Jikan + fzf |
| Episode streaming | Provider-specific resolver | yt-dlp-supported URLs |
| Sub/dub | Provider-specific | Audio-language preference when exposed |
| Quality selection | Yes | yt-dlp format selection |
| Downloads | Yes | yt-dlp |
| Watch history | Yes | Local URL history + continue |
| Syncplay | Yes | Syncplay client integration |
| Intro skip / release countdown | Yes | Not implemented |

## License

MIT. See [LICENSE](LICENSE).
