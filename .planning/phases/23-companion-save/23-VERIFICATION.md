---
phase: 23-companion-save
verified: 2026-01-28T22:15:00Z
status: passed
score: 4/4 must-haves verified
---

# Phase 23: Companion Save Restoration — Verification Report

**Phase Goal:** Restore companion health and meter values when loading a save
**Verified:** 2026-01-28
**Status:** ✅ PASSED
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Companion health values persist across save/load cycles | ✓ VERIFIED | `get_save_data()` stores per-companion health (L178-183), `load_save_data()` reads into `_pending_health` (L208), `register_companion()` applies to `current_health` (L85-88) |
| 2 | Companion meter values persist across save/load cycles | ✓ VERIFIED | `get_save_data()` stores per-companion meters (L179-183), `load_save_data()` reads into `_pending_meters` (L209), `register_companion()` applies to `meter_value` (L89-92) |
| 3 | Deferred application works — health/meters applied after companions register | ✓ VERIFIED | Timing confirmed: `load_save_data()` runs before `load_zone()` (save_manager.gd L127→L141). Zone load spawns companions → `_ready()` calls `_load_companion_data()` (sets max HP) then `register_companion()` (overrides with saved value). Correct order. |
| 4 | Missing health/meter data in old saves doesn't crash (graceful fallback) | ✓ VERIFIED | `data.get("health", {})` and `data.get("meters", {})` at L208-209 return empty dicts when keys are absent. Empty dicts mean `_pending_health.has(companion_id)` is always false → no application, companions keep default values. |

**Score:** 4/4 truths verified

### Required Artifacts

| Artifact | Expected | Exists | Substantive | Wired | Status |
|----------|----------|--------|-------------|-------|--------|
| `systems/party/party_manager.gd` | Deferred companion health/meter restoration on load | ✓ (210 lines) | ✓ (210 lines, no stubs, no TODOs) | ✓ (called by save_manager.gd L127, L89; companions register via companion_base.gd L59) | ✓ VERIFIED |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `party_manager.gd load_save_data()` (L208-209) | `party_manager.gd register_companion()` (L85-92) | `_pending_health` and `_pending_meters` dicts | ✓ WIRED | Load stores → register consumes and erases. 5 refs each: declaration (L29-30), has-check (L85,89), assignment (L86,90), erase (L88,92), populate (L208-209) |
| `save_manager.gd` (L89) | `party_manager.gd get_save_data()` (L177) | `GameManager.party_manager.get_save_data()` | ✓ WIRED | Save path: iterates companions dict, calls `get_current_health()` and `get_meter_value()`, returns in dict |
| `save_manager.gd` (L127) | `party_manager.gd load_save_data()` (L193) | `GameManager.party_manager.load_save_data(party_data)` | ✓ WIRED | Load path: reads party data from save file, passes to party_manager |
| `companion_base.gd _ready()` (L59) | `party_manager.gd register_companion()` (L76) | `GameManager.party_manager.register_companion(companion_id, self)` | ✓ WIRED | Registration triggers deferred restore; happens AFTER `_load_companion_data()` (L51) so default values are set first, then overridden |
| `register_companion()` (L87,91) | HUD | `health_changed.emit()` / `meter_changed.emit()` signals | ✓ WIRED | Signals emitted after property assignment so HUD syncs immediately; signal signatures match CompanionBase declarations (L6-7) |

### Deviation Verification: Direct Property Assignment

The executor deviated from the plan by using direct property assignment (`companion_node.current_health = ...`, `companion_node.meter_value = ...`) instead of setter methods (`set_health()`, `set_meter_value()`).

**Verification:** This is CORRECT.

- CompanionBase declares `var current_health: int` (L17) and `var meter_value: float` (L23) as public vars
- No `set_health()` or `set_meter_value()` methods exist in CompanionBase (confirmed via full file read)
- Only getter methods exist: `get_current_health()` (L219), `get_meter_value()` (L225)
- Direct property assignment is the correct GDScript approach for public vars
- Signal emissions are manually added after assignment (L87, L91) to sync HUD — this is necessary because direct assignment doesn't auto-emit signals
- Signal signatures are type-compatible: `health_changed(int, int)` gets `(current_health:int, max_health:int)`, `meter_changed(float, float)` gets `(meter_value:float, meter_max:float)`

**Conclusion:** Deviation was a necessary and correct adaptation to the actual API.

### Timing Analysis

Critical execution order during load:

```
save_manager.load_game()
  ├── party_manager.load_save_data(party_data)     ← stores _pending_health/_pending_meters
  └── GameManager.load_zone(target_zone)            ← triggers zone scene load
        └── Companion scenes instantiate
              └── companion_base._ready()
                    ├── _load_companion_data()       ← sets current_health = max_health
                    └── register_companion(id, self) ← overrides with saved health
                          ├── current_health = _pending_health[id]
                          ├── health_changed.emit()
                          ├── meter_value = _pending_meters[id]
                          ├── meter_changed.emit()
                          └── erase pending entries
```

Order is correct: pending values populated BEFORE zone load, applied AFTER companion initialization. The `_load_companion_data()` → `register_companion()` order within `_ready()` ensures defaults are set first, then overridden by saved values.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| — | — | None found | — | — |

No TODOs, FIXMEs, placeholders, empty implementations, or stub patterns detected in `party_manager.gd`.

### Human Verification Required

### 1. Save/Load Round-Trip Test
**Test:** Play the game, take damage with a companion (reduce health below max), build meter partially, then save. Load that save and check companion health/meter values.
**Expected:** Companion health should match the value at save time (not full HP). Meter should match saved value.
**Why human:** Requires running the game and observing in-game HUD values across save/load cycle.

### 2. Old Save Compatibility
**Test:** Load a save file from before phase 23 (one without "health" or "meters" keys in the party data).
**Expected:** Game loads normally, companions start at full health with default meter values. No errors in console.
**Why human:** Requires an actual old-format save file and observing console output.

### 3. Zone Transition After Load
**Test:** After loading a save with damaged companions, transition to a different zone and back.
**Expected:** Health values persist through zone transitions (pending data was erased after application, so zone transitions use normal register flow without stale pending data).
**Why human:** Requires multi-step gameplay interaction.

## Gaps Summary

No gaps found. All 4 must-have truths verified against actual code:

1. **Save path complete:** `get_save_data()` collects `current_health` and `meter_value` from all registered companions
2. **Load path complete:** `load_save_data()` stores health/meters as pending dictionaries
3. **Deferred application works:** `register_companion()` checks for pending data, applies it, emits signals, and erases consumed entries
4. **Backward compatibility ensured:** `.get("health", {})` gracefully handles missing keys in old saves
5. **Deviation valid:** Direct property assignment is correct — no setter methods exist on CompanionBase

---

_Verified: 2026-01-28T22:15:00Z_
_Verifier: Claude (gsd-verifier)_
