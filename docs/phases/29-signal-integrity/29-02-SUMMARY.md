---
phase: 29
plan: 02
subsystem: signal-bus
tags: [signals, events, cleanup, documentation]
dependency-graph:
  requires: []
  provides: [cleaned-signal-bus, orphaned-signal-docs]
  affects: []
tech-stack:
  added: []
  patterns: [doc-comment-future-hooks]
file-tracking:
  key-files:
    created: []
    modified:
      - autoloads/events.gd
      - ui/ring_menu/ring_menu.gd
decisions:
  - id: d29-02-01
    description: "Remove ring_item_selected signal — redundant with internal ring_menu handling"
    rationale: "ring_menu.gd already handles selection via direct calls to Inventory.use_item(), EquipmentManager, and PartyManager. No external system needs this broadcast."
  - id: d29-02-02
    description: "Keep 10 other orphaned signals with Future hook doc comments"
    rationale: "All have active emitters and plausible future use. Comments prevent confusion about why unconnected signals exist."
metrics:
  duration: "3 min"
  completed: "2026-01-29"
---

# Phase 29 Plan 02: Orphaned Signal Audit Summary

**One-liner:** Audited 11 orphaned Events bus signals — removed 1 dead signal (ring_item_selected), documented 10 as future hooks with descriptive comments.

## What Was Done

### Task 1: Audit and classify all 11 orphaned signals

Analyzed all 11 signals identified as orphaned (emitted but never connected):

**Kept with "Future hook" doc comments (8 signals):**
1. `stats_updated` — emitted on level-up, could drive stat sheet UI/achievements
2. `zone_exited` — emitted before zone transition, could drive cleanup/tracking
3. `player_block_ended` — emitted when block released, could drive SFX/AI reactions
4. `player_guard_broken` — guard meter depleted, could drive stagger/aggro effects
5. `ring_menu_closed` — paired with ring_menu_opened, could resume hidden UI
6. `equipment_changed` — broadcast on slot change, could drive inventory UI
7. `pickup_collected` — emitted on any pickup, could drive stats/achievements
8. `game_restarted` — emitted on restart, state cleared in GameManager

**Updated doc comments (not orphaned, but clarified purpose):**
9. `save_corrupted` — already connected in title_screen.gd
10. `game_loaded` — emitted by save_manager, could drive HUD refresh

**Removed (1 signal):**
11. `ring_item_selected` — redundant with ring_menu.gd internal handling. The ring menu already processes selections directly via `_use_item()`, `_equip_item()`, `_switch_companion()`, and `_handle_option()`. No external system consumed this broadcast.

### Files Modified
- `autoloads/events.gd` — Updated 10 doc comments, removed `ring_item_selected` signal declaration
- `ui/ring_menu/ring_menu.gd` — Removed `Events.ring_item_selected.emit()` call from `activate_selected()`

## Deviations from Plan

### Minor Corrections

**1. save_corrupted already has a consumer**
- Plan classified save_corrupted as orphaned, but title_screen.gd already connects to it (line 22)
- Still updated the doc comment to clarify its purpose
- No impact on plan outcome

**2. Signal count was 53, not ~30**
- Plan estimated ~30 signals; actual count was 54 (now 53 after removal)
- No impact — all 11 orphaned signals were correctly identified and handled

## Verification

- [x] `ring_item_selected` removed from events.gd (signal declaration gone)
- [x] `Events.ring_item_selected.emit()` removed from ring_menu.gd
- [x] grep for `ring_item_selected` across all .gd files returns zero matches
- [x] All orphaned signals have descriptive doc comments (## prefix)
- [x] Signal count decreased by 1 (54 → 53)
- [x] No runtime errors — connected signals unchanged, only orphaned signals modified

## Commits

| Task | Commit | Message |
|------|--------|---------|
| 1 | 6fe5c80 | refactor(29-02): audit orphaned signals — doc comments + remove dead signal |
