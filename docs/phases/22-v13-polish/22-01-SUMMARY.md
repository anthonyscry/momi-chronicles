---
phase: 22-v13-polish
plan: 01
subsystem: polish
tags: [shop, preload, poison, health-component, verification, tech-debt]

# Dependency graph
requires:
  - phase: 17-new-enemies
    provides: "Poison DoT system, enemy states with load() calls"
  - phase: 18-shop-system
    provides: "Shop catalog with SHOP_EQUIPMENT dictionary"
  - phase: 20-mini-bosses
    provides: "Mini-boss loot items, summon states"
provides:
  - "Mini-boss loot sellable at shop (raccoon_crown, crow_feather_coat, rat_king_collar)"
  - "Preloaded summon scenes (no runtime stutter)"
  - "Poison visual stacking (deepening green per source)"
  - "Phase 17 formal verification document"
affects: []

# Tech tracking
tech-stack:
  added: []
  patterns: ["Poison stack tracking with visual escalation", "Sell-only items in SHOP_EQUIPMENT (not in DEFAULT_EQUIPMENT_STOCK)"]

key-files:
  created:
    - .planning/phases/17-new-enemies/17-VERIFICATION.md
  modified:
    - systems/shop/shop_catalog.gd
    - characters/enemies/states/alpha_summon.gd
    - characters/enemies/states/crow_swarm_summon.gd
    - components/health/health_component.gd

key-decisions:
  - "Sell-only mini-boss items — added to SHOP_EQUIPMENT but NOT DEFAULT_EQUIPMENT_STOCK"
  - "maxi() for poison damage stacking — strongest wins, not additive"
  - "0.15 green_intensity step per stack, clamped at 0.3 for visibility"
  - "Retroactive Phase 17 verification from existing SUMMARYs"

patterns-established:
  - "Sell-only pricing: add to SHOP_EQUIPMENT for sell price lookup without adding to DEFAULT_EQUIPMENT_STOCK"
  - "Poison visual escalation: stack count * 0.15 intensity reduction, clamped"

# Metrics
duration: 3min
completed: 2026-01-29
---

# Phase 22 Plan 01: v1.3 Polish & Tech Debt Summary

**Mini-boss loot sellable at 50% value, preload() eliminates summon stutter, poison visual deepens per stack, Phase 17 retroactively verified**

## Performance

- **Duration:** 3 min
- **Started:** 2026-01-29T03:49:26Z
- **Completed:** 2026-01-29T03:52:30Z
- **Tasks:** 3
- **Files modified:** 5 (4 source + 1 verification doc created)

## Accomplishments

- Mini-boss loot items (raccoon_crown, crow_feather_coat, rat_king_collar) now sellable at shop for 50% value (100, 125, 110 coins)
- Alpha Raccoon and Crow Matriarch summon states use preload() constants instead of runtime load(), eliminating potential frame stutter
- Poison system tracks stack count with escalating green visual (0.7→0.55→0.4→0.3 per stack), strongest damage and longest duration preserved via maxi/maxf
- Phase 17 (New Enemy Types) now has formal VERIFICATION.md matching Phases 13-20 format

## Task Commits

Each task was committed atomically:

1. **Task 1: Add mini-boss loot to shop catalog + fix preload** - `ecad842` (feat)
2. **Task 2: Refactor poison visual stacking in HealthComponent** - `91afd8e` (feat)
3. **Task 3: Create Phase 17 VERIFICATION.md** - `40bf154` (docs)

## Files Created/Modified

- `systems/shop/shop_catalog.gd` — Added 3 mini-boss loot entries to SHOP_EQUIPMENT (sell-only, not in buy stock)
- `characters/enemies/states/alpha_summon.gd` — Added RACCOON_SCENE preload const, replaced runtime load()
- `characters/enemies/states/crow_swarm_summon.gd` — Added CROW_SCENE preload const, replaced runtime load()
- `components/health/health_component.gd` — Added poison_stack_count, _update_poison_visual(), maxi/maxf stacking, reset in clear_poison()
- `.planning/phases/17-new-enemies/17-VERIFICATION.md` — Formal verification doc (7/7 must-haves PASS, retroactive)

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| Sell-only items (not in DEFAULT_EQUIPMENT_STOCK) | Shop won't re-sell unique mini-boss loot — players earn it by fighting |
| maxi() for stacked poison damage | Strongest wins, not additive — prevents overpowered stacking |
| maxf() for stacked poison duration | Longest duration wins — short poison can't cancel long poison |
| 0.15 step per stack, clamped at 0.3 | Deepening green signals danger without making sprite invisible |
| Retroactive verification from SUMMARYs | Phase 17 was already confirmed working through Phases 18-20 usage |

## Deviations from Plan

None — plan executed exactly as written.

## Issues Encountered

None

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- All v1.3 tech debt items are now resolved
- v1.3.1 milestone is complete (Phase 21: save persistence + Phase 22: polish)
- Ready for next milestone planning

---
*Phase: 22-v13-polish*
*Completed: 2026-01-29*
