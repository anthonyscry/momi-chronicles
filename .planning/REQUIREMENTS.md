# Momi's Adventure - v1 Requirements

## Category: Core Movement (MOV)
- **MOV-01**: Player can move in 8 directions using WASD/arrow keys
- **MOV-02**: Player has walk and run speeds (run with Shift held)
- **MOV-03**: Player sprite faces movement direction
- **MOV-04**: Movement feels responsive (no input lag)
- **MOV-05**: Player cannot walk through solid objects

## Category: Combat System (CMB)
- **CMB-01**: Player can perform basic attack with action button
- **CMB-02**: Attacks have hitboxes that detect enemies
- **CMB-03**: Player can dodge/roll with dodge button
- **CMB-04**: Dodge has invincibility frames
- **CMB-05**: Attack has recovery time before next action
- **CMB-06**: Visual feedback on hit (flash, particles)

## Category: Health & Damage (HLT)
- **HLT-01**: Player has health points (HP)
- **HLT-02**: Taking damage reduces HP
- **HLT-03**: HP reaching 0 triggers death state
- **HLT-04**: Invincibility frames after taking damage
- **HLT-05**: Health displays in UI

## Category: Enemies (ENM)
- **ENM-01**: Basic enemy type exists (raccoon)
- **ENM-02**: Enemies have health and can be defeated
- **ENM-03**: Enemies deal contact damage
- **ENM-04**: Enemies have basic AI (patrol, chase, attack)
- **ENM-05**: Defeated enemies play death animation
- **ENM-06**: At least 2 enemy types with different behaviors

## Category: Camera (CAM)
- **CAM-01**: Camera follows player smoothly
- **CAM-02**: Camera has position smoothing
- **CAM-03**: Camera respects zone boundaries
- **CAM-04**: No jarring camera movements

## Category: Animation (ANI)
- **ANI-01**: Player has idle animation
- **ANI-02**: Player has walk animation (4 directions)
- **ANI-03**: Player has run animation (4 directions)
- **ANI-04**: Player has attack animation
- **ANI-05**: Player has hurt animation
- **ANI-06**: Player has dodge/roll animation
- **ANI-07**: Enemies have idle, walk, attack, hurt, death animations

## Category: UI/HUD (UI)
- **UI-01**: Health bar displays current/max HP
- **UI-02**: Pause menu accessible with ESC
- **UI-03**: Pause menu has Resume and Quit options
- **UI-04**: Simple title screen
- **UI-05**: Game over screen on death

## Category: World/Zones (WLD)
- **WLD-01**: Test zone exists for development
- **WLD-02**: Zone has collision boundaries
- **WLD-03**: Basic tilemap for ground/walls
- **WLD-04**: Zone transitions work (doors/exits)

## Category: Audio (AUD)
- **AUD-01**: Background music plays
- **AUD-02**: Sound effects for attacks
- **AUD-03**: Sound effects for taking damage
- **AUD-04**: Sound effects for enemy death
- **AUD-05**: Audio can be toggled in settings

## Category: State Management (STA)
- **STA-01**: Player states managed by state machine
- **STA-02**: States: Idle, Walk, Run, Attack, Hurt, Dodge, Death
- **STA-03**: Clean state transitions with no stuck states
- **STA-04**: Game can be paused/unpaused
- **STA-05**: Game state persists during session

## Category: Technical (TEC)
- **TEC-01**: Consistent 60 FPS performance
- **TEC-02**: No memory leaks during gameplay
- **TEC-03**: Pixel-perfect rendering (no blur)
- **TEC-04**: Input actions configurable
- **TEC-05**: Game runs on Windows
