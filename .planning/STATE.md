# Momi's Adventure - Project State

## Current Position

Phase: 17 of 20 (New Enemy Types)
Plan: 0 of ? in current phase (PLANNING)
Status: v1.3 Content & Variety — Phase 17 planning
Last activity: 2026-01-29 - Started v1.3 milestone

Progress: ░░░░░░░░░░░░░░░░░░░░ 0%

## Current Status
- **Version**: v1.3 Content & Variety (IN PROGRESS)
- **Last Updated**: 2026-01-29
- **Godot Files**: 84+ scripts
- **Status**: Phase 17 planning — New Enemy Types

## v1.3 Progress
- [ ] Phase 17: New Enemy Types (PLANNING)
- [ ] Phase 18: Shop System
- [ ] Phase 19: The Sewers Zone
- [ ] Phase 20: Mini-Boss System

## Session Continuity
Last session: 2026-01-29
Stopped at: Planning Phase 17
Resume file: None

## v1.3 Decisions
| Decision | Rationale |
|----------|-----------|
| 3 new enemy types | Cat (stealth), Rat (swarm), Shadow (ranged) — each forces different tactics |
| Shop system with NPC | Coin sink, gives purpose to currency earned |
| Sewers dungeon zone | Darker atmosphere, linear progression, boss at end |
| Mini-bosses per zone | Replayability, rare loot motivation, optional challenge |

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
| Boss Raccoon King | 200 | 60 | 25 | 3 patterns, enrage at 50% |

### Zones

| Zone | Enemies | Features |
|------|---------|----------|
| Neighborhood | Raccoons, Crows | Houses, fences, paths, shop (planned) |
| Backyard | Raccoons, Crows | Shed, trees, bushes |
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
| Tab | Ring Menu |
| Q | Cycle Companion |
| ESC | Pause |
| F1 | Toggle AutoBot |
| F2 | Toggle UITester |

---

*v1.3 Content & Variety started: 2026-01-29*
