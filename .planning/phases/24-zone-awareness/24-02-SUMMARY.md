---
phase: 24-zone-awareness
plan: 02
status: complete
date: 2026-01-28
duration: ~15 min
subsystem: autoloads/auto_bot.gd
affects: [25-01, 25-02]

tech-stack:
  existing: [GDScript, Area2D hazards, CanvasModulate, corridor_segments]
  added: []

files:
  modified:
    - autoloads/auto_bot.gd
  created: []

key-decisions:
  - decision: "Scan Hazards container children rather than groups"
    rationale: "ToxicPuddle nodes aren't in a group — they're children of zone's Hazards Node2D"
  - decision: "Inverse distance weighting for hazard repulsion"
    rationale: "Closer hazards push harder, far hazards are gentle nudges"
  - decision: "Corridor centers as patrol points"
    rationale: "8 corridor + 4 room centers = 12 points all within walkable Rect2 space"
  - decision: "85% hunt chance in dark zones vs 70% normal"
    rationale: "Dark environments are dangerous — bot should be proactive, not passive"

key-exports:
  - name: _update_hazard_awareness()
    type: function
    location: autoloads/auto_bot.gd
  - name: _generate_corridor_patrol_points()
    type: function
    location: autoloads/auto_bot.gd
  - name: nearby_hazards
    type: Array[Node]
    location: autoloads/auto_bot.gd
  - name: hazard_avoidance_vector
    type: Vector2
    location: autoloads/auto_bot.gd
  - name: is_in_dark_zone
    type: bool
    location: autoloads/auto_bot.gd

patterns:
  - "Zone Hazards container scanning for environmental awareness"
  - "Corridor segment center-point patrol generation"
  - "Dark zone behavioral adjustments (aggression, focus, speed)"
---

## Summary

Added ToxicPuddle hazard avoidance and sewers-specific corridor navigation to the AutoBot. Bot now steers away from toxic puddles, patrols corridor centers in the sewers instead of grid points (which would be inside walls), and behaves more aggressively in dark zones.

## What Changed

### 1. Hazard Detection (`_update_hazard_awareness()`)
- Scans zone's `Hazards` container for ToxicPuddle Area2D nodes
- Computes inverse-distance-weighted repulsion vector from nearby hazards
- Detection range: 120px, avoidance strength: 0.8
- Poisoned state amplifies avoidance by 1.5x (reactive learning)
- Detects darkness zones via CanvasModulate "Darkness" node presence

### 2. Hazard Avoidance Integration
- `_apply_boundary_avoidance()` applies hazard steering after boundary push
- `_pick_wander_direction()` blends hazard avoidance into patrol navigation
- Both combat and patrol movement avoid toxic puddles

### 3. Corridor-Aware Patrol (`_generate_corridor_patrol_points()`)
- Detects corridor-based zones via `"corridor_segments" in current_zone_ref`
- Generates points at center of each corridor segment (8 points)
- Also samples side room centers (4 points) for exploration
- Total: 12 walkable patrol points, none inside walls
- Open zones still use proportional grid from Plan 24-01

### 4. Dark Zone Behavior
- Hunt chance: 85% in dark zones vs 70% normal (more proactive)
- Aim variance: 0.1 in dark vs 0.2 normal (more focused)
- Run chance: 90% in dark zones (dangerous environment)
- Wander duration: 60% of normal (shorter patrol legs, stay alert)

## Verification
- `_update_hazard_awareness` and `_generate_corridor_patrol_points` functions exist
- `hazard_avoidance_vector`, `nearby_hazards`, `is_in_dark_zone` state vars present
- `HAZARD_DETECTION_RANGE`, `HAZARD_AVOIDANCE_STRENGTH` constants present
- `corridor_segments` referenced in corridor detection
- `is_in_dark_zone` used in wander and hunt behavior
