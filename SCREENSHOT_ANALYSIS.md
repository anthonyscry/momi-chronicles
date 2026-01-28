# Momi's Adventure - Screenshot Analysis Report

Based on analysis of 15 gameplay screenshots, here are actionable improvements organized by priority.

---

## CRITICAL ISSUES (Fix First)

### 1. Debug HUD Blocks Gameplay
**Problem:** Green debug text covers ~20% of screen, obscures enemies and gameplay
**Evidence:** All screenshots show large text block in top-left
**Fix:**
```gdscript
# In game_hud.gd or auto_bot.gd
# Toggle debug info with a key (not always visible)
# Or move to bottom-right corner
# Or make semi-transparent when not hovered
```

### 2. Poor Text Contrast
**Problem:** Green text on green grass is nearly unreadable
**Evidence:** Screenshots show HUD text blending into background
**Fix:**
- Add dark semi-transparent background behind text
- Use outline/shadow on text
- Consider different color scheme (white text, dark background)

### 3. Player Character Not Distinct
**Problem:** Hard to identify which sprite is the player vs enemies
**Evidence:** Multiple similar-looking squares on screen
**Fix:**
- Give Momi a distinct color (not used by enemies)
- Add a subtle glow or outline around player
- Make player sprite slightly larger
- Add idle animation to draw eye

---

## HIGH PRIORITY (Gameplay Impact)

### 4. No Health Pickups Visible
**Problem:** Player health drains with no way to recover
**Evidence:** Health drops from 100 to 0 across screenshots, no pickups seen
**Fix:**
- Add health pickup drops from defeated enemies (20-30% chance)
- Place static health pickups around the map
- Add healing over time when out of combat

### 5. Game Over Screen Missing Stats
**Problem:** No feedback on performance when dying
**Evidence:** Game Over only shows "Retry" and "Quit"
**Fix:**
- Show enemies defeated count
- Show time survived
- Show damage dealt
- Add "Main Menu" button
- Hide debug HUD on game over

### 6. No Visual Attack Feedback
**Problem:** Can't tell when attacks connect or miss
**Evidence:** No hit sparks, screen shake, or impact effects visible
**Fix:**
- Add hit flash on damaged enemies
- Add screen shake on player hit
- Add particle effects for attacks
- Add brief invincibility frames visual (flash/transparency)

### 7. Enemy Health Not Visible
**Problem:** Can't tell how much damage enemies have taken
**Evidence:** No health bars over enemies
**Fix:**
- Add small health bar above each enemy
- Or show health bar only when enemy is damaged
- Or use color change (red->orange->yellow as health drops)

---

## MEDIUM PRIORITY (Polish)

### 8. Inconsistent Pixel Art Scale
**Problem:** Different sprites have different "pixel sizes"
**Evidence:** House windows vs player vs trees have different resolutions
**Fix:**
- Establish consistent pixel size (e.g., 16x16 or 32x32 base)
- Redraw assets at same scale
- Use nearest-neighbor scaling only

### 9. Flat World - No Depth
**Problem:** Everything looks 2D flat, no sense of depth
**Evidence:** No shadows under any objects
**Fix:**
- Add drop shadows under all characters and objects
- Add slight darkening at building bases
- Consider subtle parallax for decoration layers

### 10. Empty Open Spaces
**Problem:** Large grass areas with nothing in them
**Evidence:** Screenshots show big empty green zones
**Fix:**
- Add grass tufts, flowers, rocks as decoration
- Add more benches, lamp posts, mailboxes
- Add subtle ground texture variation

### 11. Chokepoint Danger
**Problem:** Player can get trapped between buildings
**Evidence:** Narrow alleys between houses
**Fix:**
- Widen gaps between buildings
- Or add escape routes (jumpable fences?)
- Ensure enemy AI doesn't corner player unfairly

---

## LOW PRIORITY (Nice to Have)

### 12. Color Palette Too Saturated
**Problem:** Colors are very bright/basic "programmer art" look
**Fix:**
- Use a curated color palette (e.g., from Lospec)
- Reduce saturation slightly
- Add complementary accent colors

### 13. No Minimap
**Problem:** Hard to know where enemies are across the zone
**Fix:**
- Add small minimap in corner showing enemy dots
- Or add enemy direction indicators at screen edge

### 14. Buildings Cut Off at Edges
**Problem:** Houses placed at screen edge look incomplete
**Fix:**
- Add margin/padding to playable area
- Or let camera scroll slightly

---

## AUTOBOT-SPECIFIC OBSERVATIONS

### Bot Behavior Analysis from Screenshots:

| State | Frequency | Notes |
|-------|-----------|-------|
| HUNTING | Very Common | Works well, finds enemies |
| ATTACKING | Common | Engages properly |
| KITING | Common | Good defensive behavior |
| RETREATING | Occasional | Triggers at low health |
| CLOSING | Occasional | Approach phase works |
| HESITATING | Rare | Human-like, good |
| LAST_STAND | Not seen | May need tuning |

### Bot Improvement Ideas:
1. **Prioritize weak enemies** - Focus on almost-dead enemies first
2. **Avoid corners** - Bot sometimes gets trapped near buildings
3. **Use special attacks more** - Saw mostly regular attacks
4. **Seek health pickups** - When they exist, bot should find them

---

## QUICK WINS (Easy Fixes)

1. **Add text background** - 10 min fix, huge readability improvement
2. **Hide debug on Game Over** - Simple visibility toggle
3. **Player outline/glow** - Shader or simple sprite edit
4. **Enemy health bars** - Reuse player health bar component
5. **Screen shake on hit** - Few lines of code

---

## METRICS FROM TEST RUNS

| Metric | Value | Target |
|--------|-------|--------|
| Avg enemies killed | 7/10 | 10/10 |
| Avg survival time | 45 sec | 90+ sec |
| Bot kill rate | ~9 per min | - |
| Common death cause | Overwhelmed at low HP | - |

---

## RECOMMENDED PRIORITY ORDER

1. Fix HUD contrast (text background)
2. Add player distinction (glow/outline)
3. Add health pickups
4. Add enemy health bars
5. Add hit feedback effects
6. Improve Game Over screen
7. Polish pixel art consistency
8. Add environmental details

---

*Generated from screenshot analysis on Jan 27, 2026*
