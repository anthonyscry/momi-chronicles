# Momi's Adventure - Project State

## Current Position

Phase: 23 of 23 (Companion Save Restoration)
Plan: 1 of 1 in current phase
Status: v1.3.2 COMPLETE — Companion save restoration gap closed
Last activity: 2026-01-29 - Completed 23-01-PLAN.md

Progress: ████████████████████████████████████████ 100% (v1.3)
          ████████████████████████████████████████ 100% (v1.3.1)
          ████████████████████████████████████████ 100% (v1.3.2)

## Current Status
- **Version**: v1.3.2 Companion Save Fix (COMPLETE)
- **Last Updated**: 2026-01-29
- **Godot Files**: 120+ scripts
- **Status**: v1.3.2 milestone complete — companion health/meter restoration gap closed

## v1.3.1 Progress
- [x] Phase 21: Save System Persistence (COMPLETE — 21-01 sub-system persistence wiring)
- [x] Phase 22: v1.3 Polish & Tech Debt (COMPLETE — 22-01 shop catalog, preload, poison stacking, Phase 17 verification)

## v1.3.2 Progress
- [x] Phase 23: Companion Save Restoration (COMPLETE — 23-01 deferred health/meter restoration)

## Session Continuity
Last session: 2026-01-29
Stopped at: Completed 23-01-PLAN.md (v1.3.2 milestone complete)
Resume file: None

## v1.3.1 Decisions
| Decision | Rationale |
|----------|-----------|
| Save version v2→v3 | Backward compat via .get() defaults for old saves |
| maxi() for stacked poison damage | Strongest wins, not additive (prevents OP stacking) |
| Sell-only mini-boss items (not in DEFAULT_EQUIPMENT_STOCK) | Players can sell rare loot but shop won't re-sell unique items |
| preload() const pattern for summon scenes | Matches rat_king.gd pattern, eliminates runtime stutter |
| Stack-based poison visual (0.15 per stack) | Deepening green signals danger, clamped at 0.3 for visibility |
| _pending_health/_pending_meters deferred restoration | Matches SaveManager _pending_level pattern — store on load, apply on register |

---

## PREVIOUS MILESTONES

### v1.3 Progress (COMPLETE)
- [x] Phase 17: New Enemy Types (COMPLETE — 17-01 Stray Cat, 17-02 Sewer Rat, 17-03 Shadow Creature)
- [x] Phase 18: Shop System (COMPLETE — 18-01 Catalog & NPC, 18-02 Shop UI, 18-03 Sell Tab & Restock)
- [x] Phase 19: The Sewers Zone (COMPLETE — 19-01 Toxic Puddles, 19-02 Zone Layout, 19-03 Manhole & Integration)
- [x] Phase 20: Mini-Boss System (COMPLETE — 20-01 Foundation, 20-02 Alpha Raccoon, 20-03 Crow Matriarch, 20-04 Rat King)

### v1.3 Decisions
| Decision | Rationale |
|----------|-----------|
| 3 new enemy types | Cat (stealth), Rat (swarm), Shadow (ranged) — each forces different tactics |
| Shop system with NPC | Coin sink, gives purpose to currency earned |
| Sewers dungeon zone | Darker atmosphere, linear progression, boss at end |
| Mini-bosses per zone | Replayability, rare loot motivation, optional challenge |
| Path-based extends for new enemies | Avoids class_name autoload scope issues seen in Phase 16 |
| Stealth = alpha modulation (0.15) | Simple, visual, no shader dependency |
| Poison DoT on HealthComponent | Reusable by any enemy/hazard — not rat-specific |
| Pack cohesion via position averaging | Simple swarm behavior without navigation agents |
| Phase cycling via modulate alpha | Shadow visibility toggle without shaders, matches stealth pattern |
| Reusable projectile system (components/projectile/) | Shadow bolt pattern reusable for future ranged enemies/hazards |
| Teleport evasion (random direction) | Unpredictable, mysterious — fits shadow creature lore |
| Polygon-based NPC visuals (Nutkin squirrel) | Matches project pattern of programmatic Polygon2D sprites |
| Area2D NPC interaction (collision_mask = 2) | Same pattern as ZoneExit — detects player layer |
| 50% sell multiplier for shop | Standard RPG sell-back rate, balanced coin economy |
| Programmatic shop UI (all nodes in _ready) | Matches ring_menu pattern — full code control, no scene dependencies |
| Q key for shop category toggle | Reuses cycle_companion action, natural sub-tab cycling |
| Sell 1 at a time (not bulk) | Simpler UX, matches buy-1-at-a-time pattern |
| Only unequipped equipment sellable | Prevents accidental sell of active gear — unequip via ring menu first |
| Stock tracking with zone-entry restock | Limits buying per visit, encourages revisiting |
| 0-stock items filtered from buy list | Cleaner than showing greyed-out unavailable items |
| CanvasModulate + PointLight2D darkness | Near-black darkness with player-carried light — no shaders needed |
| Programmatic dungeon layout (corridor arrays) | All walls/floors/water built in code, .tscn stays minimal |
| S-curve corridor with 4 side rooms | Winding path creates exploration feel, rooms add optional content |
| Boss door requires E press | Prevents accidental zone transition into boss fight |
| Manhole at (530, 370) with require_interaction | Clear of NPCs, press E to enter sewers — prevents accidental transition |
| Programmatic manhole build (_build_manhole) | Matches sewers.gd pattern — code-built visuals, minimal .tscn changes |
| MiniBossIdle uses player. convention | Matches State base class and 10+ regular enemy states (not legacy enemy.) |
| Save v1→v2 with .get() defaults | Graceful migration for existing saves without mini_bosses_defeated |
| Separate mini-boss signals from boss | mini_boss_spawned/defeated avoid conflicts with existing boss flow |
| Orange health bar for mini-bosses | Color(0.9, 0.6, 0.2) visually distinguishes from red boss bar |
| 2s auto-save delay after mini-boss defeat | Shorter than 3s boss delay — lighter celebration |
| AoE slam via distance check (not hitbox) | Cleaner circular area damage, simpler than rotating hitbox |
| Summon cap of 3 alive minions | Prevents raccoon flood overwhelming player |
| Zone trigger at park_center (150, 480) | Open space for fight, matches existing spawn point |
| Warning ground decor fades on spawn | Telegraphs danger zone, cleans up after encounter starts |
| Split in _on_hurt() not a state | Boss continues fighting after splitting — more dramatic mid-fight moment |
| has_split boolean guard | Prevents infinite rat spawning when hit repeatedly below 50% HP |
| Post-split shrink + speed up (2.0→1.7, 55→70) | Wounded desperation — visual + mechanical feedback of damage |
| Poison cloud 4s duration + pulse tween | Long enough to zone players, auto-despawn prevents clutter |

### v1.2 Progress (COMPLETE)
- [x] Phase 12: Block & Parry System
- [x] Phase 13: Items & Pickups
- [x] Phase 14: Save System
- [x] Phase 15: UI Testing Automation
- [x] Phase 16: Ring Menu System

### Phase 16 Decisions
| Decision | Rationale |
|----------|-----------|
| Secret of Mana ring style | User preference for nostalgic feel |
| Tab for ring menu toggle | Non-conflicting with existing controls |
| Q for companion cycling | Quick control switching without menu |
| 5 equipment slots (dog-themed) | Collar, Harness, Leash, Coat, Hat |
| Party fights together (not swap) | All 3 companions on screen at once |
| Philo's Motivation restores when Momi hit | Unique support synergy |
| Instant equipment swap | No confirmation needed per user preference |

### v1.1 Progress (COMPLETE)
- [x] Phase 8: Combo Attack System
- [x] Phase 9: EXP & Level Up System
- [x] Phase 10: Special Abilities
- [x] Phase 11: Boss Enemy & Arena
- [x] Polish: AutoBot uses new combat abilities
- [x] Polish: Enemy respawn system

### v1.0 Progress (COMPLETE)
- [x] Phase 1: Foundation
- [x] Phase 2: Combat Core
- [x] Phase 3: Enemy Foundation
- [x] Phase 4: Combat Polish
- [x] Phase 5: UI/HUD
- [x] Phase 6: World Building
- [x] Phase 7: Polish & Audio

---

## Game Features

### Player (Momi)
- **HP**: 100 (+ level/equipment bonuses)
- **Walk Speed**: 80 px/s
- **Run Speed**: 140 px/s
- **Attack Damage**: 25 (+ level/equipment bonuses)
- **States**: Idle, Walk, Run, Attack, Hurt, Dodge, Death, SpecialAttack, Block, ComboAttack, ChargeAttack, GroundPound

### Enemies

| Enemy | HP | Speed | Damage | Behavior |
|-------|-----|-------|--------|----------|
| Raccoon | 40 | 55 | 15 | Patrol + Chase |
| Crow | 25 | 75 | 10 | Fast, flies over walls |
| Stray Cat | 30 | 90 | 20 | Stealth ambush + retreat |
| Sewer Rat | 15 | 65 | 5+poison | Swarm packs, poison bite DoT |
| Shadow Creature | 35 | 35 | 12 (ranged) | Phase in/out, shadow bolt, teleport evasion |
| Boss Raccoon King | 200 | 60 | 25 | 3 patterns, enrage at 50% |
| Mini: Alpha Raccoon | 120 | 70 | 20 | Ground slam AoE + raccoon summon, drops Raccoon Crown |
| Mini: Crow Matriarch | 80 | 90 | 15 (22 dive) | Dive bomb + crow swarm, drops Crow Feather Coat |
| Mini: Rat King | 150 | 55 (70 post-split) | 18 + poison | Poison AoE cloud, 50% HP splits into 4 rats, drops Rat King's Collar |

### NPCs

| NPC | Location | Function |
|-----|----------|----------|
| Nutkin the Squirrel | Neighborhood (400, 350) | Shop keeper — press E to interact |

### Zones

| Zone | Enemies | Features |
|------|---------|----------|
| Neighborhood | Raccoons, Crows, Stray Cats, Shadow Creature | Houses, fences, paths, Nutkin's shop, manhole to sewers |
| Backyard | Raccoons, Crows, Sewer Rats, Shadow Creature, Crow Matriarch (mini-boss) | Shed, trees, bushes, mini-boss trigger at center |
| Sewers | Sewer Rats, Shadow Creatures | Dark dungeon, PointLight2D, toxic puddles, water channels, boss door |
| Boss Arena | Raccoon King | Locked doors, victory rewards |

### Controls

| Key | Action |
|-----|--------|
| WASD / Arrows | Move |
| Shift | Run |
| Space / Z | Attack (tap=combo, hold=charge) |
| C / RMB | Ground Pound (level 5+) |
| X | Dodge |
| V | Block/Parry |
| E | Interact (shop NPC) |
| Tab | Ring Menu |
| Q | Cycle Companion |
| ESC | Pause |
| F1 | Toggle AutoBot |
| F2 | Toggle UITester |

---

*v1.3 Content & Variety started: 2026-01-29*
*v1.3 Content & Variety completed: 2026-01-29*
*v1.3.1 Tech Debt & Polish started: 2026-01-29*
