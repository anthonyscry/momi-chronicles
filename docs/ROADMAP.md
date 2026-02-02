# Momi's Adventure - Roadmap

## Current Position

| Detail | Value |
|--------|-------|
| **Engine** | Godot 4.5 / GDScript |
| **Resolution** | 384x216 (16:9 pixel art) |
| **Perspective** | 3/4 top-down |
| **Current Milestone** | v2.0 Export & Release (Phase 45 next) |
| **Last Updated** | 2026-02-01 |

---

## Game Status: Feature Complete

Momi's Adventure has a complete gameplay loop across 42 phases of development:

| System | Status | Details |
|--------|--------|---------|
| **Core Combat** | Complete | 3-hit combo, dodge, block/parry, guard meter |
| **Progression** | Complete | Leveling, EXP, coins, 13 items, 19 equipment pieces |
| **Zones** | Complete | 5 zones: Neighborhood, Backyard, Sewers, Rooftops, Boss Arena |
| **Enemies** | Complete | 8 regular types + 4 mini-bosses + Raccoon King final boss |
| **Companions** | Complete | 3 companions (Momi/Cinnamon/Philo) with unique meter abilities |
| **NPCs & Dialogue** | Complete | 4 story NPCs, branching dialogue, reputation system |
| **Quests** | Complete | 9 quests across 5 types (fetch, elimination, delivery, interaction, chain) |
| **UI** | Complete | HUD, ring menu, shop, quest tracker, quest log, pause menu |
| **Save System** | Complete | v3 atomic saves with backup, full state serialization |
| **Visual Art** | Complete | Pixel art sprites for all entities |
| **AutoBot** | Complete | Full game-playing AI (zones, combat, items, equipment, shop) |

**What remains: bug fixes, audio completion, web export, and release.**

---

## Completed Milestones

| Milestone | Phases | Summary |
|-----------|--------|---------|
| **v1.0 MVP** | 1-7 | Core gameplay: movement, combat, enemies, UI, world |
| **v1.1 Combat & Progression** | 8-11 | Combo attacks, EXP/leveling, special abilities, boss |
| **v1.2 New Mechanics** | 12-16 | Block/parry, items, save system, ring menu, UI testing |
| **v1.3 Content & Variety** | 17-20 | New enemies, shop system, sewers zone, mini-bosses |
| **v1.3.1 Tech Debt & Polish** | 21-22 | Save persistence fixes, bug fixes |
| **v1.3.2 Companion Save Fix** | 23 | Companion health restoration on load |
| **v1.4 AutoBot Overhaul** | 24-27 | Full game-playing AI with zone awareness |
| **v1.5 Integration & Quality** | 28-29 | Critical bugs, signal integrity, documentation |
| **v1.6 Visual Polish** | 30-35 | Pixel art sprites replacing all placeholders |
| **v1.7 Rooftops Zone** | 36-39 | New zone, 3 enemy types, Pigeon King, wave encounters, boss gating, victory screen |
| **v1.8 Quest System** | 40-42 | NPCs, dialogue, reputation, quest engine, 9 quests, tracking UI |
| **v1.9 Stabilization & Audio** | 43-44 | Title screen fix + audio completion ✅ |

---

## v1.9: STABILIZATION & AUDIO

**Goal**: Fix critical bugs, complete audio asset pipeline, and make the game stable enough for export.

### Phase 43: Title Screen Fix & Game Flow Verification
**Goal**: Fix the New Game flow so players can actually start the game, and verify all title screen paths work

**Status:** ✅ Complete

| Issue | Location | Severity | Description |
|-------|----------|----------|-------------|
| New Game shows placeholder | `ui/menus/title_screen.gd` L96+133 | **BLOCKER** | After difficulty selection, `_show_game_start_placeholder()` shows "Game would start here!" instead of loading neighborhood zone |

**Note:** Prior audit found 3 false positives (audio_manager comment separators mistaken for merge conflicts, export_presets headers are correct, Options menu is fully implemented via settings_menu.gd). Only the title screen bug is real.

**Deliverables:**
- `_show_game_start_placeholder()` replaced with actual scene transition to neighborhood
- Dead placeholder UI code removed
- Verified: New Game → difficulty → neighborhood zone loads
- Verified: Continue → save loads → correct zone
- Verified: Quit from pause menu → returns to title screen

**Plans:** 1 plan in 1 wave

Plans:
- [x] 43-01-PLAN.md — Fix title screen New Game flow + verify all game entry paths

---

### Phase 44: Audio Completion
**Goal**: Curate and wire audio assets so every zone and action has real audio

**Status:** ✅ Complete

**Current audio inventory:**
- 34 SFX files (all .wav) — covers most actions
- 66 music files (all .wav) — includes 24+ unused AI-generated candidates
- AudioManager is sophisticated (1079 lines): crossfade, health-based switching, combat intensity, zone mapping, time-of-day variants, A/B testing (F2), 8-channel SFX pool

**Gaps to fill:**
| Gap | Details |
|-----|---------|
| **Sewers music** | No `sewers.wav` — referenced in code but missing file |
| **Rooftops music** | No rooftops zone track |
| **Unused candidates** | 24+ AI-generated WAVs with UUID names sitting unused |
| **SFX coverage** | Most combat/UI covered; may need enemy-specific audio |

**Deliverables:**
- Sewers and Rooftops zone music tracks (curate from existing AI candidates or generate new)
- Unused AI music tracks auditioned and either wired into AudioManager or removed
- SFX gap audit — verify every Events signal that should play audio has a mapped sound
- AUDIO_README.md corrected (currently references .ogg but all files are .wav)

**Plans:** 1 plan in 1 wave

Plans:
- [x] 44-01-PLAN.md — Wire rooftops audio mappings + catalog AI candidates + user picks tracks

---

## v2.0: EXPORT & RELEASE

**Goal**: Browser-playable and Windows-downloadable builds on itch.io.

### Phase 45: Web Export
**Goal**: Working browser build with save persistence and proper input handling

**Status:** Not started

**Current state:** export_presets.cfg has a Web preset targeting `exports/web/index.html`. No browser-specific code exists.

**Deliverables:**
- Web export tested and functional in Chrome/Firefox/Edge
- Save system adapted for web (IndexedDB or Godot's built-in web storage)
- Audio unlock on first user gesture (browser requirement)
- Loading screen during WASM initialization
- Viewport scaling / fullscreen button for browser window
- Input display adapts to keyboard (no gamepad prompts in web)

**Plans:** 1 plan in 1 wave

Plans:
- [ ] 45-01-PLAN.md — Web export build + compatibility guards + browser testing

---

### Phase 46: Performance & Polish
**Goal**: Stable 60 FPS, fast loads, clean release quality

**Status:** Not started

| Target | Goal |
|--------|------|
| **FPS** | Stable 60 on mid-range hardware |
| **Load time** | < 3s to gameplay |
| **Memory** | Minimize unused asset loading |
| **Draw calls** | Batch where possible |

**Deliverables:**
- Performance profiling pass (identify bottlenecks)
- GDScript optimization (cache lookups, reduce _process overhead)
- Unused asset audit and removal
- AutoBot quest integration (bot can exercise quest system for regression testing)
- Full playthrough verification: all 5 zones, all quests completable, save/load works

Plans:
- [ ] TBD — created by /gsd-plan-phase

---

### Phase 47: Release Candidate
**Goal**: Ship v2.0 on itch.io

**Status:** Not started

**Release Checklist:**
- [ ] All pixel art sprites in place (verified v1.6)
- [ ] All audio assets wired (no silent actions)
- [ ] Web export tested in 3+ browsers
- [ ] Windows export tested (.exe)
- [ ] Save system tested (new game, save, load, cross-zone)
- [ ] All 9 quests completable start to finish
- [ ] Victory screen reachable and functional
- [ ] AutoBot can play full game without crashes
- [ ] No critical bugs
- [ ] README updated with controls, features, credits
- [ ] itch.io page: screenshots, description, tags

**Deliverables:**
- Windows .exe build
- Web build (itch.io hosted)
- Screenshots (at least 1 per zone)
- Release notes
- itch.io page published

Plans:
- [ ] TBD — created by /gsd-plan-phase

---

# FEATURE PRIORITIZATION

## Tier 1: Must-Have for v2.0 Release
1. ~~Visual polish~~ ✅ (v1.6)
2. ~~Rooftops zone~~ ✅ (v1.7)
3. ~~Quest system~~ ✅ (v1.8)
4. Critical bug fixes (Phase 43)
5. Audio completion (Phase 44)
6. Web export (Phase 45)
7. Performance pass (Phase 46)

## Tier 2: Should-Have (do if time permits)
8. AutoBot quest awareness (in Phase 46 as regression testing)
9. Options menu with audio controls (in Phase 43 bug fixes)
10. Enemy-specific audio cues

## Tier 3: Post-Release / Future
11. Companion visual ability effects (particles, shockwaves)
12. Companion leveling/progression
13. New Game+ mode
14. Speedrun timer mode
15. Achievement system
16. Local co-op multiplayer
17. Additional zones and quest content

---

# ESTIMATED TIMELINE

| Milestone | Phases | Phase Count |
|-----------|--------|-------------|
| ~~v1.0-v1.8~~ | 1-42 | ✅ COMPLETE (42 phases) |
| v1.9 Stabilization & Audio | 43-44 | 2 phases |
| v2.0 Export & Release | 45-47 | 3 phases |

**Remaining: 5 phases to v2.0 release**

---

# APPENDIX: DEVELOPMENT HISTORY

## Phase Detail (v1.0-v1.8)

| Milestone | Phases | Key Deliverables |
|-----------|--------|------------------|
| v1.0 MVP | 1-7 | Core gameplay loop |
| v1.1 Combat | 8-11 | Combo system, leveling, boss |
| v1.2 Mechanics | 12-16 | Block/parry, save, ring menu |
| v1.3 Content | 17-20 | New enemies, shop, sewers, mini-bosses |
| v1.3.x Fixes | 21-23 | Save fixes, tech debt |
| v1.4 AutoBot | 24-27 | Full game-playing AI |
| v1.5 Quality | 28-29 | Bug fixes, signal cleanup |
| v1.6 Visual | 30-35 | All pixel art sprites |
| v1.7 Rooftops | 36-39 | 5th zone, 3 enemy types, Pigeon King, wave encounters, boss gating, victory |
| v1.8 Quest System | 40-42 | NPCs, dialogue, reputation, 9 quests, quest UI |

## Key Architectural Decisions

| Decision | Phase | Rationale |
|----------|-------|-----------|
| Component-based architecture | v1.0 | Composable, reusable systems |
| Events autoload signal bus | v1.0 | Decoupled communication |
| Path-based extends (not class_name) | v1.0 | Avoids autoload scope issues |
| Programmatic UI (code-built in _ready) | v1.2 | Matches ring menu pattern, full control |
| Save version v3 with .get() defaults | v1.3 | Backward compatible migration |
| DialogueNPC Area2D pattern | v1.8 | Reusable, programmatic, matches ShopNPC |
| Data-driven quest definitions | v1.8 | Matches ItemDatabase/EquipmentDatabase pattern |
| Event-driven quest objectives | v1.8 | Signal-based completion via Events bus |

## Content Inventory (as of v1.8)

| Category | Count | Details |
|----------|-------|---------|
| Zones | 5 (+1 test) | Neighborhood, Backyard, Sewers, Rooftops, Boss Arena |
| Regular Enemies | 8 | Raccoon, Crow, Stray Cat, Sewer Rat, Shadow Creature, Pigeon, Roof Rat, Garden Gnome |
| Mini-bosses | 4 | Alpha Raccoon, Crow Matriarch, Rat King, Pigeon King |
| Final Boss | 1 | Raccoon King |
| Companions | 3 | Momi (Zoomies), Cinnamon (Overheat/Block), Philo (Motivation/Heal) |
| Story NPCs | 4 | Gertrude, Maurice, Kids Gang, Henderson |
| Shop NPCs | 1 | Nutkin |
| Items | 13 | 5 healing, 3 buffs, 1 guard, 1 antidote, 2 tactical, 1 revival |
| Equipment | 19 | 5 slots x 3 tiers + 4 boss drops |
| Quests | 9 | 2 interaction, 1 fetch, 1 elimination, 1 delivery, 4-part chain |
| Audio (SFX) | 34 | .wav files covering combat, UI, movement |
| Audio (Music) | 66 | .wav files including zone themes, combat variants, AI candidates |

---

*Roadmap last updated: 2026-02-01*
*Next action: Plan Phase 45 (Web Export)*
