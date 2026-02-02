# Plan 01: Project Configuration

## Metadata
```yaml
phase: 01-foundation
plan: 01
wave: 1
depends_on: []
files_modified: 1
autonomous: true
must_haves:
  truths:
    - "Project opens in Godot 4.5 without errors"
    - "Pixel art renders without blur at any window size"
    - "All input actions are defined and testable"
    - "Autoloads are registered and accessible"
  artifacts:
    - path: "project.godot"
      provides: "Project configuration"
      min_lines: 80
  key_links:
    - from: "project.godot"
      to: "autoloads/events.gd"
      via: "autoload registration"
    - from: "project.godot"
      to: "autoloads/game_manager.gd"
      via: "autoload registration"
```

## Objective
Configure project.godot with pixel art settings, input actions, and autoload registrations.

## Tasks

<task type="auto">
  <name>Task 1: Create project.godot with all settings</name>
  <files>project.godot</files>
  <action>
    Create project.godot with:
    - config_version=5 for Godot 4.x
    - project name "Momi's Adventure"
    - Viewport: 384x216
    - Window override: 1152x648 (3x)
    - Stretch mode: viewport
    - Stretch aspect: keep
    - Default texture filter: 0 (Nearest)
    - Physics FPS: 60
    - Input actions: move_up (W, Up), move_down (S, Down), move_left (A, Left), move_right (D, Right), run (Shift), attack (Space, Z), dodge (X), interact (E), pause (Escape)
    - Autoload: Events, GameManager
    - Collision layer names
  </action>
  <verify>File exists and contains all required sections</verify>
  <done>
    - project.godot exists with correct format
    - Viewport is 384x216
    - Texture filter is Nearest
    - All 9 input actions defined
    - Both autoloads registered
  </done>
</task>

## Success Criteria
- [ ] Project can be opened in Godot 4.5
- [ ] Window displays at 1152x648
- [ ] Input actions appear in Project Settings > Input Map
- [ ] Autoloads listed in Project Settings > Autoload
