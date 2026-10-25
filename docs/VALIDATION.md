# Validation

Target: Windows Steam build 5272616; official UE4SS 3.0.1.

## 0.1.3

49 focused Lua tests passed. Cases include encounter protection, thresholds, repeated/reentrant callbacks, inventory capacity, UI-language fallback, F6 persistence, level-up healing, additive static support/equipment bonuses, duplicate support suppression, knocked-out recipients/providers, max-level JP, achievement callback count and preflight failures.

Native getter checks passed for support states, all 11 equipment slots, reward parameter outputs (money 1.1, EXP/JP 1.5) and achievement-interface availability. Cold startup passed after removing temporary probes. Installed script hashes matched release source. These getter checks issued no rewards or save writes.

Original Blueprint/data audits verified settlement eligibility, static bonus stacking/truncation, earned-money achievement handling and ordinary-group isolation. The catalogue contains 377 ordinary enemies and 1735 ordinary groups.

Full 0.1.3 boosted/knocked-out gameplay comparisons and an actual cumulative-money achievement unlock have not been tested. Ordinary damaged-character level-up recovery also remains to be checked in game.

## Earlier core acceptance

Eleven actual ordinary encounters resolved successfully, including an unshortened interval and an exact level-margin boundary. Below-threshold encounters entered normal combat without duplicate rewards. EXP/JP/money/item deltas, native level-ups, derived stats, notifications and F6 persistence were checked. This evidence predates the 0.1.3 bonus/eligibility changes and is not a claim of fresh acceptance for those changes.

Boss/story separation was source/mock audited; individual protected sequences were not exhaustively played. Battle-performance rewards, capture/steal outcomes, late rare-cat substitution and battle-only cleanup are outside this mod's simulation.
