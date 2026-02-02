---
phase: 34-enemy-sprites
summary: 01
type: summary
depends_on: ["33-01"]
files_modified:
  - characters/enemies/enemy_base.gd
  - characters/enemies/raccoon.tscn
  - characters/enemies/crow.tscn
  - characters/enemies/stray_cat.tscn
  - characters/enemies/sewer_rat.tscn
  - characters/enemies/shadow_creature.tscn
  - characters/enemies/alpha_raccoon.tscn
  - characters/enemies/crow_matriarch.tscn
  - characters/enemies/rat_king.tscn
  - characters/enemies/boss_raccoon_king.tscn
  - characters/enemies/states/enemy_idle.gd
  - characters/enemies/states/enemy_patrol.gd
  - characters/enemies/states/enemy_chase.gd
  - characters/enemies/states/enemy_attack.gd
  - characters/enemies/states/enemy_hurt.gd
  - characters/enemies/states/enemy_death.gd
  - characters/enemies/states/cat_stealth.gd
  - characters/enemies/states/cat_pounce.gd
  - characters/enemies/states/crow_dive_bomb.gd
  - characters/enemies/alpha_raccoon.gd
  - characters/enemies/crow_matriarch.gd
  - characters/enemies/rat_king.gd
  - characters/enemies/boss_raccoon_king.gd
  - characters/enemies/shadow_creature.gd
completed: 2026-02-01
---

# Phase 34 Summary: Enemy Sprites

## Overview
Replaced all enemy and boss Polygon2D placeholders with AnimatedSprite2D using generated pixel art sprites. Wired enemy state machines to play correct animations for each state.

## Changes Made

### 1. enemy_base.gd Updates
- Changed `@onready var sprite: Polygon2D` to `AnimatedSprite2D`
- Added `_update_animation()` helper function for state-based animation switching
- Added `_physics_process()` override to call animation updates
- Fixed `sprite.color` → `sprite.modulate` in flash_damage()

### 2. State Script Animation Wiring
Added `player.sprite.play("animation_name")` calls in enter() for:
- `enemy_idle.gd` → "idle"
- `enemy_patrol.gd` → "walk"
- `enemy_chase.gd` → "walk"
- `enemy_attack.gd` → "attack"
- `enemy_hurt.gd` → "hurt"
- `enemy_death.gd` → "death" + fixed tween to use `modulate:a`

### 3. Enemy-Specific Special States
- `cat_stealth.gd` → plays "stealth" animation
- `cat_pounce.gd` → plays "pounce" animation
- `crow_dive_bomb.gd` → plays "attack" animation

### 4. Scene Updates (9 files)
Converted Sprite2D from Polygon2D to AnimatedSprite2D with SpriteFrames:

| Scene | Animations | Sprite |
|-------|------------|--------|
| raccoon.tscn | idle, walk, attack, hurt, death | raccoon_idle.png, raccoon_attack.png |
| crow.tscn | idle, walk, attack, hurt, death (+ dive) | crow_idle.png, crow_dive.png |
| stray_cat.tscn | idle, walk, stealth, pounce, hurt, death | stray_cat_*.png |
| sewer_rat.tscn | idle, walk, attack (pack), hurt, death | sewer_rat_*.png |
| shadow_creature.tscn | idle, walk, attack (bolt), hurt, death | shadow_creature_*.png |
| alpha_raccoon.tscn | idle, walk, attack (slam), summon, hurt, death | alpha_raccoon.png, alpha_raccoon_slam.png |
| crow_matriarch.tscn | idle, walk, attack (dive), summon, hurt, death | crow_matriarch.png, crow_matriarch_dive.png |
| rat_king.tscn | idle, walk, attack (poison), split, hurt, death | rat_king.png, rat_king_poison.png |
| boss_raccoon_king.tscn | idle, idle_enrage, walk, attack, charge, summon, hurt, death | raccoon_king_*.png |

### 5. Boss Enrage Handling
- Added `is_enraged: bool` flag check
- `_enter_enrage()` plays "idle_enrage" animation at 50% HP
- Sprite automatically switches to enrage variant when triggered

### 6. Removed Legacy Polygon2D Decorations
Cleaned up boss scripts that added Polygon2D decorations at runtime:
- `alpha_raccoon.gd` - removed crown/scar Polygon2D children
- `crow_matriarch.gd` - removed crest/eye Polygon2D children
- `rat_king.gd` - removed rat_nub/eye/tail Polygon2D children
- `boss_raccoon_king.gd` - removed crown Polygon2D child
- `shadow_creature.gd` - removed glow_aura Polygon2D

## Verification Checklist
- [x] Zero Polygon2D references in enemy .tscn files
- [x] All 9 enemy scenes use AnimatedSprite2D with SpriteFrames
- [x] All 6 base state scripts have sprite.play() calls
- [x] All 3 enemy-specific states have sprite.play() calls
- [x] Boss enrage triggers animation switch at 50% HP
- [x] All sprite.color references changed to sprite.modulate

## Sprite Assets Used
```
art/generated/enemies/
  raccoon_idle.png, raccoon_attack.png
  crow_idle.png, crow_dive.png
  stray_cat_idle.png, stray_cat_stealth.png, stray_cat_pounce.png
  sewer_rat_idle.png, sewer_rat_pack.png
  shadow_creature_idle.png, shadow_creature_bolt.png

art/generated/bosses/
  alpha_raccoon.png, alpha_raccoon_slam.png
  crow_matriarch.png, crow_matriarch_dive.png
  rat_king.png, rat_king_poison.png
  raccoon_king_normal.png, raccoon_king_enrage.png, raccoon_king_death.png
```

## Impact
- All enemies now display as animated pixel art
- Combat encounters have visual feedback matching gameplay
- Bosses have enrage state with distinct visual
- Zero AI regression - all state logic preserved
