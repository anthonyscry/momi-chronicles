# Momi's Adventure - Project State

## Current Position

Phase: 31 — Art Generation Checkpoint ⏸️
Plan: —
Status: v1.6 Visual Polish — Phase 30 COMPLETE, awaiting user art generation
Last activity: 2026-01-29 — Phase 30 Art Pipeline Tooling verified ✅

Progress: ██████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ ~17% (v1.6)

## Current Milestone: v1.6 Visual Polish

| Phase | Name | Requirements | Status |
|-------|------|-------------|--------|
| 30 | Art Pipeline Tooling | TOOL-01, TOOL-02 | ✅ Complete |
| 31 | Art Generation Checkpoint | (human gate) | ⬜ Pending |
| 32 | Player Sprite Integration | CHAR-01 | ⬜ Pending |
| 33 | Companion Sprites | CHAR-02, CHAR-03 | ⬜ Pending |
| 34 | Enemy & Boss Sprites | ENEM-01, ENEM-02, ENEM-03 | ⬜ Pending |
| 35 | World, Items & Effects | WRLD-01, WRLD-02, FX-01, FX-02, INTG-01, INTG-02 | ⬜ Pending |

## Accumulated Decisions (from v1.0-v1.5)
| Decision | Rationale |
|----------|-----------|
| Component-based architecture | Composable, reusable systems |
| Events autoload signal bus | Decoupled communication |
| call-down-signal-up pattern | Clear data flow |
| Path-based extends (not class_name) | Avoids autoload scope issues |
| Programmatic UI (code-built in _ready) | Full control, matches ring_menu pattern |
| preload() for all scene references | Eliminates runtime stutter |
| Save version v3 with .get() defaults | Backward compatible migration |
| First-in-first-revived ordering for Revival Bone | Simple, deterministic knocked_out.keys()[0] |
| Cache scenes with load() at zone init | Dynamic scene paths can't use preload(); init-time load() is equivalent |
| Re-emit Events signals for HUD refresh on load | All HUD elements already listen — zero child script changes needed |
| Clear only Inventory.active_buffs on restart | Only autoload child state survives scene reload |
| Dual-audience PROJECT.md (overview + technical) | Accessible to anyone; detailed for developers |
| White background prompts for AI art generation | AI generators ignore hex color requests; flood-fill from corners works reliably |
| Suno pattern for Gemini automation | Consistent Playwright sync API, argparse CLI, try/except import guard |
| 3-tier image download fallback | Gemini DOM varies; blob extraction → JS fetch → manual save prevents crashes |

## Session Continuity
Last session: 2026-01-29
Stopped at: Phase 31 — API generator script fixed, need to switch to Imagen 4 Fast + enable billing
Resume file: .planning/CONVERSATION_SUMMARY.md

---

## ALL PREVIOUS MILESTONES COMPLETE

| Milestone | Phases | Status |
|-----------|--------|--------|
| v1.0 MVP | 1-7 | ✅ COMPLETE |
| v1.1 Combat & Progression | 8-11 | ✅ COMPLETE |
| v1.2 New Mechanics | 12-16 | ✅ COMPLETE |
| v1.3 Content & Variety | 17-20 | ✅ COMPLETE |
| v1.3.1 Tech Debt & Polish | 21-22 | ✅ COMPLETE |
| v1.3.2 Companion Save Fix | 23 | ✅ COMPLETE |
| v1.4 AutoBot Overhaul | 24-27 | ✅ COMPLETE |
| v1.5 Integration & Quality Audit | 28-29 | ✅ COMPLETE |
| v1.6 Visual Polish | 30-35 | 🔄 IN PROGRESS |

---

*v1.6 Visual Polish started: 2026-01-29*
