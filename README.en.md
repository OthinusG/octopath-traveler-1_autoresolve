<img src="https://raw.githubusercontent.com/OthinusG/octopath-traveler-1_autoresolve/main/docs/site/assets/octopath-logo.png" alt="Octopath Traveler" width="96" height="96">

# OT1 Auto Resolve

[简体中文](README.md)

Source release 0.1.3 for Octopath Traveler I, Windows Steam build 5272616 and official UE4SS 3.0.1.

Resolve eligible over-levelled ordinary walking encounters before combat and grant rewards through game APIs. Boss, story, fixed, duel and summon encounters remain excluded. F6 toggles the mod and persists its setting.

- Highest active-party level must meet both area danger and enemy levels plus the configured margin.
- Static equipped support and EXP/JP accessory bonuses follow OT1 additive rules and truncation.
- Knocked-out members receive no EXP/JP. Living max-level members still receive JP.
- Level-ups refill that member's HP/MP. Earned leaves update the native cumulative-money achievement record.
- Notifications follow the text language: Simplified/Traditional Chinese, English for everything else. Voice settings are independent.
- No combat-performance bonuses, stealing/capture rewards, rare-cat substitution, first-species tracking or battle-only over-limit cleanup.

![In-game screenshot: automatic encounter rewards in the English interface](https://raw.githubusercontent.com/OthinusG/octopath-traveler-1_autoresolve/main/docs/site/assets/gameplay-en.webp)

## Install

Install official [UE4SS 3.0.1](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/v3.0.1) separately. Copy `mod/OT1AutoResolve` into the game's `Octopath_Traveler/Binaries/Win64/Mods` folder. Add `OT1AutoResolve : 1` to the existing `Mods/mods.txt`; preserve other entries. Restart the game.

For upgrades replace only `OT1AutoResolve/Scripts`, preserving `config.ini`. Defaults: Enabled=1, LevelMargin=1, ToggleKey=F6, ShowUI=1. See [Chinese user guide](mod/README.md).

## Test and package

Requires Lua 5.4+ for local tests and Python 3.9+ for packaging; the game's Lua runtime is supplied by UE4SS.

```sh
lua tests/test_mod.lua "$PWD"
python3 tools/package_mod.py
```

The packager produces `dist/OT1AutoResolve-0.1.3-mod-only.zip` and its SHA256 file. This archive contains no loader binaries. The checked-in `catalog.lua` is sufficient for normal development and packaging; no extraction is required.

See [development notes](docs/DEVELOPMENT.md), [validation scope](docs/VALIDATION.md), and [notices](NOTICE.md). The upstream UE4SS MIT notice is retained under `LICENSES/UE4SS-MIT.txt`; no new license has been selected for the mod source.
