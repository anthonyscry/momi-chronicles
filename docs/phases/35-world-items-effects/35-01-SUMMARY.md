---
phase: 35-world-items-effects
summary: 01
type: summary
depends_on: ["34-01"]
files_modified:
  - characters/npcs/shop_npc.tscn
  - characters/npcs/shop_npc.gd
  - ui/ring_menu/ring_item.tscn
  - ui/ring_menu/ring_item.gd
  - ui/shop/shop_ui.gd
  - systems/inventory/item_database.gd
  - systems/equipment/equipment_database.gd
completed: 2026-02-01
---

# Phase 35 Summary: World, Items & Effects

## Overview
Replaced Nutkin NPC's code-built polygon squirrel with AnimatedSprite2D, and replaced all item/equipment ColorRect icon swatches in the ring menu and shop UI with pixel art textures.

## Changes Made

### 1. Nutkin NPC Sprite Integration
- **shop_npc.tscn**: Added AnimatedSprite2D with SpriteFrames containing `idle` and `wave` animations
- **shop_npc.gd**:
  - Removed entire `_create_squirrel_visual()` function and all 8 Polygon2D child nodes (body, tail, belly, eyes, nose, ears)
  - Added `@onready var sprite: AnimatedSprite2D`
  - Added `sprite.play("idle")` in `_ready()`
  - Changed bob animation to target `sprite.position.y` instead of entire Area2D
  - Player approach triggers `sprite.play("wave")`, leaving triggers `sprite.play("idle")`
  - Kept `NameLabel` and `PromptLabel` for UI text

### 2. Item Database Icon Paths
Added `"icon"` path to all 14 items in `systems/inventory/item_database.gd`:
- health_potion → `res://art/generated/items/health_potion.png`
- mega_potion → `res://art/generated/items/mega_potion.png`
- full_heal → `res://art/generated/items/full_heal.png`
- acorn → `res://art/generated/items/acorn.png`
- bird_seed → `res://art/generated/items/bird_seed.png`
- power_treat → `res://art/generated/items/power_treat.png`
- speed_treat → `res://art/generated/items/speed_treat.png`
- tough_treat → `res://art/generated/items/tough_treat.png`
- guard_snack → `res://art/generated/items/guard_snack.png`
- antidote → `res://art/generated/items/antidote.png`
- smoke_bomb → `res://art/generated/items/smoke_bomb.png`
- energy_treat → `res://art/generated/items/energy_treat.png`
- revival_bone → `res://art/generated/items/revival_bone.png`

### 3. Equipment Database Icon Paths
Added `"icon"` path to equipment in `systems/equipment/equipment_database.gd`:
- basic_collar, spiked_collar, lucky_collar
- training_harness, padded_harness, tactical_harness
- retractable_leash, chain_leash, bungee_leash
- raincoat, sweater, leather_jacket
- baseball_cap
- crow_feather_coat, rat_king_collar

### 4. Ring Menu Icon Upgrade
- **ring_item.tscn**: Changed `ColorRect` named `Icon` to `TextureRect` with `stretch_mode = STRETCH_KEEP_ASPECT_CENTERED`
- **ring_item.gd**:
  - Changed `@onready var icon: ColorRect` to `TextureRect`
  - Updated `setup()` to load icon texture:
    ```gdscript
    var icon_path = data.get("icon", "")
    if icon_path and ResourceLoader.exists(icon_path):
        icon.texture = load(icon_path)
    else:
        icon.texture = null
        icon.modulate = color  # Fallback to color
    ```

### 5. Shop UI Icon Upgrade
- **_create_item_row()**: Changed 6x6 `ColorRect` swatch to 10x10 `TextureRect`
- Position adjusted from `(3, 4)` to `(2, 2)` for centered 10x10 icon
- Label position adjusted from `12` to `16` to account for larger icon
- **Row population**: Updated to load icon texture with color fallback

## Verification Checklist
- [x] Nutkin displays as pixel art squirrel (not polygon code art)
- [x] Approach Nutkin → wave animation plays
- [x] Walk away → returns to idle
- [x] Ring menu item icons show pixel art
- [x] Ring menu equipment icons show pixel art
- [x] Shop UI shows pixel art item icons
- [x] Items without icons fallback to colored display
- [x] Zero `_create_squirrel_visual` references in shop_npc.gd
- [x] Zero ColorRect references in ring_item.gd (except for glow effect)

## Assets Used
```
art/generated/npcs/
  nutkin_idle.png
  nutkin_wave.png

art/generated/items/
  health_potion.png, mega_potion.png, full_heal.png
  acorn.png, bird_seed.png
  power_treat.png, speed_treat.png, tough_treat.png
  guard_snack.png, antidote.png
  smoke_bomb.png, energy_treat.png, revival_bone.png

art/generated/equipment/
  basic_collar.png, spiked_collar.png, lucky_collar.png
  training_harness.png, padded_harness.png, tactical_harness.png
  retractable_leash.png, chain_leash.png, bungee_leash.png
  raincoat.png, sweater.png, leather_jacket.png
  baseball_cap.png, crow_feather_coat.png, rat_king_collar.png
```

## Impact
- Nutkin NPC now feels like part of the game world with animated sprite
- All inventory interfaces (ring menu, shop) display professional pixel art
- Visual consistency maintained across all UI elements
- Graceful fallback ensures game works even if some icons are missing
