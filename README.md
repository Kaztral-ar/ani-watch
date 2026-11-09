# AniWatch

AniWatch is a modular POSIX-shell anime discovery CLI. It brings a lightweight terminal workflow to Jikan/MyAnimeList metadata, with interactive selection through **fzf** and optional playback of direct media URLs through a local player.

> **Scope:** Jikan provides anime metadata, not episode streams. AniWatch does not currently scrape streaming providers, resolve episodes, or generate playback URLs. The `play` command accepts a direct media URL supplied by the user.

## Features

- Search anime titles and display scores, episode counts, and types.
- Interactive search and title selection with fzf.
- Browse popular anime and the current seasonal catalogue.
- Browse a specific season by year and season name.
- Discover a random anime and inspect full details, genres, and synopsis.
- Play a direct HTTP(S) media URL with mpv or VLC.
- Modular source, standalone build, and offline smoke tests.

## Requirements

- POSIX-compatible shell
- `curl` and `jq` for metadata commands
- `fzf` for interactive mode
- `mpv` or VLC for direct URL playback

## Install

```sh
git clone https://github.com/Kaztral-ar/ani-watch.git
cd ani-watch
sudo make install
```

Run from the checkout without installing:

```sh
sh bin/aniwatch help
```

## Usage

```sh
# Interactive title search and selection (requires fzf)
aniwatch

# Search and list matching titles
aniwatch search "Frieren"

# Browse popular and currently airing-season catalogues
aniwatch top
aniwatch season

# Browse a specific season
aniwatch season 2025 fall

# Random title and full metadata
aniwatch random
aniwatch info 52991

# Play a direct media URL
aniwatch play "https://example.com/video.mp4"
```

Supported season names: `winter`, `spring`, `summer`, `autumn`.

## Configuration

| Variable | Default | Purpose |
|---|---|---|
| `ANIWATCH_API_URL` | `https://api.jikan.moe/v4` | Metadata API base URL |
| `ANIWATCH_LIMIT` | `10` | Number of search/season results |
| `ANIWATCH_PLAYER` | `mpv` | Preferred direct-URL player |

Example:

```sh
ANIWATCH_LIMIT=20 aniwatch search "One Piece"
```

## Development

```sh
make test
make build
sh dist/aniwatch help
```

Source modules live in `lib/aniwatch/`. The standalone build is generated at `dist/aniwatch`.

## Comparison with upstream ani-cli

AniWatch takes inspiration from the terminal-first workflow of [pystardust/ani-cli](https://github.com/pystardust/ani-cli), but it is a separate implementation and does not copy its GPL-3.0 source.

| Capability | upstream ani-cli | AniWatch |
|---|---|---|
| Interactive terminal selection | fzf, rofi, dmenu | fzf |
| Search and catalogue browsing | Provider-backed scraping | Jikan metadata API |
| Episode resolution and streaming | Yes, provider dependent | Not implemented |
| Sub/dub selection and quality | Yes | Not implemented |
| Download and batch episodes | Yes | Not implemented |
| Watch history / continue | Yes | Not implemented |
| Syncplay / intro skip | Supported integrations | Not implemented |
| Popular and seasonal discovery | Search/provider flow | Jikan top/current/specific season |
| Modular shell source and build | Single main script | Split modules + standalone build |

The upstream project has a broader playback feature set, including episode selection, quality selection, downloads, history, Syncplay, and intro skipping. AniWatch currently focuses on metadata discovery and a maintainable modular base. These playback features require a compatible streaming provider and are not falsely exposed as working commands here.

## Project layout

```text
bin/aniwatch              CLI entry point
lib/aniwatch/             Application modules
scripts/build.sh          Standalone build script
tests/run.sh              Offline smoke tests
.github/workflows/ci.yml  CI checks
Makefile                  Development and install targets
LICENSE                   MIT license
```

## License

MIT. See [LICENSE](LICENSE).
