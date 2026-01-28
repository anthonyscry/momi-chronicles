# Phase 14: Save System - Context

**Gathered:** 2026-01-28
**Status:** Ready for planning

<domain>
## Phase Boundary

Persist player progress between game sessions. Single save slot with auto-save and manual save. Load game resumes from saved state. Multiple save slots are out of scope.

</domain>

<decisions>
## Implementation Decisions

### Save trigger timing
- Auto-save on zone transitions (entering new zone)
- Auto-save after boss defeated + victory celebration/rewards complete
- Manual save available from pause menu

### Load game flow
- Player spawns at zone entrance (not exact position)
- Visual cut transition (Persona 5-style quick screen wipe, not fade)
- Brief transition effect then straight to gameplay

### Title screen behavior
- "Continue" option appears if save exists
- "New Game" shows confirmation if save exists ("This will overwrite your save. Continue?")
- If no save exists, only "New Game" shown

### Claude's Discretion
- Data corruption handling (validate on load, warn if corrupt, offer fresh start, keep .bak for recovery)
- Save file format and location
- Exact visual cut implementation (color, speed, style matching game aesthetic)
- What happens if save fails mid-write (atomic write pattern)

</decisions>

<specifics>
## Specific Ideas

- Persona 5-style transition: quick stylized visual cut/wipe, not a slow fade
- Save should feel instant and unobtrusive during gameplay
- After boss kill, wait for celebration/rewards before triggering save

</specifics>

<deferred>
## Deferred Ideas

- Multiple save slots (2+) — future polish phase
- Save slot selection UI — depends on multiple slots
- Cloud save sync — out of scope

</deferred>

---

*Phase: 14-save-system*
*Context gathered: 2026-01-28*
