---
phase: 21-save-persistence
verified: 2026-01-28T20:05:00Z
status: passed
score: 4/4 must-haves verified
gaps: []
---

# Phase 21: Save System Persistence — Verification Report

**Phase Goal:** Persist equipment, inventory, and party state across save/load cycles
**Verified:** 2026-01-28
**Status:** ✅ PASSED
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Equipment persists across save/load cycles | ✓ VERIFIED | `_gather_save_data()` calls `GameManager.equipment_manager.get_save_data()` (line 87); `_apply_save_data()` calls `GameManager.equipment_manager.load_save_data(equipment_data)` (line 119); EquipmentManager serializes `equipped` dict + `equipment_inventory` dict (lines 182-186), deserializes with defaults (lines 188-197) |
| 2 | Inventory items persist across save/load cycles | ✓ VERIFIED | `_gather_save_data()` calls `GameManager.inventory.get_save_data()` (line 88); `_apply_save_data()` calls `GameManager.inventory.load_save_data(inventory_data)` (line 123); Inventory serializes `items` dict (lines 203-206), deserializes and emits `inventory_changed` (lines 208-210) |
| 3 | Party state persists across save/load cycles | ✓ VERIFIED | `_gather_save_data()` calls `GameManager.party_manager.get_save_data()` (line 89); `_apply_save_data()` calls `GameManager.party_manager.load_save_data(party_data)` (line 127); PartyManager serializes active companion, knocked-out list, health, meters, AI presets (lines 163-177), deserializes all fields (lines 179-190) |
| 4 | Old v2 saves load without crashing (backward compat) | ✓ VERIFIED | `_validate_save_data()` only requires `["version", "level", "total_exp", "coins", "current_zone"]` — does NOT require equipment/inventory/party keys (line 242); `_apply_save_data()` uses `data.get("equipment", {})` with `is_empty()` guard before calling `load_save_data()` (lines 117-127); v2 saves simply skip sub-system restoration (graceful fallback to defaults) |

**Score:** 4/4 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `autoloads/save_manager.gd` | Full game state persistence including equipment, inventory, party | ✓ VERIFIED | 248 lines, no stubs, no TODOs. Contains `equipment_manager.get_save_data` (line 87). SAVE_VERSION = 3. Used by 6 files (game_manager.gd, title_screen.gd, pause_menu.gd, ring_menu.gd, ui_tester.gd). |
| `systems/equipment/equipment_manager.gd` | get_save_data() and load_save_data() methods | ✓ VERIFIED (pre-existing) | 198 lines, no stubs/TODOs. `get_save_data()` at line 182 returns equipped + inventory. `load_save_data()` at line 188 restores both with defaults and emits `stats_recalculated`. |
| `systems/inventory/inventory.gd` | get_save_data() and load_save_data() methods | ✓ VERIFIED (pre-existing) | 211 lines, no stubs/TODOs. `get_save_data()` at line 203 returns items dict. `load_save_data()` at line 208 restores items and emits `inventory_changed`. |
| `systems/party/party_manager.gd` | get_save_data() and load_save_data() methods | ✓ VERIFIED (pre-existing) | 191 lines, no stubs/TODOs. `get_save_data()` at line 163 returns active, knocked_out, health, meters, presets. `load_save_data()` at line 179 restores all fields. |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `save_manager.gd` | `equipment_manager.gd` | `GameManager.equipment_manager.get_save_data()` / `load_save_data()` | ✓ WIRED | Save: line 87 gathers data. Load: line 119 restores data. Both go through GameManager singleton accessor. |
| `save_manager.gd` | `inventory.gd` | `GameManager.inventory.get_save_data()` / `load_save_data()` | ✓ WIRED | Save: line 88 gathers data. Load: line 123 restores data. Both go through GameManager singleton accessor. |
| `save_manager.gd` | `party_manager.gd` | `GameManager.party_manager.get_save_data()` / `load_save_data()` | ✓ WIRED | Save: line 89 gathers data. Load: line 127 restores data. Both go through GameManager singleton accessor. |
| `save_manager.gd` | callers | `save_game()` / `load_game()` public API | ✓ WIRED | Called from 6 callsites: game_manager.gd (3×), title_screen.gd (1×), pause_menu.gd (1×), ring_menu.gd (1×), ui_tester.gd (1×). |

### Requirements Coverage

| Requirement | Status | Blocking Issue |
|-------------|--------|----------------|
| Equipment, inventory, and party data survive save/load cycles | ✓ SATISFIED | — |
| Save version bump v2→v3 with backward compatibility | ✓ SATISFIED | — |
| Wire SaveManager to call existing get_save_data()/load_save_data() | ✓ SATISFIED | — |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| — | — | — | — | No anti-patterns found. Zero TODOs, FIXMEs, placeholders, or stubs in any modified file. |

### Human Verification Required

### 1. Full Save/Load Round-Trip
**Test:** Equip items, collect inventory, switch companions, save game, quit, reload — verify all state restored
**Expected:** Equipment slots, inventory quantities, active companion, knocked-out status, AI presets all match pre-save state
**Why human:** Requires running the game and comparing state before/after save cycle

### 2. v2 Save Backward Compatibility
**Test:** Place a v2 save file (without equipment/inventory/party keys) in user:// and load it
**Expected:** Game loads without crash; equipment/inventory/party revert to defaults (same as current v2 behavior)
**Why human:** Requires a real v2 save file and running the game

### Gaps Summary

No gaps found. All four must-have truths are verified through code-level analysis:

1. **SaveManager orchestrates correctly** — `_gather_save_data()` calls all three sub-system `get_save_data()` methods and stores results in the save dictionary. `_apply_save_data()` retrieves all three sub-system blocks with `.get()` fallbacks and calls `load_save_data()` on each.

2. **Sub-system serialization is substantive** — Each manager serializes real game state (not stubs): EquipmentManager saves equipped slots + inventory, Inventory saves items dict, PartyManager saves active companion + knocked-out list + health + meters + AI presets.

3. **Backward compatibility is structural** — `_validate_save_data()` does NOT require the new keys, `.get("key", {})` provides empty-dict fallbacks, and `is_empty()` guards prevent calling `load_save_data({})` unnecessarily.

4. **Execution order is safe** — Sub-system restoration happens before `load_zone()` (correct since managers are autoload singletons), player progression restores after zone load via one-shot callback.

---

_Verified: 2026-01-28T20:05:00Z_
_Verifier: Claude (gsd-verifier)_
