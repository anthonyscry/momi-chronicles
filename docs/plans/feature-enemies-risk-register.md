# Feature Enemies Risk Register

## Summary
This register tracks key risks for the enemies feature implementation.

| ID | Risk | Impact | Likelihood | Mitigation | Owner | Status |
|----|------|--------|------------|------------|-------|--------|
| R1 | DamageEvent class missing or incompatible with projectile damage usage | Bomb damage fails or errors at runtime | Medium | Search for DamageEvent definition and align gnome bomb damage with existing damage pipeline | Eng | Open |
| R2 | Rooftop spawner entry point not found or differs from plan | Integration delay or incorrect spawn placement | Medium | Locate actual spawn logic in world scenes and update plan with discovered file path before code | Eng | Open |
| R3 | Events.gd contains merge artifacts or duplicate signals | Signal conflicts or runtime warnings | Low | Clean up duplicates in Events.gd when touching signals and run basic scene load | Eng | Open |
| R4 | Collision layer or mask mismatch for bomb/hitboxes | Player not taking damage or hitboxes failing | Medium | Verify layers in project.godot and validate hitbox/hurtbox masks in scene | Eng | Open |
| R5 | SpriteFrames not configured or assets missing | Enemy appears invisible or idle only | Medium | Add sprite sheets early and validate animations in gnome.tscn | Art/Eng | Open |
| R6 | Bomb explosion effects cause performance drops with multiple gnomes | Frame drops in rooftop encounters | Low | Keep explosion VFX lightweight and cap spawn count in encounters | Eng | Open |

## Validation Steps
- Load rooftop scene and watch for errors in Output panel
- Spawn a gnome test scene to validate hitbox, hurtbox, and projectile behavior
- Confirm events emit and are received without warnings

## Review Cadence
- Revisit after EN-1 discovery and after EN-5 projectile implementation
