# Roof Rat Sprites - Placeholder Reference

This document describes the required sprite sheets for the Roof Rat enemy.
All sprites should be 32x32 canvas with 16x16 centered pixel art.

## Required Sprite Sheets

1. **roof_rat_wall_idle.png** (4 frames, 0.3s each)
   - Flattened profile against wall surface
   - Subtle breathing animation
   - Semi-transparent overlay ready (for stealth effect)

2. **roof_rat_wall_run.png** (6 frames, 0.12s each)
   - Profile view running along vertical surface
   - Legs moving in running cycle
   - Body slightly angled along surface

3. **roof_rat_ambush.png** (4 frames, 0.1s each)
   - Frame 0: Squashed pre-drop pose
   - Frame 1-2: Dropping down with stretched body
   - Frame 3: Landing/crouch pose

4. **roof_rat_retreat.png** (4 frames, 0.15s each)
   - Climbing upward scramble animation
   - Legs reaching up
   - Body stretched vertically

5. **roof_rat_hurt.png** (3 frames, 0.15s each)
   - Recoil pose
   - Flash white
   - Return to neutral

6. **roof_rat_death.png** (4 frames, 0.2s each)
   - Falling down animation
   - Fade out effect

## Style Guidelines

- 16x16 actual sprite, 32x32 canvas with centering
- Brown/gray fur with lighter underbelly
- Pink nose, dark eyes
- Pointed ears visible in profile
- Long tail trailing behind
- Nearest-neighbor scaling for pixel-perfect rendering
