# AniWatch

AniWatch is a modular POSIX-shell anime discovery and playback CLI. It combines Jikan/MyAnimeList metadata, a HiAnime catalog adapter for title/episode/server listings, yt-dlp-compatible URL playback, MPV, local watch history and optional Syncplay.

> **Provider boundary:** Jikan supplies anime metadata. The HiAnime adapter queries the site's search page and episode/server endpoints. These are unofficial website endpoints and may change or reject automated requests. Server listings are not direct video URLs. Playback still requires a media URL supported by yt-dlp and accessible to your account. AniWatch does not bypass DRM or access controls.

## Features

- Search anime metadata through Jikan.
- Search HiAnime titles and list episodes and server labels.
- Browse popular, random and seasonal anime through Jikan.
- Play supported media URLs using MPV and yt-dlp.
- Inspect accessible HLS master playlists, select best/worst or capped resolution, and pass a required HTTP Referer to MPV/yt-dlp.
- Prefer Japanese audio (`sub`) or English audio (`dub`) when the source exposes language metadata.
- Select best, worst, 360p, 480p, 720p or 1080p formats when available.
- Download supported media with subtitles when supplied by the source.
- Record episode-aware watch history (anime slug and episode number) and resume the last URL; older history files remain readable.
- Join a Syncplay room to synchronize playback with friends.
- Modular POSIX shell source, standalone build and offline tests.

## Requirements

- POSIX-compatible shell
- `curl` and `jq`
- `fzf` for interactive HiAnime title selection
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
# HiAnime catalog
aniwatch search "Frieren"
aniwatch episodes "slug-from-search-results" # use the exact slug printed by search
aniwatch servers 123456                 # use an episode ID from episodes

# Jikan metadata
aniwatch metadata-search "Frieren"
aniwatch top
aniwatch random
aniwatch season
aniwatch season 2025 autumn
aniwatch info 52991

# Play a supported media/page URL
aniwatch watch "https://example.com/watch/episode" 1080p sub
aniwatch watch "https://example.com/watch/episode" 720p dub
aniwatch download "https://example.com/watch/episode" 1080p sub

# Play an accessible HLS master playlist, optionally with a provider Referer
aniwatch hls "https://cdn.example.com/master.m3u8" 720p "https://provider.example/" "Anime Episode 1"

# Download an accessible HLS playlist
aniwatch hls-download "https://cdn.example.com/master.m3u8" best "https://provider.example/"

# Watch together
aniwatch syncplay "https://example.com/video.mp4"

# History
aniwatch history
aniwatch continue
aniwatch history-clear
```

The HLS resolver supports accessible master playlists and relative variant URLs. It does not resolve HiAnime server IDs into protected or obfuscated embed streams. The HiAnime search command prints a slug and title. Pass that slug to `episodes`; pass an episode ID from that output to `servers`. The server command displays the available server labels and type only. It does not resolve embedded players into direct stream URLs.

### Audio and quality behavior

- `sub` prefers Japanese audio; `dub` prefers English audio.
- The source must expose audio-language metadata for yt-dlp to select the intended track reliably.
- Subtitle tracks are selected in MPV using English as the default preference. Downloads embed English subtitles when the source provides them.
- Quality is a maximum-height preference; if the requested resolution is unavailable, yt-dlp may choose a lower available format.

### Watch history

History is stored locally at `$XDG_STATE_HOME/aniwatch/history.tsv`. If `XDG_STATE_HOME` is unset, AniWatch uses `~/.local/state/aniwatch/`. New entries include anime ID and episode number; legacy three-column entries remain readable. Override the location with `ANIWATCH_STATE_DIR`. History is not uploaded.

## Configuration

| Variable | Default | Purpose |
|---|---|---|
| `ANIWATCH_API_URL` | `https://api.jikan.moe/v4` | Jikan metadata API |
| `ANIWATCH_HIANIME_BASE` | `https://hianime.at` | HiAnime site base |
| `ANIWATCH_LIMIT` | `10` | Jikan result count |
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

Source modules live in `lib/aniwatch/`; the standalone build is generated by `scripts/build.sh`.

## Comparison with upstream ani-cli

AniWatch is an independent implementation inspired by the terminal workflow of [pystardust/ani-cli](https://github.com/pystardust/ani-cli). It does not copy upstream source code.

| Capability | upstream ani-cli | AniWatch |
|---|---|---|
| Anime search | HiAnime HTML search | HiAnime HTML search + Jikan |
| Episode list | HiAnime episode endpoint | HiAnime episode endpoint |
| Server list | HiAnime server endpoint + provider resolver | HiAnime server labels only |
| Direct stream resolution | Provider-specific embed resolver | Generic accessible HLS manifest resolver; no provider embed decryption |
| Sub/dub | Provider server selection | Audio-language preference for supplied URLs; provider selection pending |
| Quality | Provider/HLS selection | HLS variant selection + yt-dlp format selection |
| Downloads | yt-dlp / ffmpeg fallback | yt-dlp for supported URLs and HLS variants |
| Watch history | Episode-aware | Episode-aware for interactive direct-stream playback; legacy URL history supported |
| Syncplay | Yes | Syncplay client integration |

## License

MIT. See [LICENSE](LICENSE).
