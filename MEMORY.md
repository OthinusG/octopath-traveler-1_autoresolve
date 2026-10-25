# Project Memory

- Project: OT1 Auto Resolve; version 0.1.3. Windows Steam build 5272616 and official UE4SS 3.0.1 are the verified target.
- The repository was repurposed from a UE4SS fork. Upstream commit history remains; the original upstream MIT notice is retained under LICENSES. The mod has no newly selected license.
- Only UpdatePlayerStep is hooked. Require actual movement, decreasing expired steps, ordinary mode, native battle/event guards and source-derived safe groups before rewarding.
- Reset the encounter interval to a positive value before original IsEncount executes. BattleStartWipe can remain true during normal exploration and is not a safe transition guard.
- Use highest active-party level for threshold checks. Current HP determines recipient eligibility; knocked-out active members provide static equipped bonuses but receive no EXP/JP/healing. Living max-level members retain JP.
- Static support IDs 0/32/41 and source-derived EXPUP/JPUP equipment contributions follow native additive rules and truncation. GetBattleParamToFloat needs all four output-table arguments. Runtime output names are enable/param; the code also accepts Blueprint/SDK capitalization.
- Native AddCharacterExp does not refill HP/MP. Only a true LevelUp output triggers native per-character recovery. Earned leaves notify the native cumulative-money achievement interface once.
- Skipped battles must not simulate combat-only over-limit cleanup, combat-performance bonuses, steal/capture actions or first-species discovery.
- Earlier native-parameter diagnostic tracing caused object-conversion crashes; it is removed and must not be restored.
- 49 portable Lua tests and native getter/cold-start checks passed. Full 0.1.3 boosted/knocked-out gameplay and achievement unlock remain untested; see docs/VALIDATION.md.
