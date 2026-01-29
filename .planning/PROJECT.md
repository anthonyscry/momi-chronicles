# Momi's Adventure - Project Definition

## Vision
A 3/4 perspective pixel art action RPG in the style of Chrono Trigger, Stardew Valley, and Earthbound. Players control Momi, a brave French Bulldog who leads a neighborhood watch of animal friends to protect their community from mysterious threats.

## Core Pillars
1. **Charming Character-Driven Story** - Focus on Momi and friends' personalities
2. **Accessible Action Combat** - Simple but satisfying combat system
3. **Exploration & Discovery** - Neighborhoods to explore, secrets to find
4. **Cozy Atmosphere** - Warm, inviting pixel art world

## Main Characters

### Momi (Protagonist)
- **Species**: French Bulldog
- **Role**: Leader of the Neighborhood Watch
- **Personality**: Brave, loyal, protective, sometimes stubborn
- **Combat Style**: Melee-focused with charge attacks

### Cinnamon
- **Species**: Cat
- **Role**: Momi's best friend, ranged support
- **Personality**: Clever, sarcastic, secretly caring
- **Combat Style**: Ranged attacks, debuffs

### Philo
- **Species**: Golden Retriever
- **Role**: Tank/Support
- **Personality**: Friendly, optimistic, not the brightest
- **Combat Style**: Defensive, can draw aggro

## Story Context
The peaceful neighborhood has been experiencing strange occurrences - missing items, weird sounds at night, shadows moving where they shouldn't. Momi takes it upon themselves to investigate, recruiting friends along the way to form the Neighborhood Watch.

## Technical Stack
- **Engine**: Godot 4.5
- **Language**: GDScript
- **Resolution**: 384x216 (16:9 pixel art)
- **Art Style**: Pixel art, 16x16 or 32x32 character sprites
- **Perspective**: 3/4 top-down (like Stardew Valley)

## Art Assets
Existing AI-generated sprites in `gemini_images/` folder:
- Character sprites for Momi, Cinnamon, Philo
- Enemy sprites (raccoons, crows, shadow creatures)
- Environment tiles
- UI elements

## Current Milestone: v1.5 Integration & Quality Audit

**Goal:** Fix confirmed bugs, wire missing signal handlers, and clean up tech debt discovered during full codebase audit.

**Target fixes:**
- Revival Bone ring menu stub (item consumed, no revive)
- Antidote cure_poison/clear_poison method mismatch
- Boss summon runtime load() stutter
- save_corrupted signal with no UI handler
- Orphaned signal cleanup & documentation update

## Validated Capabilities

### v1.0 MVP ✓
- Player movement, combat, dodge, block/parry
- 2 base enemy types (raccoon, crow), state machine AI
- 4 zones (neighborhood, backyard, sewers, boss arena)
- Health/damage system with poison DoT
- UI: health bar, guard bar, EXP bar, coin counter, combo counter, ability bar
- Pause menu, title screen, game over screen
- Audio system with BGM + SFX

### v1.1 Combat & Progression ✓
- 3-hit combo chain with timing windows
- EXP/leveling system (1-20)
- Charge attack, ground pound (level 5+)
- Boss fight (Raccoon King, 200 HP, 3 patterns, enrage)

### v1.2 New Mechanics ✓
- Block/parry with guard meter
- Items & pickups (health, coins, drop tables)
- Save system (atomic write, backup, auto-save)
- UI testing automation (F2)
- Ring menu (Secret of Mana style) with items, equipment, companions
- 3-companion party: Momi (DPS), Cinnamon (Tank), Philo (Support)

### v1.3 Content & Variety ✓
- 3 new enemies: Stray Cat (stealth), Sewer Rat (swarm/poison), Shadow Creature (ranged)
- Shop system with Nutkin NPC, buy/sell, restock
- Sewers dungeon zone with darkness, toxic puddles
- 3 mini-bosses: Alpha Raccoon, Crow Matriarch, Rat King

### v1.4 AutoBot Overhaul ✓
- Dynamic zone awareness, hazard avoidance
- Smart item/gear management
- Zone traversal & NPC interaction
- Full game loop AI (FARM→SHOP→TRAVERSE→CLEAR→BOSS→VICTORY)

## Technical Stack
- **Engine**: Godot 4.5
- **Language**: GDScript
- **Resolution**: 384x216 (16:9 pixel art)
- **Art Style**: Pixel art, 16x16 or 32x32 character sprites
- **Perspective**: 3/4 top-down (like Stardew Valley)
- **Architecture**: Component-based, signal bus (Events autoload), call-down-signal-up

## Main Characters

### Momi (Protagonist)
- **Species**: French Bulldog
- **Role**: Leader / DPS — Zoomies mechanic
- **Combat Style**: Melee-focused with charge attacks, combos, ground pound

### Cinnamon
- **Species**: English Bulldog
- **Role**: Tank — Overheat mechanic
- **Combat Style**: Defensive, draws aggro

### Philo
- **Species**: Boston Terrier
- **Role**: Support — Lazy/Motivated mechanic
- **Combat Style**: Support, motivation restores when Momi hit

---
*Last updated: 2026-01-29 after v1.5 milestone initialization*
