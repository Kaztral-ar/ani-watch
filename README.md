# AniWatch

A modular, POSIX shell-based command-line anime browser and player, based on the `ani-cli` v5.1.7 codebase. This repository keeps the original implementation, module layout, tests, build scripts, and licensing while presenting the project under the **AniWatch** name.

> **Compatibility note:** The command-line executable and its existing options retain the `ani-cli` name for compatibility with the source code. The GitHub project/repository is named **ani-watch**.

Licensed under **GPL-3.0-or-later**. See [LICENSE](LICENSE).

## Features

- Search and browse anime from the configured provider.
- Select episodes and stream them through supported media players.
- Choose video quality and resolve playback links.
- Maintain viewing history and continue from saved progress.
- Download episodes when the required tools are available.
- Display next-episode scheduling information.
- Build a portable, single-file shell script from the modular source.
- Run offline unit and end-to-end tests with mocked network/player commands.

## Requirements

Required tools:

- `curl`
- `sed`, `grep`, and `awk`
- `fzf` (or a supported menu alternative such as `rofi` or `dmenu`)
- `mpv` or VLC

Optional tools include `yt-dlp`, `ffmpeg`, `ani-skip`, and `syncplay`, depending on the features you use.

## Quick start

Run directly from the repository:

```sh
sh bin/ani-cli
```

Show available options:

```sh
sh bin/ani-cli -h
```

Build the standalone version:

```sh
make build
```

The generated executable is written to:

```
dist/ani-cli
```

Install system-wide (the default prefix is `/usr/local`):

```sh
sudo make install
```

## Development

Run the test suite:

```sh
make test
```

Run shell linting (requires ShellCheck):

```sh
make lint
```

The tests include unit and end-to-end coverage under `sh`, `dash`, and `bash`, using mocked HTTP, menu, player, and media-tool commands. The test suite is designed to run offline.

## Project structure

```text
ani-watch/
├── bin/
│   └── ani-cli                 # Development entry point
├── dist/
│   └── ani-cli                 # Generated standalone build
├── lib/
│   └── ani-cli/
│       ├── MODULES             # Central module load order
│       ├── core.sh             # Common helpers and command checks
│       ├── config.sh           # Defaults, environment and platform setup
│       ├── util.sh             # String and URL utilities
│       ├── http.sh             # HTTP fetching
│       ├── decode.sh           # Embed decoding helpers
│       ├── provider_hianime.sh # Provider-specific search and stream resolution
│       ├── quality.sh          # Quality selection and link resolution
│       ├── episodes.sh         # Episode selection and navigation
│       ├── history.sh          # Watch-history management
│       ├── ui.sh               # Menus and terminal selection
│       ├── player.sh           # Playback and download functions
│       ├── schedule.sh         # Next-episode countdown
│       ├── update.sh           # Self-update support for bundled builds
│       ├── cli.sh              # Argument parsing and help
│       └── main.sh             # Application entry point and main flow
├── scripts/
│   └── build.sh                # Creates the standalone build
├── tests/                      # Unit and end-to-end test suite
├── Makefile
└── LICENSE
```

## Configuration

Existing `ANI_CLI_*` environment variables are retained. The original command options and configuration names remain unchanged to avoid breaking existing scripts and user setups.

## Extending the provider

Provider-specific behaviour is isolated in `lib/ani-cli/provider_hianime.sh`. To adapt the project to another site, implement the provider search, episode-list, and stream-resolution functions while keeping their existing contracts. The rest of the application—menus, history, playback, and downloads—is designed to remain provider-independent.

## Notes and limitations

The provider integration depends on the remote site's page structure and embed decoding behaviour. Site changes may require updates to `provider_hianime.sh` and `decode.sh`. Validate provider changes against the live service as well as the synthetic fixtures in the test suite.

## Credits

This project is based on [pystardust/ani-cli](https://github.com/pystardust/ani-cli). Original upstream licensing and notices are retained in the repository.
