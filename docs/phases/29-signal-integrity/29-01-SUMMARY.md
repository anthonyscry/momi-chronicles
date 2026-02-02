# Phase 29 Plan 01: Wire Signal Handlers Summary

> JWT auth with — no. **Three missing signal handlers wired: corrupt save warning on title screen, HUD refresh on load, buff clearing on restart.**

---
phase: 29
plan: 01
subsystem: signals
tags: [signals, save-system, hud, game-state, ui]
dependency-graph:
  requires: [14, 16, 28]
  provides: [save_corrupted handler, game_loaded HUD refresh, game_restarted buff clearing]
  affects: [29-02, 29-03]
tech-stack:
  added: []
  patterns: [signal-connect-in-ready, re-emit-for-hud-refresh, autoload-state-clearing]
key-files:
  created: []
  modified: [ui/menus/title_screen.gd, ui/hud/game_hud.gd, autoloads/game_manager.gd]
decisions:
  - id: D29-01-01
    choice: "Re-emit existing Events signals for HUD refresh rather than adding update methods to each HUD element"
    rationale: "All HUD elements already listen to Events signals — simplest approach with zero changes to child scripts"
  - id: D29-01-02
    choice: "Clear only Inventory.active_buffs in _clear_temporary_state(), not combo/poison/guard"
    rationale: "Combo, poison, guard are scene-tree nodes destroyed by reload_current_scene(). Only Inventory survives as autoload child."
  - id: D29-01-03
    choice: "Use ConfirmationDialog for corrupt save restore/fresh choice"
    rationale: "Matches existing title_screen pattern — ConfirmationDialog node already exists in scene tree"
metrics:
  duration: ~6 minutes
  completed: 2026-01-29
---

## What Was Done

### Task 1: Wire save_corrupted signal to title screen warning
Connected `Events.save_corrupted` in `_ready()` before any load can fire. When a corrupt save is detected during load, the title screen now:
- Shows a red warning label ("Save corrupted. Backup found — restore?")
- Checks for backup save file existence via `FileAccess.file_exists(SaveManager.BACKUP_PATH)`
- Offers "Restore Backup" (copies backup → main save, retries load) or "Start Fresh" (deletes save, starts new game)
- Shows brief green "Restored from backup" success note on restore
- If no backup exists, only shows "Start Fresh" option

### Task 2: Wire game_loaded signal to refresh all HUD elements
Connected `Events.game_loaded` in game_hud.gd `_ready()`. The handler waits 2 frames for the player to spawn (matching save_manager's pattern), then re-emits:
- `player_health_changed` with HealthComponent current/max values → HealthBar updates
- `coins_changed` with GameManager.coins → CoinCounter updates
- `exp_gained` + `player_leveled_up` with ProgressionComponent values → ExpBar updates
- `guard_changed` with GuardComponent current/max → GuardBar updates

All null-safe with get_node_or_null checks.

### Task 3: Wire game_restarted signal to clear temporary state
Added `_clear_temporary_state()` to game_manager.gd, called before `reload_current_scene()` in `restart_game()`. This:
- Emits `buff_expired` for each active buff type (clean lifecycle for BuffIcons)
- Clears `inventory.active_buffs` dictionary

Combo counter, poison visuals, and guard meter reset naturally via scene tree destruction — no action needed.

## Decisions Made

| ID | Decision | Rationale |
|----|----------|-----------|
| D29-01-01 | Re-emit Events signals for HUD refresh | All HUD elements already listen to Events — zero changes to child scripts needed |
| D29-01-02 | Only clear Inventory.active_buffs on restart | Only autoload child state survives reload; scene nodes reset naturally |
| D29-01-03 | Use existing ConfirmationDialog for corrupt save UI | Matches existing pattern, node already in scene tree |

## Deviations from Plan

None — plan executed exactly as written.

## Commits

| Task | Commit | Description |
|------|--------|-------------|
| 1 | 3435db3 | feat(29-01): wire save_corrupted signal to title screen warning |
| 2 | 573b728 | feat(29-01): wire game_loaded signal to refresh all HUD elements |
| 3 | 041c8e3 | feat(29-01): clear active buffs on game restart |

## Next Phase Readiness

- **Phase 29-02** (orphaned signal audit): All 3 signals now have handlers. The audit can verify these connections and document remaining unconnected signals.
- **Phase 29-03** (PROJECT.md rewrite): No blockers from this plan.
- No new concerns or blockers discovered.
