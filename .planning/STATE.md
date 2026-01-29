# Momi's Adventure - Project State

## Current Position

Phase: 19 of 20 (The Sewers Zone)
Plan: 1 of 3 in current phase
Status: In progress
Last activity: 2026-01-29 - Completed 19-01-PLAN.md (Toxic Puddle & Sewer Infrastructure)

Progress: ██████████░░░░░░░░░░ 46%

## Current Status
- **Version**: v1.3 Content & Variety (IN PROGRESS)
- **Last Updated**: 2026-01-29
- **Godot Files**: 105+ scripts
- **Status**: Phase 19 started — ToxicPuddle hazard component and sewers zone autoload registrations complete. Ready for 19-02 (zone scene layout).

## v1.3 Progress
- [x] Phase 17: New Enemy Types (COMPLETE — 17-01 Stray Cat, 17-02 Sewer Rat, 17-03 Shadow Creature)
- [x] Phase 18: Shop System (COMPLETE — 18-01 Catalog & NPC, 18-02 Shop UI, 18-03 Sell Tab & Restock)
- [ ] Phase 19: The Sewers Zone (IN PROGRESS — 19-01 complete)
- [ ] Phase 20: Mini-Boss System

## Session Continuity
Last session: 2026-01-29
Stopped at: Completed 19-01-PLAN.md (Toxic Puddle & Sewer Infrastructure)
Resume file: None

## v1.3 Decisions
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

---

## PREVIOUS MILESTONES

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

### NPCs

| NPC | Location | Function |
|-----|----------|----------|
| Nutkin the Squirrel | Neighborhood (400, 350) | Shop keeper — press E to interact |

### Zones

| Zone | Enemies | Features |
|------|---------|----------|
| Neighborhood | Raccoons, Crows, Stray Cats, Shadow Creature | Houses, fences, paths, Nutkin's shop |
| Backyard | Raccoons, Crows, Sewer Rats, Shadow Creature | Shed, trees, bushes |
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
