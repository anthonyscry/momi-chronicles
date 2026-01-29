---
phase: 23-companion-save
plan: 01
subsystem: save-system
tags: [save-load, party, companion, health, meters, deferred-restoration]

# Dependency graph
requires:
  - phase: 21-save-persistence
    provides: "PartyManager save/load wiring in SaveManager"
provides:
  - "Companion health/meter values restored on load via deferred application"
  - "_pending_health/_pending_meters pattern for post-zone-load state"
affects: []

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Deferred state application: store pending on load, apply on register"

key-files:
  created: []
  modified:
    - "systems/party/party_manager.gd"

key-decisions:
  - "Direct property assignment (current_health/meter_value) instead of setter methods — CompanionBase has no set_health/set_meter_value methods"
  - "Emit health_changed/meter_changed signals after restoration for HUD sync"
  - "Erase pending entries after application to prevent stale data on zone transitions"

patterns-established:
  - "Deferred restoration: _pending_{state} dict populated on load, consumed in register callback"

# Metrics
duration: 1min
completed: 2026-01-29
---

# Phase 23 Plan 01: Companion Save Restoration Summary

**Deferred health/meter restoration in PartyManager using _pending_health/_pending_meters dicts — populated on load_save_data(), consumed on register_companion()**

## Performance

- **Duration:** 1 min
- **Started:** 2026-01-29T04:07:46Z
- **Completed:** 2026-01-29T04:08:52Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments
- Companion health values now persist across save/load cycles
- Companion meter values now persist across save/load cycles
- Deferred application pattern matches SaveManager's _pending_level/_pending_exp approach
- Old saves without health/meter keys load gracefully via .get() empty dict fallback

## Task Commits

Each task was committed atomically:

1. **Task 1: Add deferred health/meter restoration to PartyManager** — `cc99a58` (fix)

## Files Created/Modified
- `systems/party/party_manager.gd` — Added _pending_health/_pending_meters dicts, deferred restoration in register_companion(), pending storage in load_save_data()

## Decisions Made
- **Direct property assignment over setter methods:** CompanionBase has no `set_health()` or `set_meter_value()` — properties `current_health` and `meter_value` are public vars. Set directly and emit signals manually for HUD sync.
- **Signal emission after restoration:** `health_changed` and `meter_changed` signals emitted after setting properties so HUD updates immediately on companion registration.
- **Erase-after-apply pattern:** Pending entries erased after application to prevent stale data from affecting future zone transitions within the same session.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Used direct property assignment instead of nonexistent setter methods**
- **Found during:** Task 1 (implementation)
- **Issue:** Plan assumed `set_health()` and `set_meter_value()` methods exist on CompanionBase. They don't — CompanionBase uses direct public vars (`current_health`, `meter_value`) with getter methods only.
- **Fix:** Set properties directly (`companion_node.current_health = ...`, `companion_node.meter_value = ...`) and manually emit `health_changed`/`meter_changed` signals for HUD synchronization.
- **Files modified:** systems/party/party_manager.gd
- **Verification:** Grep confirms correct property names match CompanionBase declarations (lines 18, 23) and signal patterns (lines 175, 6-7)
- **Committed in:** cc99a58

---

**Total deviations:** 1 auto-fixed (1 bug — nonexistent method names)
**Impact on plan:** Necessary adaptation to actual codebase API. Same behavior, correct implementation.

## Issues Encountered
None

## User Setup Required
None — no external service configuration required.

## Next Phase Readiness
- Companion save/load gap is fully closed
- Phase 23 complete — ready for v1.3.2 milestone closure

---
*Phase: 23-companion-save*
*Completed: 2026-01-29*
