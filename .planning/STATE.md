# Momi's Adventure - Project State

## Current Position

Phase: 13 of 16 (Items & Pickups)
Plan: 3 of 3 in current phase
Status: Phase complete
Last activity: 2026-01-28 - Completed 13-03-PLAN.md

Progress: ██████████████████░░ 84%

## Current Status
- **Version**: v1.2 New Mechanics IN PROGRESS
- **Last Updated**: 2026-01-28
- **Godot Files**: 90+
- **Status**: Phase 13 COMPLETE (3/3 plans complete)

## v1.2 Progress
- [x] Phase 12: Block & Parry System (COMPLETE)
- [x] Phase 13: Items & Pickups (COMPLETE - HUD counter, effects, drop tables)
- [ ] Phase 14: Save System
- [ ] Phase 15: UI Testing Automation
- [ ] Phase 16: Ring Menu System

## Session Continuity
Last session: 2026-01-28T04:45:58Z
Stopped at: Completed 13-03-PLAN.md
Resume file: None

## v1.1 Progress (COMPLETE)
- [x] Phase 8: Combo Attack System
- [x] Phase 9: EXP & Level Up System
- [x] Phase 10: Special Abilities
- [x] Phase 11: Boss Enemy & Arena
- [x] Polish: AutoBot uses new combat abilities (combo, charge, ground pound)
- [x] Polish: Enemy respawn system (2.5 min off-camera respawn)

---

## ALL PHASES COMPLETE

### Phase 1: Foundation
- Project configured (384x216 viewport, pixel art)
- Input actions defined (9 actions)
- Autoloads (Events, GameManager)
- State machine system
- Player with movement (idle, walk, run)
- Camera following with smoothing
- Test zone

### Phase 2: Combat Core
- Hitbox component (damage dealing)
- Hurtbox component (damage receiving)
- Health component (HP tracking)
- Attack state (timed hitbox)
- Hurt state (invincibility, flash)

### Phase 3: Enemy Foundation
- Base enemy class with AI
- Enemy states (idle, patrol, chase, attack, hurt, death)
- Raccoon enemy (melee, 40 HP)
- Detection and pursuit AI

### Phase 4: Combat Polish
- Dodge state (i-frames, evasion)
- Crow enemy (fast, flying, 25 HP)
- Knockback on hit

### Phase 5: UI/HUD
- Health bar (color-coded)
- Pause menu (ESC to pause)
- Game over screen
- Title screen
- Player death state

### Phase 6: World Building
- TileSet resource (48 tiles: ground, walls, nature, props)
- Tile atlas PNG (128x128, programmatically generated)
- BaseZone class (common zone functionality)
- Neighborhood zone (houses, fences, paths, enemies)
- Backyard zone (shed, trees, bushes, more enemies)
- ZoneExit component (triggers zone transitions)
- Zone transition system (via GameManager)
- Camera limits per zone

### Phase 7: Polish & Audio (COMPLETE)
- Placeholder audio files generated (7 music + 11 SFX)
- AudioManager integration verified
- Death → Game Over → Retry flow working
- AutoBot testing verified all systems
- Windows export preset configured

---

## Game Features

### Player (Momi)
- **HP**: 100
- **Walk Speed**: 80 px/s
- **Run Speed**: 140 px/s
- **Attack Damage**: 25
- **States**: Idle, Walk, Run, Attack, Hurt, Dodge, Death, SpecialAttack

### Enemies

| Enemy | HP | Speed | Damage | Behavior |
|-------|-----|-------|--------|----------|
| Raccoon | 40 | 55 | 15 | Patrol + Chase |
| Crow | 25 | 75 | 10 | Fast, flies over walls |

### Zones

| Zone | Size | Enemies | Features |
|------|------|---------|----------|
| Neighborhood | 384x216 | 2 Raccoons, 1 Crow | Houses, fences, paths |
| Backyard | 384x216 | 3 Raccoons, 2 Crows | Shed, trees, bushes |

### Controls

| Key | Action |
|-----|--------|
| WASD / Arrows | Move |
| Shift | Run |
| Space / Z | Attack (tap=combo, hold=charge) |
| C / RMB | Ground Pound (level 5+) |
| X | Dodge |
| ESC | Pause |
| F1 | Toggle AutoBot |

### Combat System (v1.1)

| Attack Type | How to Use | Effect |
|-------------|------------|--------|
| Combo Attack | Tap attack 1-3x | 3-hit chain: 1x → 1.25x → 1.75x damage |
| Charge Attack | Hold attack 0.4-1.2s | 1.5x-2.5x damage, lunges forward |
| Ground Pound | Special attack (lvl 5+) | AoE damage + stun, 3s cooldown |

### Enemy Respawn System

- Enemies respawn 2.5 minutes after death
- Only respawn when off-camera (200+ pixels from player)
- Continuously cycle - farming XP forever!

---

## File Structure (60+ Godot files)

```
momi-chronicles/
├── project.godot
├── export_presets.cfg
├── icon.svg
│
├── assets/
│   ├── audio/
│   │   ├── music/ (7 placeholder WAV files)
│   │   └── sfx/ (12 placeholder WAV files)
│   └── tiles/
│       ├── tile_atlas.png
│       ├── world_tileset.tres
│       └── generate_tiles.py
│
├── autoloads/
│   ├── events.gd
│   ├── game_manager.gd
│   ├── audio_manager.gd
│   ├── effects_manager.gd
│   └── auto_bot.gd
│
├── components/
│   ├── state_machine/ (3 files)
│   ├── hitbox/ (2 files)
│   ├── hurtbox/ (2 files)
│   ├── health/ (5 files)
│   ├── pickup/ (2 files)
│   └── zone_exit/ (2 files)
│
├── characters/
│   ├── player/
│   │   ├── player.gd, player.tscn
│   │   └── states/ (8 files)
│   └── enemies/
│       ├── enemy_base.gd
│       ├── raccoon.gd, raccoon.tscn
│       ├── crow.gd, crow.tscn
│       ├── test_dummy.gd, test_dummy.tscn
│       └── states/ (6 files)
│
├── world/zones/
│   ├── base_zone.gd
│   ├── test_zone.gd, test_zone.tscn
│   ├── neighborhood.gd, neighborhood.tscn
│   └── backyard.gd, backyard.tscn
│
├── ui/
│   ├── hud/
│   │   ├── health_bar.gd, health_bar.tscn
│   │   └── game_hud.gd, game_hud.tscn
│   └── menus/
│       ├── title_screen.gd, title_screen.tscn
│       ├── pause_menu.gd, pause_menu.tscn
│       └── game_over.gd, game_over.tscn
│
├── tools/
│   └── generate_placeholder_audio.py
│
└── exports/
    └── windows/ (export destination)
```

---

## How to Play

1. Open `momi-chronicles/project.godot` in Godot 4.5
2. Press F5 to run
3. Game auto-starts with AutoBot (press F1 to take control)
4. Or click "Start Game" on title screen
5. Explore the neighborhood zone
6. Walk to the right edge to enter the backyard
7. Walk to the left edge of backyard to return
8. Fight the raccoons and crows!
9. Press ESC to pause
10. Die and retry, or quit

---

## Requirements Coverage (FINAL)

| Category | Covered | Notes |
|----------|---------|-------|
| Movement (MOV) | 5/5 | All movement requirements |
| Combat (CMB) | 5/6 | Missing combo attacks (out of scope) |
| Health (HLT) | 5/5 | All health requirements |
| Enemies (ENM) | 6/6 | Raccoon + Crow |
| Camera (CAM) | 4/4 | Zone transitions work |
| Animation (ANI) | 0/7 | Using color placeholders (upgrade later) |
| UI (UI) | 5/5 | All UI requirements |
| World (WLD) | 4/4 | Tilemap + zone transitions |
| Audio (AUD) | 5/5 | Placeholder audio working |
| State (STA) | 5/5 | All state requirements |
| Technical (TEC) | 5/5 | All technical requirements |

**Total: 49/52 requirements (94%)**

**Deferred:**
- ANI-01 to ANI-07: Sprite animations (using color placeholders)
- CMB-xx: Combo attacks (future feature)

---

## Verified by AutoBot Testing

The AutoBot ran automated gameplay tests verifying:
- [x] Title screen auto-start
- [x] Player movement (walk, run)
- [x] Combat (attack, special attack, hurt)
- [x] Enemy AI (patrol, chase, attack, death)
- [x] Health system (damage, HP tracking)
- [x] State machines (player 8 states, enemy 6 states)
- [x] Audio system (no crashes, files load)

---

## To Upgrade Audio

1. Generate music using prompts in `SUNO_PROMPTS.md`
2. Convert MP3 to OGG (see `assets/audio/AUDIO_README.md`)
3. Replace the .wav files with your .ogg files
4. Update paths in `autoloads/audio_manager.gd` (.wav → .ogg)

---

*Project completed: 2026-01-27*
*v1.0 MVP - All 7 phases complete*
