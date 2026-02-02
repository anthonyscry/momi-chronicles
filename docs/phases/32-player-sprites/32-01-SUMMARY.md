---
phase: 32-player-sprites
plan: 01
status: complete
started: 2026-02-01
completed: 2026-02-01
subsystem: characters/player
affects: [33-companion-sprites, 34-enemy-boss-sprites]

tech-stack:
  added: []
  patterns:
    - "AnimatedSprite2D with SpriteFrames for character visuals"
    - "sprite.play('state_name') in state enter() for animation switching"
    - "flip_h for horizontal facing instead of scale.x = -1"
    - "modulate for color effects instead of .color (AnimatedSprite2D has no .color)"
    - "Sprite2D with frame texture for afterimage ghosts"

key-files:
  modified:
    - characters/player/player.tscn
    - characters/player/player.gd
    - characters/player/states/player_idle.gd
    - characters/player/states/player_walk.gd
    - characters/player/states/player_run.gd
    - characters/player/states/player_attack.gd
    - characters/player/states/player_combo_attack.gd
    - characters/player/states/player_charge_attack.gd
    - characters/player/states/player_special_attack.gd
    - characters/player/states/player_ground_pound.gd
    - characters/player/states/player_dodge.gd
    - characters/player/states/player_block.gd
    - characters/player/states/player_hurt.gd
    - characters/player/states/player_death.gd
    - autoloads/effects_manager.gd

decisions:
  - decision: "Sprite mapping for states without dedicated sprites"
    choice: "chomp=attack/combo, bark=charge/special, dig=ground_pound, run=dodge, idle=block"
    rationale: "9 unique PNGs cover 13 animations via semantic mapping (dog chomps to attack, digs for ground pound, etc.)"
  - decision: "flip_h instead of scale.x for facing"
    choice: "flip_h = facing_left"
    rationale: "Decouples facing from scale effects used by combo/charge/special states"
  - decision: "Dodge afterimage uses Sprite2D with frame texture"
    choice: "sprite_frames.get_frame_texture() into Sprite2D ghost"
    rationale: "Polygon2D ghost no longer valid; Sprite2D shows actual sprite frame"
---

## Summary

Replaced Momi's Polygon2D placeholder with AnimatedSprite2D using generated pixel art. Wired all 12 state machine states to play correct animations on enter().

## What Changed

### player.tscn
- Removed `GlowOutline` (Polygon2D) and `Sprite2D` (Polygon2D) nodes
- Added `Sprite2D` node as `AnimatedSprite2D` with `SpriteFrames` containing 13 animations
- 9 ext_resource textures: momi_idle, momi_walk, momi_run, momi_chomp, momi_bark, momi_dig, momi_hurt, momi_death, momi_happy
- Each animation: 1 frame, FPS=1, no loop (static poses that swap on state change)

### player.gd
- `@onready var sprite: Polygon2D` → `AnimatedSprite2D`
- `sprite.scale.x = -1/1` → `sprite.flip_h = facing_left/false`
- Added `sprite.play("idle")` in `_ready()`

### All 12 state scripts
- Added `player.sprite.play("animation_name")` in every `enter()` function
- Replaced all `sprite.color` references with `sprite.modulate` (dodge, block, death)

### effects_manager.gd
- Dodge afterimage: `Polygon2D` ghost → `Sprite2D` with `sprite_frames.get_frame_texture()` + `flip_h`

## Sprite Animation Map

| Animation | Source PNG | Used By States |
|-----------|-----------|----------------|
| idle | momi_idle | Idle, Block |
| walk | momi_walk | Walk |
| run | momi_run | Run, Dodge |
| attack | momi_chomp | Attack |
| combo_attack | momi_chomp | ComboAttack |
| charge | momi_bark | ChargeAttack |
| special_attack | momi_bark | SpecialAttack |
| ground_pound | momi_dig | GroundPound |
| dodge | momi_run | Dodge |
| block | momi_idle | Block |
| hurt | momi_hurt | Hurt |
| death | momi_death | Death |
| happy | momi_happy | (available for cutscenes) |

## Conversion Pattern (for Phase 33/34)

1. Remove Polygon2D node, add AnimatedSprite2D with SpriteFrames
2. Change script type annotation: `Polygon2D` → `AnimatedSprite2D`
3. Replace `scale.x = -1/1` → `flip_h = true/false`
4. Replace `.color` → `.modulate`
5. Add `sprite.play("name")` in each state's `enter()`
6. Update any afterimage/ghost code that clones Polygon2D
