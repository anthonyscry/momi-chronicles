# Phase 29: Signal Integrity & Polish - Context

**Gathered:** 2026-01-29
**Status:** Ready for planning

<domain>
## Phase Boundary

Wire 3 missing signal handlers (save_corrupted, game_loaded, game_restarted), clean up 11 orphaned Events bus signals, and rewrite PROJECT.md to reflect the actual game through v1.4. No new gameplay features — this is audit cleanup only.

</domain>

<decisions>
## Implementation Decisions

### Save Corruption Feedback (SIG-01)
- Show warning on the **title screen** when player tries to load a corrupted save
- **Try backup first**: "Save corrupted. Backup found — restore?" If backup exists, offer restore. If no backup or restore fails, fall back to "Start fresh?"
- Visual style: **red-tinted text overlay** on the title screen — fits existing programmatic UI pattern
- If backup restore succeeds: show **brief "Restored from backup" note** that fades after a few seconds once gameplay starts

### Orphaned Signal Policy (DEBT-02)
- **Keep useful signals with descriptive doc comments**: `## Future hook — could drive buff timer UI, particle effects on buff start/end`
- **Claude audits each of the 11** signals — evaluate which are genuinely useful future hooks vs. speculative dead-ends. Remove truly pointless ones.
- **Removed signals noted in commit message** — list what was removed and why, so it's searchable in git history

### PROJECT.md Rewrite (DEBT-03)
- **Full rewrite** — not a patch, a complete snapshot of the game as it exists today
- **Dual audience**: game overview up top (accessible to anyone), technical reference below (developer details)
- **Personality profiles for characters** — name, breed, role, personality quirk, unique mechanic. A few sentences each. The Bulldog Squad deserves proper introductions.
- **Full progression arc** — document the player journey from Neighborhood through Boss Arena, including mini-bosses, shop, and zone flow

### Claude's Discretion
- Exact wording of save corruption messages
- How long the "Restored from backup" note displays
- PROJECT.md section ordering and formatting
- Which of the 11 orphaned signals to keep vs. remove (with justification)
- Implementation details for game_loaded HUD refresh and game_restarted state clearing

</decisions>

<specifics>
## Specific Ideas

No specific references — open to standard approaches within the decisions above.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 29-signal-integrity*
*Context gathered: 2026-01-29*
