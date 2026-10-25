# Development

## Layout

- `mod/OT1AutoResolve/Scripts/main.lua`: encounter guards, reward preparation, native writes, F6 and notifications.
- `catalog.lua`: checked-in ordinary-group/enemy values and verified reward-accessory bonuses.
- `messages.lua`: pure UI-language selection.
- `tests/test_mod.lua`: portable focused Lua fixtures; no game or loader required.
- `tools/package_mod.py`: standard-library mod-only ZIP packager.
- `tools/build_catalog.py`: optional local-data catalogue generator, not required for packaging.

## Constraints

Target only Windows Steam build 5272616 and official UE4SS 3.0.1. Hook only the verified ordinary-map UpdatePlayerStep path. Preserve all movement, battle/event and safe-group guards. Do not import OT2 identifiers or signatures. Do not write saves directly. Keep UI-language selection independent of voice. Native GetBattleParamToFloat needs all four output-table argument positions on UE4SS 3.0.1.

Do not add native-function parameter tracing: earlier development tracing caused an Unreal-to-Lua object-conversion crash and was removed. Getter calls are distinct from installing native hooks.

## Optional catalogue regeneration

The public build uses the committed catalogue. Regeneration additionally requires locally obtained assets from the exact game build and a compatible development reader; these prerequisites are intentionally not bundled.

Place `EnemyDB.uasset/.uexp`, `EnemyGroupData.uasset/.uexp` and `ItemDB.uasset/.uexp` under `evidence/assets/`. Supply the compatible `Data.py` table reader under `reference/ot1-randomizer/`. It must omit the unused hjson import and correctly skip SoftObjectProperty, StrProperty and FloatProperty tagged values for this PC build. The generator validates table footers, ordinary-enemy/group restrictions, item references and reward-accessory property tags.

```sh
python3 tools/build_catalog.py
lua tests/test_mod.lua "$PWD"
```

Raw source-data/Blueprint audits require private local game extraction and are not included as runnable public tests. Their findings are summarized in VALIDATION.md. Never commit local extraction, saves, remote access scripts or machine-specific notes.
