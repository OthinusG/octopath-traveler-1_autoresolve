# Project Rules

## Scope
Maintain the Octopath Traveler I ordinary-encounter auto-resolve mod. Read README.md, MEMORY.md and docs/DEVELOPMENT.md before editing.

## Target and constraints
- Windows Steam build 5272616; official UE4SS 3.0.1.
- Hook only the verified UpdatePlayerStep path and preserve battle/event/movement/catalogue guards.
- Never affect boss, story, fixed, duel or summon battles. Unknown encounters remain normal combat.
- No direct save edits, native parameter tracing, combat-performance bonuses or battle-only over-limit cleanup.
- Keep UI text language independent of voice. Preserve user configuration on upgrades.
- Do not commit game assets, SDK/Blueprint dumps, saves, loader binaries or machine-specific data.

## Checks
Run `lua tests/test_mod.lua "$PWD"` and `python3 tools/package_mod.py`. Check changed Lua with luac. Tests and native source/getter checks are not equivalent to full in-game acceptance; report runtime limits accurately. Update MEMORY.md for durable project decisions, without secrets or personal host details.
