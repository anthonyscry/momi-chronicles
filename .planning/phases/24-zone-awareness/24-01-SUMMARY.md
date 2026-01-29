---
phase: 24-zone-awareness
plan: 01
status: complete
date: 2026-01-28
duration: ~15 min
subsystem: autoloads/auto_bot.gd
affects: [24-02]

tech-stack:
  existing: [GDScript, BaseZone class_name, Camera2D limits]
  added: []

files:
  modified:
    - autoloads/auto_bot.gd
  created: []

key-decisions:
  - decision: "Walk ancestor tree to find BaseZone"
    rationale: "Player is always a child of the zone scene — reliable detection"
  - decision: "Camera limits as fallback"
    rationale: "If BaseZone not found (e.g. test scene), camera limits still give correct bounds"
  - decision: "3x2 grid + center for patrol points"
    rationale: "7 proportional points cover any zone shape without zone-specific hardcoding"

key-exports:
  - name: current_zone_size
    type: Vector2
    location: autoloads/auto_bot.gd
  - name: current_zone_ref
    type: Node
    location: autoloads/auto_bot.gd
  - name: _generate_patrol_points()
    type: function
    location: autoloads/auto_bot.gd
  - name: _update_zone_awareness()
    type: function
    location: autoloads/auto_bot.gd

patterns:
  - "BaseZone ancestor walk for zone detection"
  - "Camera limit fallback for edge cases"
  - "Proportional grid-based patrol generation"
---

## Summary

Replaced hardcoded 800x600 `ZONE_SIZE` constant with dynamic zone boundary detection that reads `BaseZone.zone_size` from the player's ancestor tree. Bot now automatically adapts to any zone dimensions.

## What Changed

### 1. Dynamic Zone Detection (`_update_zone_awareness()`)
- Walks player's ancestor tree to find BaseZone node
- Caches `current_zone_ref` and `current_zone_size` 
- Only re-detects when zone ref is lost (zone transitions)
- Fallback chain: BaseZone → Camera2D limits → DEFAULT_ZONE_SIZE (800x600)
- Resets detection flag on player reference change

### 2. Dynamic Boundary Avoidance
- `_apply_boundary_avoidance()` now uses `current_zone_size` instead of hardcoded `ZONE_SIZE`
- Works correctly in all zones: Neighborhood (800x600), Backyard (384x216), Sewers (1152x648)

### 3. Proportional Patrol Points (`_generate_patrol_points()`)
- Replaced 6 hardcoded Neighborhood-specific coordinates with dynamic generation
- Generates 7 points (3x2 grid + center) proportional to `current_zone_size`
- Points stay `ZONE_PADDING * 2` inside boundaries
- Adapts automatically to any zone dimensions

## Verification
- No bare `ZONE_SIZE` references remain (only `DEFAULT_ZONE_SIZE`)
- `current_zone_size` used in state, detection, boundary avoidance
- No hardcoded patrol coordinates remain
- `_generate_patrol_points()` and `_update_zone_awareness()` functions exist
