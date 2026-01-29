---
phase: 21-save-persistence
plan: 01
subsystem: save-system
tags: [save, persistence, equipment, inventory, party, backward-compat]

# Dependency graph
requires:
  - phase: 14-save-system
    provides: "SaveManager with atomic writes, backup, version migration"
  - phase: 16-ring-menu
    provides: "EquipmentManager, Inventory, PartyManager with get_save_data/load_save_data helpers"
provides:
  - "Full game state persistence including equipment, inventory, and party data"
  - "Save version v3 with backward compatibility for v2 saves"
affects: [22-polish]

# Tech tracking
tech-stack:
  added: []
  patterns: ["sub-system save/load delegation via get_save_data()/load_save_data()"]

key-files:
  created: []
  modified: ["autoloads/save_manager.gd"]

key-decisions:
  - "Bump save version v2 to v3 for sub-system data"
  - "Use .get() with empty dict defaults for v2 backward compatibility"
  - "Restore sub-systems before zone load (singletons survive transitions)"
  - "No changes needed to sub-system managers — their helpers already worked correctly"

patterns-established:
  - "Sub-system persistence: each manager owns get_save_data()/load_save_data(), SaveManager orchestrates"

# Metrics
duration: 1min
completed: 2026-01-28
---

# Phase 21 Plan 1: Save Persistence Summary

**Wired equipment, inventory, and party sub-system persistence into SaveManager with v2-backward-compatible v3 save format**

## Performance

- **Duration:** 1 min
- **Started:** 2026-01-28T19:48:16Z
- **Completed:** 2026-01-28T19:49:33Z
- **Tasks:** 2 (1 implementation, 1 verification-only)
- **Files modified:** 1

## Accomplishments
- SaveManager now gathers and restores equipment, inventory, and party state across save/load cycles
- Save version bumped from 2 to 3 with graceful backward compatibility (old v2 saves load without crash)
- Verified execution ordering: sub-systems restore before zone load, player progression restores after zone load via callback

## Task Commits

Each task was committed atomically:

1. **Task 1: Wire sub-system save data into SaveManager gather/apply** - `ead5182` (feat)
2. **Task 2: Verify sub-system data ordering** - No commit (verification-only, no code changes needed)

## Files Created/Modified
- `autoloads/save_manager.gd` - Added equipment/inventory/party persistence in gather, apply, and defaults

## Decisions Made
- Bumped SAVE_VERSION v2 to v3 to reflect new sub-system data in save format
- Used `.get("key", {})` with `is_empty()` checks for backward compatibility — v2 saves simply skip sub-system restoration (items revert to defaults, which is the current behavior anyway)
- Confirmed sub-system restore happens BEFORE zone load (correct because managers are autoload singletons)
- No modifications to equipment_manager.gd, inventory.gd, or party_manager.gd — their helpers were already correct

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- Save persistence complete — equipment, inventory, and party state now survive save/load cycles
- Ready for Phase 22 (v1.3 Polish & Tech Debt)
- No blockers or concerns

---
*Phase: 21-save-persistence*
*Completed: 2026-01-28*
