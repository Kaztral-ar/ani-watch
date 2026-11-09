# ani-watch (modular layout)

A restructured [ani-cli](https://github.com/Kaztral-ar/ani-watch) v5.1.7: same behaviour, split into small
modules with consistent names, tests, and a single-file build. GPL-3.0-or-later (see `LICENSE`).

## Use

```sh
make build              # -> dist/ani-cli (one portable POSIX sh file)
sudo make install       # PREFIX=/usr/local by default
sh bin/ani-cli          # run straight from the checkout, no build needed
make test               # unit + end-to-end tests under sh, dash, bash (offline, mocked HTTP)
make lint               # shellcheck
```

Requires `curl`, `sed`, `grep`, `awk`, `fzf` (or rofi/dmenu) and `mpv` or VLC. Optional: `yt-dlp`/`ffmpeg`
(downloads), `ani-skip`, `syncplay`. Run `ani-cli -h` for options. All `ANI_CLI_*` environment variables from
upstream are unchanged.

## Layout

```
bin/ani-cli               dev entry point: sources lib/ani-cli/*.sh then runs main
dist/ani-cli              generated single-file build (what you install)
lib/ani-cli/MODULES       load order; the only list of modules (used by bin/ and scripts/build.sh)
  core.sh                 die/info/warn, require_cmd, first_available, TAB/NL
  config.sh               defaults + ANI_CLI_* env, platform detection, curl/player selection
  util.sh                 is_uint, url_encode, normalize_title
  http.sh                 http_fetch (the only place that calls curl for scraping)
  decode.sh               b64_decode, decode_embed_blob (XOR)
  provider_hianime.sh     provider_search / provider_episodes / provider_resolve_stream  <- site-specific
  quality.sh              select_quality, resolve_video_link
  episodes.sh             episode_next/prev/range/exists, resolve_episode_selection
  history.sh              history_* (init, migrate, save, pending list)
  ui.sh                   menu, select_from_list, number_lines
  player.sh               play_episode, play_selection, one player_* function per player, download_episode
  schedule.sh             next-episode countdown (-N)
  update.sh               self_update (-U, bundled build only)
  cli.sh                  cli_parse_args, cli_usage
  main.sh                 main + the load_*/playback_loop flow
scripts/build.sh          bundles the modules
tests/                    harness, mock curl/menu/player/ffmpeg, fixtures generator, unit + e2e tests
```

## Naming (old -> new)

| upstream | here |
|---|---|
| `hianime_curl` | `http_fetch` |
| `hianime_search` / `hianime_episodes` / `hianime_m3u8` | `provider_search` / `provider_episodes` / `provider_resolve_stream` |
| `deobfuscate_blob` | `decode_embed_blob` |
| `get_video_link` | `resolve_video_link` |
| `nth` | `select_from_list` |
| `dep_ch` / `dep_ch_failover` | `require_cmd` / `first_available` |
| `play` / `play_episode` | `play_selection` / `play_episode` |
| `update_history` / `backup_old_hist` / `process_hist_entry` | `history_save` / `history_migrate` / `history_next_entry` |
| `time_until_next_ep` / `update_script` | `show_next_episode_schedule` / `self_update` |
| globals `ep_no`, `links`, `refr` ... | `EP_NO`, `STREAM_LINKS`, `REFERER` ... (UPPER_SNAKE) |

## Supporting another site

Replace the three `provider_*` functions in `provider_hianime.sh` (contracts are in the file header); everything
else (menus, history, players, download) is site-independent. Add the fixtures to `tests/make_fixtures.py`.

## Changes from upstream behaviour

- Search terms are percent-encoded (`&`, `#`, `%`, non-ASCII no longer break the URL).
- Episode, history and menu lookups use exact string comparison (awk) instead of regexes built from user
  data: `1.5`, `15` and `1x5` can no longer be confused, and titles with `& | \` are stored safely.
- `-h`, `-V` and `-D` work without a player or curl installed; first action flag wins.
- `download` honours multiple `ANI_CLI_PLAYER_FLAGS`; EOF at the search prompt exits instead of looping.
- `-U` only operates on the bundled build and takes its source from `ANI_CLI_UPDATE_URL` (default: upstream).
- Next-episode countdown uses `curl --data-urlencode`.

## Known limits

The live site is the fragile part: the regexes in `provider_hianime.sh` and the XOR key in `decode.sh` are copied
verbatim from upstream and were verified only against synthetic fixtures that follow the same markup, not the
live site. If it changes, fix those two files.
