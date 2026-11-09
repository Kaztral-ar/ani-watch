# AniWatch

AniWatch is a modular POSIX shell CLI for discovering anime from your terminal. It supports title search, popular-anime listings, detailed metadata, and launching direct media URLs with a local player.

**Metadata provider:** [Jikan API](https://jikan.moe/) (MyAnimeList data). Jikan does not provide streaming links. AniWatch does not host or scrape video content.

## Features

- Search anime by title.
- Browse popular anime.
- View full anime metadata and synopsis.
- Launch a direct media URL with mpv or VLC.
- Modular shell source with a standalone build target.
- Smoke tests that run without network access.

## Requirements

- POSIX-compatible shell
- `curl` and `jq` for metadata commands
- `mpv` or VLC for direct URL playback

## Install

Clone the repository and install the command:

```sh
git clone https://github.com/Kaztral-ar/ani-watch.git
cd ani-watch
sudo make install
```

Or run it directly from the checkout:

```sh
sh bin/aniwatch help
```

## Usage

```sh
aniwatch search "Frieren"
aniwatch top
aniwatch info 52991
aniwatch play "https://example.com/video.mp4"
aniwatch
```

## Configuration

| Variable | Default | Purpose |
|---|---|---|
| `ANIWATCH_API_URL` | `https://api.jikan.moe/v4` | Metadata API base URL |
| `ANIWATCH_LIMIT` | `10` | Number of search/top results |
| `ANIWATCH_PLAYER` | `mpv` | Preferred direct-URL player |

Example:

```sh
ANIWATCH_LIMIT=15 aniwatch search "One Piece"
```

## Development

```sh
make test
make build
```

The modular source lives in `lib/aniwatch/`. The generated standalone command is written to `dist/aniwatch`.

## Project layout

```text
bin/aniwatch              CLI entry point
lib/aniwatch/             Application modules
scripts/build.sh          Standalone build script
tests/run.sh              Offline smoke tests
Makefile                  Development and install targets
LICENSE                   MIT license
```

## License

MIT. See [LICENSE](LICENSE).
