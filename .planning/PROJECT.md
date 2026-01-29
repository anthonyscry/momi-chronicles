# Momi's Adventure

## Vision

A 3/4 perspective pixel art action RPG inspired by Chrono Trigger, Stardew Valley, and Earthbound. Players control Momi, a brave French Bulldog who leads the Bulldog Squad -- a neighborhood watch of animal friends protecting their community from mysterious threats. Explore four distinct zones, battle diverse enemies, gear up at the local shop, and take on fearsome bosses with your companions at your side.

## The Bulldog Squad

**Momi** (French Bulldog) -- Leader / DPS
Brave, loyal, protective, and sometimes stubborn. Momi leads the neighborhood watch and is always first into danger. Unique **Zoomies** mechanic: builds speed and damage through sustained combat. Combat kit includes a 3-hit combo chain, charge attack, ground pound (level 5+), dodge roll, and block/parry.

**Cinnamon** (English Bulldog) -- Tank
Tough, stubborn, and utterly reliable. Cinnamon plants herself between the squad and danger. Unique **Overheat** mechanic: absorbs massive damage but overheats if pushed too hard. Draws aggro and soaks hits so the squad can fight safely.

**Philo** (Boston Terrier) -- Support
Laid-back and lazy -- until Momi's in trouble. Unique **Lazy/Motivated** mechanic: starts fights unmotivated (weak output), but motivation surges when Momi takes hits, making Philo increasingly effective in tough encounters.

## Story Context

The peaceful neighborhood has been experiencing strange occurrences -- missing items, weird sounds at night, shadows moving where they shouldn't. Momi investigates, recruits Cinnamon and Philo, and discovers a growing threat that leads from familiar streets down into the sewers and ultimately to a showdown with the Raccoon King.

## The World

1. **Neighborhood** -- Starting zone. Home turf with Nutkin the Squirrel's shop. Alpha Raccoon mini-boss. Manhole entrance to the Sewers.
2. **Backyard** -- Second zone with tougher enemies. Crow Matriarch mini-boss.
3. **Sewers** -- Dungeon zone. Darkness, toxic puddles, tight corridors. Sewer Rats and Shadow Creatures lurk here. Rat King mini-boss. Path to the Boss Arena.
4. **Boss Arena** -- Final zone. Raccoon King boss fight (200 HP, 3 phases, enrage at 50%).

## Enemy Roster

| Enemy | Type | Behavior |
|-------|------|----------|
| Raccoon | Basic melee | Patrols and chases |
| Crow | Aerial | Dive attacks from above |
| Stray Cat | Stealth ambusher | Hides, pounces from stealth, fast retreat |
| Sewer Rat | Swarm (packs of 3-4) | Poison bite DoT |
| Shadow Creature | Ranged | Phases in/out of visibility, shadow bolt projectile |

**Mini-bosses:** Alpha Raccoon (ground slam + summon reinforcements), Crow Matriarch (dive bomb + crow swarm), Rat King (poison cloud + splits at 50% HP).
**Boss:** Raccoon King -- 200 HP, 3 attack patterns, enrage phase at 50%.

---

## Technical Reference

### Stack

- **Engine**: Godot 4.5 / GDScript
- **Resolution**: 384x216 (16:9 pixel art)
- **Art Style**: Pixel art, 16x16/32x32 sprites
- **Perspective**: 3/4 top-down (Stardew Valley style)

### Architecture

- Component-based design (HitboxComponent, HealthComponent, GuardComponent, etc.)
- **Events** autoload signal bus (30+ signals) for decoupled communication
- Call-down-signal-up pattern throughout
- Path-based `extends` (not `class_name`) to avoid autoload scope issues
- Programmatic UI (code-built in `_ready`) -- matches ring menu pattern
- `preload()` for all scene references (eliminates runtime stutter)
- `load()` cached at zone init for dynamic scene paths

### Systems Inventory

| System | Key Details |
|--------|-------------|
| **Combat** | 3-hit combo chain, charge attack, ground pound, block/parry with guard meter, dodge roll |
| **Progression** | EXP/Level system (1-20), stat scaling on level up |
| **Items & Inventory** | Consumables (heal, buff, cure, revive), enemy drop tables, max 20 slots |
| **Equipment** | 5 slots, stat bonuses, managed by EquipmentManager |
| **Ring Menu** | Secret of Mana-style radial menu -- Items, Equipment, Companions, Options rings |
| **Companions** | 3-member party, knocked out/revive mechanics, unique meters per companion |
| **Save System** | Atomic write with backup, auto-save on zone entry/boss defeat, version v3 |
| **Shop** | Nutkin NPC, buy/sell, restock on zone re-entry, stock tracking |
| **AI (AutoBot)** | Full game-playing AI, F1 toggle, dynamic zone awareness, smart item/gear management |

### Autoloads

| Autoload | Purpose |
|----------|---------|
| GameManager | Game state, pause, zone transitions, currency |
| SaveManager | Save/load with atomic writes and backup |
| Events | Global signal bus (30+ signals) |
| AudioManager | BGM + SFX |
| EffectsManager | Visual effects (hit flash, screen shake, particles) |
| ItemDatabase | Item definitions and effect types |
| EquipmentDatabase | Equipment definitions and stat bonuses |
| CompanionData | Companion stats and meter configurations |
| ShopCatalog | Shop pricing and stock definitions |
| DebugLogger | Development logging |
| AutoBot | AI player (F1 toggle) |
| UITester | Automated UI testing (F2 toggle) |
| RingMenu | Secret of Mana-style radial menu (scene autoload) |
| ShopUI | Shop interface (scene autoload) |

### Save Data (v3)

Level, total EXP, coins, current zone, boss/mini-boss defeated flags, equipment loadout, inventory items, party state (companion health/meters). Backward compatible with v1/v2 saves via `.get()` defaults.

### Art Assets

Existing AI-generated sprites in `gemini_images/` folder covering characters, enemies, environment tiles, and UI elements.

### Current Milestone

**v1.5 Integration & Quality Audit** -- Fixing bugs and wiring missing signals from full codebase audit (2026-01-29).

---
*Last updated: 2026-01-29 after v1.4 completion*
