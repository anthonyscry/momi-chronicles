# Momi's Adventure - Project State

## Current Position

Phase: Not started (defining requirements)
Plan: —
Status: v1.6 Visual Polish — DEFINING REQUIREMENTS
Last activity: 2026-01-29 — Milestone v1.6 started

Progress: ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ 0% (v1.6)

## Current Status
- **Version**: v1.6 Visual Polish (STARTING)
- **Last Updated**: 2026-01-29
- **Godot Files**: 120+ scripts (100 .gd files)
- **Status**: Defining requirements

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

## Session Continuity
Last session: 2026-01-29
Stopped at: Defining v1.6 requirements
Resume file: None

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

---

*v1.6 Visual Polish started: 2026-01-29*
