# Code Review Findings

## Executive Summary
Primary opportunities are in performance hot paths (group scans and per-frame allocations), merge artifacts in core autoloads, and missing headless E2E coverage. Modularization can reduce duplicated damage logic and improve testability.

## High Priority Findings
1) Merge artifacts and duplicate logic in core autoloads
- `autoloads/save_manager.gd` contains multiple conflicting implementations.
- `autoloads/game_manager.gd` contains duplicated blocks and merge separators.
- `autoloads/events.gd` includes duplicate signal blocks.
Action: normalize to a single authoritative implementation and remove separators.

2) Per-frame group scans in hot paths
- `get_nodes_in_group("enemies")` and `get_nodes_in_group("player")` called in multiple per-frame contexts.
Action: add a lightweight EntityRegistry autoload to cache group membership and reduce scanning.

3) Per-frame allocations in UI
- `ui/hud/coin_counter.gd` updates values per frame and triggers frequent label updates.
- `ui/hud/combo_counter.gd` creates ColorRect spark nodes on combo events; no pooling.
Action: reduce per-frame work and limit allocations to events.

4) E2E coverage is mostly interactive
- UITester exists but is not wired to a headless runner scene.
Action: add headless E2E scene and script, expand UITester scenarios to cover edge cases.

## Medium Priority Findings
- Damage flow logic appears in multiple enemy projectiles and states; introduce shared helpers.
- UI theme settings are repeated; use a shared HUD theme resource for consistency.

## Suggested Order of Fixes
1) Merge cleanup in autoloads
2) EntityRegistry for group lookups
3) Damage helpers
4) E2E runner and UITester expansion
5) UI perf and theme alignment
