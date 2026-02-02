# Test Enemy - Difficulty Integration Demo

## Purpose
Simple proof-of-concept enemy demonstrating the difficulty system integration.

## Features
- **Basic Health**: 50 HP with visual health display
- **Difficulty-Scaled Damage**: Base 10 damage, modified by difficulty multiplier
  - Story Mode: 5 damage (0.5x)
  - Normal: 10 damage (1.0x)
  - Challenge: 15 damage (1.5x)
- **Difficulty-Scaled Attack Speed**: 2s base cooldown, modified by AI aggression
  - Story Mode: ~2.86s (slower, 1/0.7)
  - Normal: 2.0s
  - Challenge: ~1.54s (faster, 1/1.3)
- **Difficulty-Scaled Drops**: 50% base drop chance, modified by drop multiplier
  - Story Mode: ~100% chance (2.0x)
  - Normal: 50% chance (1.0x)
  - Challenge: 25% chance (0.5x)

## How to Test

### Manual Verification
1. Create a test scene or open an existing game scene
2. Instance `tests/test_enemy.tscn`
3. Add a player to the scene (must be in "player" group)
4. Run the scene
5. Change difficulty via pause menu (ESC key)
6. Observe the console output for damage values
7. Let the enemy die and check drop behavior

### Expected Behavior
- Enemy appears as a red square (32x32)
- Health label shows "HP: 50/50" above enemy
- When near player (< 64 pixels), attacks every 2 seconds (modified by difficulty)
- Console shows: "TestEnemy dealt X damage (base: 10.0, multiplier: Y)"
- When killed, may drop gold loot (yellow square) based on difficulty
- Console shows drop result and multipliers

### Visual Feedback
- **Attack**: Enemy flashes yellow briefly
- **Damage**: Enemy flashes white briefly
- **Loot**: Gold square fades out over 2 seconds

## Garden Gnome Test Scene

Use the dedicated gnome test scene for manual behavior verification.

### Manual Verification
1. Open `tests/test_gnome.tscn`
2. Run the scene (F6)
3. Move the player within range of the gnome
4. Confirm telegraph "!" pulse, bomb arc, and explosion timing
5. Confirm damage is applied when within the AOE radius

## Integration Points
- Uses `EnemyDifficultyModifier` component
- Reads multipliers via `difficulty_modifier.get_damage_multiplier()`, etc.
- Applies damage via `difficulty_modifier.apply_damage(base_damage)`
- Checks drops via `difficulty_modifier.should_drop(base_drop_chance)`
- Modifies attack cooldown via `difficulty_modifier.get_ai_cooldown(base_cooldown)`

## Console Output Example
```
TestEnemy spawned with modifiers - Damage: 0.50x, Drops: 2.00x, AI: 0.70x
TestEnemy dealt 5.0 damage (base: 10.0, multiplier: 0.50x)
TestEnemy defeated!
  - Loot dropped! (chance: 50.0%, multiplier: 2.00x)
```

## Notes
- This is a minimal proof-of-concept, not a production enemy
- No proper AI pathfinding or state machine
- Visual representation is simple colored squares
- Collision uses basic polygon shape
