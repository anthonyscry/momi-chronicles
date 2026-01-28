# Plan 05: Test Zone & Camera

## Metadata
```yaml
phase: 01-foundation
plan: 05
wave: 3
depends_on: ["03"]
files_modified: 2
autonomous: true
must_haves:
  truths:
    - "Test zone loads and displays"
    - "Player spawns in test zone"
    - "Camera follows player smoothly"
    - "Camera stays within zone boundaries"
  artifacts:
    - path: "world/zones/test_zone.tscn"
      provides: "Test zone for development"
      min_lines: 30
    - path: "world/zones/test_zone.gd"
      provides: "Zone script with camera limits"
      min_lines: 15
  key_links:
    - from: "test_zone.tscn"
      to: "player.tscn"
      via: "scene instance"
    - from: "test_zone.gd"
      to: "player.set_camera_limits"
      via: "function call on ready"
```

## Objective
Create test zone scene for development and verify camera follows player.

## Tasks

<task type="auto">
  <name>Task 1: Create test zone script</name>
  <files>world/zones/test_zone.gd</files>
  <action>
    Create test_zone.gd:
    - extends Node2D
    - @export var zone_size: Vector2 = Vector2(640, 360)
    - @onready var player: Player = $Player
    - func _ready():
      - Set camera limits based on zone_size
      - player.set_camera_limits(Rect2(Vector2.ZERO, zone_size))
      - Events.zone_entered.emit("test_zone")
  </action>
  <verify>Script sets camera limits on ready</verify>
  <done>Zone script with camera limit setup</done>
</task>

<task type="auto">
  <name>Task 2: Create test zone scene</name>
  <files>world/zones/test_zone.tscn</files>
  <action>
    Create test_zone.tscn with:
    - TestZone (Node2D with test_zone.gd)
      - Background (ColorRect, size 640x360, dark green color for ground)
      - Boundaries (StaticBody2D)
        - Top (CollisionShape2D, WorldBoundaryShape2D or RectangleShape2D)
        - Bottom (CollisionShape2D)
        - Left (CollisionShape2D)
        - Right (CollisionShape2D)
      - Player (instance of player.tscn, position 320, 180)
    Set as main scene in project.godot
  </action>
  <verify>Scene loads, player visible, boundaries prevent exit</verify>
  <done>Test zone with player spawn and boundaries</done>
</task>

## Success Criteria
- [ ] F5 in Godot runs test_zone.tscn
- [ ] Player visible in center of zone
- [ ] Camera follows player movement
- [ ] Player cannot leave zone boundaries
