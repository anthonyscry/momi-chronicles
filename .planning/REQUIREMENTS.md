# Requirements: Momi's Adventure

**Defined:** 2026-01-29
**Core Value:** Satisfying action RPG combat with Momi and friends — everything wired up and working

## v1.5 Requirements

Requirements for the Integration & Quality Audit milestone. All issues discovered during full codebase audit on 2026-01-29.

### Bug Fixes (BUG)

- [x] **BUG-01**: Revival Bone item from ring menu actually revives a knocked-out companion (not just consumed silently)
- [x] **BUG-02**: Antidote item cures poison when used (method name matches health_component's clear_poison)
- [x] **BUG-03**: Boss summon state uses preload() instead of runtime load() to prevent frame stutters

### Signal Integrity (SIG)

- [ ] **SIG-01**: save_corrupted signal shows player-visible error feedback (toast, HUD message, or title screen warning)
- [ ] **SIG-02**: game_loaded signal triggers UI refresh (health bar, coin counter, EXP bar update to loaded values)
- [ ] **SIG-03**: game_restarted signal clears stale state (active buffs, poison visuals, combo counter)

### Tech Debt (DEBT)

- [x] **DEBT-01**: All scene instantiation uses preload() — no runtime load() in hot paths (boss_attack_summon.gd, base_zone.gd respawn)
- [ ] **DEBT-02**: Orphaned Events bus signals either connected to handlers or removed with comment explaining why
- [ ] **DEBT-03**: PROJECT.md reflects actual game state (characters, features, scope updated through v1.4)

## Out of Scope

| Feature | Reason |
|---------|--------|
| New gameplay features | This milestone is audit/fix only — no new mechanics |
| AutoBot updates | Bot already works around the bugs; fixes target player experience |
| UI redesign | Only add minimal UI for save_corrupted feedback |
| Performance profiling | Fix known load() issues; full profiling deferred |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| BUG-01 | Phase 28 | Complete |
| BUG-02 | Phase 28 | Complete |
| BUG-03 | Phase 28 | Complete |
| SIG-01 | Phase 29 | Pending |
| SIG-02 | Phase 29 | Pending |
| SIG-03 | Phase 29 | Pending |
| DEBT-01 | Phase 28 | Complete |
| DEBT-02 | Phase 29 | Pending |
| DEBT-03 | Phase 29 | Pending |

**Coverage:**
- v1.5 requirements: 9 total
- Mapped to phases: 9
- Unmapped: 0 ✓

---
*Requirements defined: 2026-01-29*
*Last updated: 2026-01-29 after codebase audit*
