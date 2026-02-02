# Performance Baseline

## Objective
Capture a baseline for frame time, memory, and load time before optimization work.

## Baseline Metrics (To Capture)
- Target FPS: 60
- Frame time (ms): TBD
- Memory (MB): TBD
- Load time to main scene (s): TBD

## Recommended Baseline Procedure
1) Run the game in editor and measure average FPS in a busy combat scene.
2) Use Godot profiler to capture spikes during:
   - Combat with multiple enemies
   - UI heavy interactions (pause menu, ring menu)
3) Capture load time for `ui/menus/title_screen.tscn` to gameplay scene.

## Known Hot Path Candidates
- `get_nodes_in_group("enemies")` in per-frame loops
- UI updates in `_process` for HUD elements
- AutoBot scans over enemies and companions every frame

## Notes
This file should be updated with concrete measurements after CR-2 and CR-3 changes.
