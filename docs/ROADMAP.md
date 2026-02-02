# Momi's Adventure - Comprehensive Roadmap

## Current Position

| Detail | Value |
|--------|-------|
| **Engine** | Godot 4.5 / GDScript |
| **Resolution** | 384×216 (16:9 pixel art) |
| **Perspective** | 3/4 top-down |
| **Current Milestone** | v1.7 Rooftops Zone COMPLETE — Next: v1.8 Quest System |
| **Last Updated** | 2026-02-01 |

---

## Completed Milestones

| Milestone | Status | Summary |
|-----------|--------|---------|
| **v1.0 MVP** | ✅ | Core gameplay: movement, combat, enemies, UI, world |
| **v1.1 Combat & Progression** | ✅ | Combo attacks, EXP/leveling, special abilities, boss |
| **v1.2 New Mechanics** | ✅ | Block/parry, items, save system, ring menu, UI testing |
| **v1.3 Content & Variety** | ✅ | New enemies, shop system, sewers zone, mini-bosses |
| **v1.3.1 Tech Debt & Polish** | ✅ | Save persistence fixes, bug fixes |
| **v1.3.2 Companion Save Fix** | ✅ | Companion health restoration on load |
| **v1.4 AutoBot Overhaul** | ✅ | Full game-playing AI with zone awareness |
| **v1.5 Integration & Quality** | ✅ | Critical bugs, signal integrity, documentation |
| **v1.6 Visual Polish** | ✅ | Pixel art sprites replacing all placeholders |
| **v1.7 Rooftops Zone** | ✅ | New zone, 3 enemy types, Pigeon King mini-boss, wave encounters, boss gating, victory screen |

---

## v1.7: ROOFTOPS ZONE (COMPLETE ✅)

**Goal**: New nighttime rooftop zone with unique enemies and a mini-boss, expanding the game world upward from Neighborhood via ladder.

### Phase 36: New Enemy Types
**Goal**: Create the three new enemy types for the Rooftops zone

| Sub-phase | Name | Status | Deliverables |
|-----------|------|--------|-------------|
| 36-01 | Pigeon Enemy | ✅ Complete | Flock behavior system, aerial swoop attacks, coordinated group AI |
| 36-02 | Garden Gnome | ✅ Complete | Stationary turret enemy, bomb/explosive projectile attacks |

**Also delivered:** Roof Rat enemy (wall-ambush behavior, stealth alpha, retreat mechanics)

---

### Phase 37: Rooftop Spawners
**Goal**: Build the Rooftops zone and populate it with enemies and the Pigeon King mini-boss

| Sub-phase | Name | Status | Deliverables |
|-----------|------|--------|-------------|
| 37-01 | Zone Foundation | ✅ Complete | Rooftops zone layout (4 platforms + 3 walkways), moonlit night atmosphere, chimney obstacles, zone transitions to/from Neighborhood |
| 37-02 | Enemies + Pigeon King | ✅ Complete | ~20 enemies placed (3 pigeon flocks, 4 gnomes, 5 roof rats), Pigeon King mini-boss with swoop dive + reinforcement call |

**Key artifacts:**
- `world/zones/rooftops.gd` / `.tscn` — 5th explorable zone (1200x700)
- `characters/enemies/pigeon_king.gd` / `.tscn` — Mini-boss (120 HP, 2 attack patterns)
- Bidirectional zone transition: Neighborhood ladder ↔ Rooftops

---

### Phase 38: Rooftop Encounters
**Goal**: Wave-based encounter scripting and AutoBot rooftops integration

**Status:** ✅ Complete

**Plans:** 2 plans in 1 wave (parallel)

Plans:
- [x] 38-01-PLAN.md — AutoBot Rooftops zone awareness (game loop progression, platform patrol)
- [x] 38-02-PLAN.md — Wave-based encounter spawning (per-platform triggers, announcements)

**Deliverables:**
- AutoBot game loop includes rooftops in progression chain (neighborhood → backyard → rooftops → sewers → boss)
- AutoBot platform-based patrol points for rooftops zone
- Wave-based enemy spawning (trigger on walkway crossing, not all-at-once)
- Encounter announcement text per platform area

---

### Phase 39: Raccoon King Setup
**Goal**: Boss progression gating and victory endgame flow

**Status:** ✅ Complete

**Plans:** 2 plans in 1 wave (parallel)

Plans:
- [x] 39-01-PLAN.md — Sewers boss door gating (require 2+ mini-boss defeats)
- [x] 39-02-PLAN.md — Boss arena victory screen + re-entry check + game completion

**Deliverables:**
- Boss door gating: require 2 of 4 mini-bosses defeated before entry
- Visual boss door status indicator (X/2 BOSSES orange, ENTER... green)
- Victory screen overlay with stats (level, coins, mini-bosses), flavor text, two buttons
- Continue Playing / Title Screen options after victory
- Boss re-entry prevention (peaceful message + exit, no respawn)
- game_complete flag in GameManager (persists via save, resets on new game)

---

## v1.8: QUEST SYSTEM

### Phase 40: Dialogue System Expansion
**Goal**: Rich NPC interactions beyond shopkeeper — 4 story NPCs with branching dialogue and reputation system

**Status:** 📋 Planned (2 plans)

**Plans:** 2 plans in 1 wave (parallel)

Plans:
- [ ] 40-01-PLAN.md — DialogueNPC base + Gertrude & Maurice (NPCs + dialogue JSON + zone placement)
- [ ] 40-02-PLAN.md — Kids Gang & Henderson + reputation system (remaining NPCs + GameManager reputation tracking)

**Already exists:** DialogueManager autoload, DialogueResource, DialogueData JSON loader, DialogueBox UI (typewriter + choices), NPCBase class, ShopNPC (Nutkin), Events signals for dialogue/quest

| NPC | Role | Location |
|-----|------|----------|
| **Old Lady Gertrude** | Hints about Raccoon King, lore | Near houses (120, 220) |
| **Mailman Maurice** | Neighborhood news, delivery quest hooks | Main road (400, 300) |
| **Kids Gang** | Playful fans of Momi, ball quest hooks | Park area (180, 480) |
| **Grumpy Mr. Henderson** | Hostile → friendly arc, reputation-gated dialogue | North houses (280, 180) |

**Deliverables:**
- ~~Dialogue tree system with branching choices~~ ✅ Already exists
- ~~NPC base class extended for dialogue interaction~~ ✅ Already exists
- Reusable DialogueNPC script (Area2D pattern like ShopNPC)
- 4 NPCs with unique dialogue trees (5-7 nodes each)
- Reputation/friendliness system (0-100 scale, saved, affects Henderson's dialogue)
- Mini-boss defeats boost all NPC reputation (+10 per boss)

---

### Phase 41: Quest Tracking UI
**Goal**: Display active quests and objectives

**Deliverables:**
- Quest journal UI panel (accessible from ring menu)
- Quest objective tracker (HUD corner display)
- Quest completion detection and reward distribution
- Quest givers' marker icons on overworld

---

### Phase 42: Quest Types Implementation
**Goal**: Varied quest structures for engagement

| Quest Type | Example | Structure |
|------------|---------|-----------|
| **Fetch** | Find lost dog toy in Sewers | Collect -> Return -> Reward |
| **Elimination** | Clear 10 crows from Backyard | Kill count -> Return -> Reward |
| **Delivery** | Deliver Acorn to Old Lady Gertrude | Pickup -> Travel -> Deliver -> Reward |
| **Interaction** | Talk to 3 NPCs about the strange noises | NPC visits -> Report -> Reward |
| **Chain** | Series of 4 escalating quests | Quest 1->2->3->4-> Big Reward |

**Deliverables:**
- Quest types: Fetch, Elimination, Delivery, Interaction, Chain
- Quest giver NPC spawning logic
- Quest state machine (available, active, ready_to_complete, completed)
- Quest rewards (EXP, coins, items, reputation)

---

## v1.9: COMPANION & AUDIO

### Phase 43: Companion Ability Expansion
**Goal**: Make companions feel unique and impactful in combat

| Companion | New Ability |
|-----------|-------------|
| **Cinnamon** | Shield Bash -- short charge that stuns enemies for 1s, 8s cooldown |
| **Philo** | Motivated Surge -- activated ability to instantly reach 100% motivation meter |
| **Momi** | Howl -- buffs party attack speed by 15% for 10s, 30s cooldown |

**Deliverables:**
- Companion ability system (hotkey or ring menu activation)
- Ability cooldown UI indicators
- Howl buff system (temporary stat modifier)
- Cinnamon stun mechanic and Philo surge activation

---

### Phase 44: Placeholder Audio Replacement
**Goal**: Real audio assets replacing all placeholders

| Asset Type | Current | Goal |
|------------|---------|------|
| **BGM** | 88 placeholder WAVs | 8-10 curated tracks (Suno or royalty-free) |
| **SFX** | 16 basic WAVs | 40+ contextual SFX |

**Deliverables:**
- Background music themes for each zone (Neighborhood, Backyard, Sewers, Rooftops, Boss)
- Combat music transition system (peaceful -> tense -> intense)
- Per-action SFX: attacks, dodges, block, parry, pickups, UI
- Audio Manager enhancements for music crossfade

---

### Phase 45: Dynamic Audio System
**Goal**: Reactive audio based on gameplay state

| Feature | Implementation |
|---------|---------------|
| **Health-based music** | Intensity increases as player HP drops |
| **Combo audio** | Escalating hitsound on combo counter increase |
| **Ambient layering** | Multiple ambient tracks mixing based on zone and time |
| **Enemy audio** | Unique callouts for enemy spotting, attacking, dying |

**Deliverables:**
- Health-triggered music intensity system
- Combo sound escalation
- Ambient mix engine
- Enemy audio variety system

---

## v1.10: PERFORMANCE & EXPORT

### Phase 46: Web Export Preparation
**Goal**: Browser-playable build

**Deliverables:**
- Web export preset configured
- WASM/ASM.js compatibility check
- File I/O shims for web (IndexedDB for saves)
- Performance profiling and optimization
- Loading screen implementation

---

### Phase 47: Performance Optimization
**Goal**: Target 60 FPS on low-end hardware

| Target | Current | Goal |
|--------|---------|------|
| **FPS** | Variable | Stable 60 |
| **Load time** | ~5s | ~2s |
| **Memory** | ~200MB | ~100MB |
| **Draw calls** | High | Batched |

**Deliverables:**
- Sprite batching for character rendering
- Collision shape simplification
- Unused asset culling
- GDScript optimization (cache calls, reduce _process overhead)
- Particles pooling system

---

## v2.0: RELEASE

### Phase 48: Release Candidate
**Goal**: Polished v2.0 release build

**Checklist:**
- [ ] All placeholder graphics replaced with pixel art
- [ ] All placeholder audio replaced with real audio
- [ ] Web export tested and functional
- [ ] Windows export tested
- [ ] Save system tested across all milestones
- [ ] AutoBot verified playing full game (all zones including Rooftops)
- [ ] No critical bugs in bug tracker
- [ ] Playtest feedback incorporated
- [ ] README and documentation complete
- [ ] itch.io page created with screenshots/video

**Deliverables:**
- v2.0 release build (Windows .exe)
- Web build (itch.io)
- Screenshots and trailer
- Release notes

---

# FEATURE PRIORITIZATION

## Tier 1: Must-Have for v2.0
1. ~~Complete v1.6 visual polish~~ ✅
2. ~~Rooftops zone (Phases 36-39)~~ ✅
3. Web export (Phase 46)
4. Bug cleanup and optimization (Phase 47)

## Tier 2: Strongly Desired
5. Quest system (Phases 40-42)
6. Companion ability expansion (Phase 43)
7. Audio integration (Phases 44-45)

## Tier 3: Future Consideration
8. Multiplayer (local co-op)
9. New game+ mode
10. Speedrun mode with timer
11. Achievement system

---

# ESTIMATED TIMELINE

| Milestone | Phases | Effort |
|-----------|--------|--------|
| v1.7 Rooftops | 36-39 | ✅ COMPLETE |
| v1.8 Quest System | 40-42 | 3-4 weeks |
| v1.9 Companion & Audio | 43-45 | 2-3 weeks |
| v1.10 Performance & Export | 46-47 | 2 weeks |
| v2.0 Release | 48 | 1 week |

**Total remaining**: ~9-12 weeks to v2.0 release

---

# APPENDIX: ROADMAP HISTORY

## v1.0-v1.6 Summary (COMPLETE)

| Milestone | Phases | Key Deliverables |
|-----------|--------|------------------|
| v1.0 MVP | 1-7 | Core gameplay loop |
| v1.1 Combat | 8-11 | Combo system, leveling, boss |
| v1.2 Mechanics | 12-16 | Block/parry, save, ring menu |
| v1.3 Content | 17-20 | New enemies, shop, sewers, mini-bosses |
| v1.3.x Fixes | 21-23 | Save fixes, tech debt |
| v1.4 AutoBot | 24-27 | Full game-playing AI |
| v1.5 Quality | 28-29 | Bug fixes, signal cleanup |
| v1.6 Visual | 30-35 | All pixel art sprites integrated |

## v1.7 Progress (COMPLETE ✅)

| Phase | Name | Status |
|-------|------|--------|
| 36-01 | Pigeon Enemy | ✅ Complete |
| 36-02 | Garden Gnome + Roof Rat | ✅ Complete |
| 37-01 | Rooftops Zone Foundation | ✅ Complete |
| 37-02 | Enemies + Pigeon King | ✅ Complete |
| 38 | Rooftop Encounters | ✅ Complete |
| 39 | Raccoon King Setup | ✅ Complete |

---

*Roadmap last updated: 2026-02-01*
*Next review: After v1.8 Quest System planning*
