# Art Generation Workflow for Momi's Adventure

**Version:** 1.0
**Date:** 2026-02-01
**Purpose:** Document the complete workflow for generating, processing, and integrating sprites using the Gemini API pipeline

---

## Overview

This document describes the end-to-end process for creating polished pixel art sprites for Momi's Adventure using AI generation (Gemini API) combined with post-processing tools to ensure visual consistency and quality.

**Related Documents:**
- [VISUAL_STANDARDS.md](../.auto-claude/specs/005-visual-polish-sprite-consistency/VISUAL_STANDARDS.md) - Pixel scale and aesthetic requirements
- [SPRITE_QA_CHECKLIST.md](../.auto-claude/specs/005-visual-polish-sprite-consistency/SPRITE_QA_CHECKLIST.md) - Quality assurance checklist

---

## Quick Reference: Pixel Scale Standards

| Asset Type | Size | Examples |
|-----------|------|----------|
| Environment Tiles | 16x16 | Grass, walls, props |
| Items/Equipment | 16x16 | Potions, collars, hats |
| Regular Enemies | 24x24 | Crow, Raccoon, Rat, Cat |
| Player/Companions | 32x32 | Momi, Cinnamon, Philo |
| Mini-Bosses | 36-40px | Alpha Raccoon, Crow Matriarch |
| Major Bosses | 48x48 | Rat King, Raccoon King |

**CRITICAL:** All sprites must match these exact dimensions. See VISUAL_STANDARDS.md for detailed requirements.

---

## Workflow Stages

### Stage 1: Pre-Generation Planning
**Before generating any sprites:**

1. **Review Audit Documents**
   - Check which sprites are missing/need regeneration
   - Understand visual requirements (color, silhouette, distinctiveness)
   - Identify priority order (high → medium → low)

2. **Review Visual Standards**
   - Confirm pixel scale target (16x16 / 24x24 / 32x32 / 48x48)
   - Review color palette constraints (friendly vs hostile)
   - Check aesthetic requirements (Earthbound-meets-Ghibli)

3. **Prepare Generation Prompts**
   - Use prompt templates from VISUAL_STANDARDS.md
   - Customize for specific sprite (character/enemy/item)
   - Include all required details (size, style, color, perspective)

4. **Set Up Directory Structure**
   ```bash
   # Ensure directories exist
   mkdir -p art/generated/characters
   mkdir -p art/generated/enemies
   mkdir -p art/generated/bosses
   mkdir -p art/generated/items
   mkdir -p art/generated/equipment
   mkdir -p art/generated/tiles
   ```

---

### Stage 2: AI Sprite Generation (Gemini API)

**Tool:** `tools/gemini_api_generate.py`

#### Generation Parameters

**For Characters (32x32):**
```bash
python tools/gemini_api_generate.py \
  --prompt "32x32 pixel art of Momi the French Bulldog in idle stance. Tan/golden fur (#D9B373), stocky build, friendly expressive eyes. SNES 16-bit style, Earthbound-meets-Ghibli aesthetic. Top-down 3/4 view, upright heroic pose. 1px black outline, transparent background, lighting from top-left." \
  --output art/generated/characters/momi_idle.png \
  --size 64x64
```

**Generation Strategy:**
- Generate at **2x target size** (e.g., 64x64 for 32x32 sprites) for better quality
- Downscale during post-processing for crisp pixels
- Generate multiple candidates, pick best quality

**For Enemies (24x24):**
```bash
python tools/gemini_api_generate.py \
  --prompt "24x24 pixel art of hostile raccoon enemy with trash can lid shield. Dirty gray fur, black bandit mask, yellow glowing eyes, hunched aggressive posture. SNES 16-bit style, desaturated cool colors. MUST look threatening, NOT friendly. 1px black outline, transparent background. Distinct from player character (avoid warm tan/brown tones)." \
  --output art/generated/enemies/raccoon_idle.png \
  --size 48x48
```

**For Items (16x16):**
```bash
python tools/gemini_api_generate.py \
  --prompt "16x16 pixel art icon of a red health potion. SNES RPG item icon style, simple bottle shape with cork stopper. Bright red liquid (#FF4D4D) in clear glass container. 1px black outline, transparent background. Top-down 3/4 view, maximum clarity. Limit to 3-4 colors for readability." \
  --output art/generated/items/health_potion.png \
  --size 32x32
```

**For Environment Tiles (16x16):**
```bash
python tools/gemini_api_generate.py \
  --prompt "16x16 pixel art tile of vibrant green grass for suburban neighborhood. SNES 16-bit style, bright and cheerful. Top-down 3/4 view, edges must tile seamlessly. Color: #61885F. Clean pixel art, transparent background." \
  --output art/generated/tiles/grass_01.png \
  --size 32x32
```

#### Prompt Best Practices

**Required Elements:**
- ✅ Pixel dimensions (16x16 / 24x24 / 32x32 / 48x48)
- ✅ Art style (SNES 16-bit, Earthbound-meets-Ghibli)
- ✅ Perspective (top-down 3/4 view)
- ✅ Color specifications (hex codes or color names)
- ✅ Outline requirement (1px black)
- ✅ Background (transparent)
- ✅ Lighting direction (top-left)

**Character-Specific:**
- Species and appearance (French Bulldog, tan fur, etc.)
- Posture (upright heroic vs hunched hostile)
- Eye design (friendly expressive vs glowing hostile)
- Accessories or special features

**Enemy-Specific:**
- MUST specify hostile/threatening appearance
- MUST contrast with player palette (cool vs warm tones)
- Include distinctive features (weapons, corruption, etc.)
- Emphasize size difference (smaller than player for regular enemies)

**Item-Specific:**
- Simple iconic shape (bottle, bone, collar, etc.)
- Color coding (red = health, orange = power, etc.)
- Readable at small scale (limit details)
- Category visual language (see VISUAL_STANDARDS.md)

**Tile-Specific:**
- Zone aesthetic (suburban / nature / dungeon)
- Tileable (for ground/wall tiles) or standalone (for props)
- Color palette matching zone theme

---

### Stage 3: Post-Processing

**Tool:** `art/rip_sprites.py`

#### Background Removal & Transparency

After AI generation, all sprites must be processed to ensure clean transparent backgrounds:

```bash
# Process character sprites
python art/rip_sprites.py art/generated/characters/

# Process enemy sprites
python art/rip_sprites.py art/generated/enemies/
python art/rip_sprites.py art/generated/bosses/

# Process item sprites
python art/rip_sprites.py art/generated/items/
python art/rip_sprites.py art/generated/equipment/

# Process tile sprites
python art/rip_sprites.py art/generated/tiles/
```

**What rip_sprites.py does:**
1. Removes background colors (replaces with alpha transparency)
2. Cleans up edge artifacts
3. Generates preview images (*_preview.png) for QA
4. Downscales from generation size (64x64) to target size (32x32)
5. Ensures clean alpha channel edges

#### Manual Downscaling (if needed)

If rip_sprites.py doesn't handle downscaling:

```bash
# Using ImageMagick
convert art/generated/characters/momi_idle.png -resize 32x32 -filter Point art/generated/characters/momi_idle_32x32.png

# Using Python/PIL
python -c "
from PIL import Image
img = Image.open('art/generated/characters/momi_idle.png')
img_resized = img.resize((32, 32), Image.NEAREST)
img_resized.save('art/generated/characters/momi_idle_32x32.png')
"
```

**Downscaling Method:**
- Use **NEAREST** neighbor (Point) filter for crisp pixel art
- Never use smooth/linear filters (causes blur)

---

### Stage 4: Quality Assurance

#### Automated Verification

**Size Check:**
```bash
# Verify all character sprites are 32x32
python -c "
from PIL import Image
import os

target_size = (32, 32)
sprite_dir = 'art/generated/characters'

for filename in os.listdir(sprite_dir):
    if filename.endswith('.png') and not filename.endswith('_preview.png'):
        img = Image.open(os.path.join(sprite_dir, filename))
        status = '✓ OK' if img.size == target_size else f'✗ FAIL: {img.size}'
        print(f'{filename}: {status}')
"
```

**Batch Size Verification:**
```bash
# Check all asset types at once
python -c "
from PIL import Image
import os

expected = {
    'characters': (32, 32),
    'enemies': (24, 24),
    'bosses': (48, 48),
    'items': (16, 16),
    'equipment': (16, 16),
    'tiles': (16, 16)
}

for dir_name, size in expected.items():
    dir_path = f'art/generated/{dir_name}'
    if os.path.exists(dir_path):
        print(f'\n{dir_name.upper()} (expected {size[0]}x{size[1]}):')
        for file in os.listdir(dir_path):
            if file.endswith('.png') and not file.endswith('_preview.png'):
                img = Image.open(os.path.join(dir_path, file))
                status = '✓' if img.size == size else f'✗ {img.size}'
                print(f'  {status} {file}')
"
```

#### Manual Visual QA

**Checklist for EACH sprite:**
- [ ] Correct pixel dimensions (16x16 / 24x24 / 32x32 / 48x48)
- [ ] 1px black outline present and complete
- [ ] Transparent background with no artifacts
- [ ] Matches color palette constraints (see VISUAL_STANDARDS.md)
- [ ] Lighting direction consistent (top-left)
- [ ] No AI generation artifacts (text, distortions, etc.)
- [ ] Aesthetic matches Earthbound-Ghibli style
- [ ] Character is centered in canvas (no clipping)
- [ ] **For enemies:** Visually distinct from player (hostile appearance, different palette)
- [ ] **For items:** Readable at small scale, iconic silhouette

**Visual Comparison Test:**
```bash
# Generate side-by-side comparison for visual review
python -c "
from PIL import Image
import os

# Compare player vs enemy sprites
momi = Image.open('art/generated/characters/momi_idle.png')
raccoon = Image.open('art/generated/enemies/raccoon_idle.png')

# Create comparison image
comparison = Image.new('RGBA', (momi.width + raccoon.width + 10, max(momi.height, raccoon.height)), (255, 255, 255, 0))
comparison.paste(momi, (0, 0))
comparison.paste(raccoon, (momi.width + 10, 0))
comparison.save('art/generated/comparison_player_vs_enemy.png')
print('Comparison saved: art/generated/comparison_player_vs_enemy.png')
"
```

**Review comparison image to verify:**
- Enemy looks smaller/different from player
- Color palettes don't clash
- Silhouettes are distinct
- Player is clearly the "hero" vs enemy "threat"

---

### Stage 5: Scene Integration

**Tool:** Godot Editor (manual integration)

#### Replace Placeholder Sprites

**For Characters:**
1. Open scene file (e.g., `characters/player/player.tscn`)
2. Locate Polygon2D or existing sprite node
3. Replace with AnimatedSprite2D node
4. Create SpriteFrames resource
5. Add animation frames for each state (idle, walk, run, etc.)
6. Wire animations to character state machine (in .gd script)

**For Items/Equipment:**
1. Open inventory UI scene
2. Replace ColorRect placeholders with Sprite2D nodes
3. Set texture to item sprite (e.g., `art/generated/items/health_potion.png`)
4. Verify sprite scale in UI (may need to scale node)

**For Environment Tiles:**
1. Open TileSet resource (`assets/tiles/world_tileset.tres`)
2. Add new tiles to atlas
3. Set tile properties (collision, autotile, etc.)
4. Paint tiles in zone scenes using TileMap editor

#### Animation Setup Example

```gdscript
# In player.gd or companion script
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
    # Animations should match sprite frame names
    animated_sprite.play("idle")

func _physics_process(delta):
    if velocity.length() > 0:
        if is_running:
            animated_sprite.play("run")
        else:
            animated_sprite.play("walk")
    else:
        animated_sprite.play("idle")

    # Flip sprite based on direction
    if velocity.x != 0:
        animated_sprite.flip_h = velocity.x < 0
```

---

## Directory Structure

```
art/
├── generated/                    # All AI-generated sprites
│   ├── characters/              # Player & companion sprites (32x32)
│   │   ├── momi_idle.png
│   │   ├── momi_walk.png
│   │   ├── cinnamon_idle.png
│   │   └── ...
│   ├── enemies/                 # Regular enemy sprites (24x24)
│   │   ├── crow_idle.png
│   │   ├── raccoon_attack.png
│   │   └── ...
│   ├── bosses/                  # Boss sprites (36-48px)
│   │   ├── rat_king_idle.png
│   │   ├── raccoon_king_phase1.png
│   │   └── ...
│   ├── items/                   # Consumable item icons (16x16)
│   │   ├── health_potion.png
│   │   ├── power_treat.png
│   │   └── ...
│   ├── equipment/               # Equipment icons (16x16)
│   │   ├── basic_collar.png
│   │   ├── spiked_collar.png
│   │   └── ...
│   └── tiles/                   # Environment tiles (16x16)
│       ├── neighborhood_tiles.png
│       ├── backyard_tiles.png
│       └── sewers_tiles.png
├── GENERATION_WORKFLOW.md       # This file
└── rip_sprites.py              # Post-processing tool
```

---

## Common Issues & Solutions

### Issue: Sprite has white/colored background instead of transparency
**Solution:**
- Run `python art/rip_sprites.py art/generated/[directory]/`
- If still present, manually edit in GIMP/Photoshop:
  - Select background color with magic wand
  - Delete background
  - Export as PNG with alpha channel

### Issue: Sprite dimensions are wrong (e.g., 31x31 instead of 32x32)
**Solution:**
- Regenerate sprite with explicit size in prompt
- Or manually resize with NEAREST filter:
  ```bash
  convert sprite.png -resize 32x32! -filter Point sprite_fixed.png
  ```
- The `!` forces exact dimensions (ignores aspect ratio)

### Issue: Sprite looks blurry/smoothed
**Cause:** Wrong downscaling filter used (linear/smooth instead of nearest)
**Solution:**
- Always use NEAREST/Point filter for pixel art
- Re-downscale with correct filter:
  ```bash
  convert sprite.png -resize 32x32 -filter Point sprite_crisp.png
  ```

### Issue: Enemy sprite looks too similar to player
**Cause:** Prompt didn't emphasize hostile appearance or color contrast
**Solution:**
- Regenerate with updated prompt:
  - Add "MUST look threatening, NOT friendly or cute"
  - Add "Use cool desaturated colors (grays, blacks, purples)"
  - Add "Distinct from player character (avoid warm tan/brown)"
  - Add hostile eye design (glowing red/yellow, slit pupils)

### Issue: Item sprite not readable at 16x16
**Cause:** Too much detail for small scale
**Solution:**
- Simplify design (reduce colors to 3-4)
- Use iconic shapes (bottle = potion, bone = treat)
- Increase outline thickness if needed
- Test readability by viewing at actual UI size

### Issue: Animation frames don't align (jitter during playback)
**Cause:** Inconsistent pivot point or character position across frames
**Solution:**
- Ensure character is centered in canvas for all frames
- Use same canvas size for all frames in animation
- Verify pivot point is consistent (usually bottom-center)

---

## Batch Generation Scripts

### Generate All Character Sprites
```bash
#!/bin/bash
# generate_characters.sh

CHARACTERS=("momi" "cinnamon" "philo")
STATES=("idle" "walk" "run" "attack" "hurt" "death")

for char in "${CHARACTERS[@]}"; do
    for state in "${STATES[@]}"; do
        echo "Generating ${char}_${state}..."
        python tools/gemini_api_generate.py \
            --prompt "32x32 pixel art of ${char} in ${state} animation. [ADD CHARACTER-SPECIFIC DETAILS HERE]" \
            --output "art/generated/characters/${char}_${state}.png" \
            --size 64x64
    done
done

# Post-process all
python art/rip_sprites.py art/generated/characters/
```

### Generate All Items
```bash
#!/bin/bash
# generate_items.sh

ITEMS=(
    "health_potion:red healing potion"
    "mega_potion:magenta super potion"
    "power_treat:orange dog bone with fire aura"
    "speed_treat:cyan dog bone with motion lines"
)

for item_data in "${ITEMS[@]}"; do
    IFS=':' read -r item_name item_desc <<< "$item_data"
    echo "Generating ${item_name}..."
    python tools/gemini_api_generate.py \
        --prompt "16x16 pixel art icon of ${item_desc}. SNES RPG item icon, simple readable design, 1px black outline, transparent background." \
        --output "art/generated/items/${item_name}.png" \
        --size 32x32
done

# Post-process all
python art/rip_sprites.py art/generated/items/
```

---

## Quality Gates

Before moving to the next phase, ALL sprites must pass:

### Gate 1: Size Verification (Automated)
- [ ] All sprites match target pixel dimensions
- [ ] No oversized or undersized sprites
- [ ] Batch verification script returns "OK" for all

### Gate 2: Visual QA (Manual)
- [ ] All sprites have 1px black outlines
- [ ] All backgrounds are fully transparent
- [ ] No AI artifacts or generation errors
- [ ] Aesthetic consistency across all assets

### Gate 3: Color Palette Check (Manual)
- [ ] Player/companions use warm friendly tones
- [ ] Enemies use cool hostile tones
- [ ] No palette conflicts (enemies don't use player colors)
- [ ] Color coding is consistent (red = health, orange = power, etc.)

### Gate 4: Distinctiveness Test (Manual)
- [ ] Player is instantly identifiable in side-by-side comparison
- [ ] Enemies look hostile and threatening (not friendly/cute)
- [ ] Items are readable at small scale
- [ ] No visual confusion between asset types

### Gate 5: Integration Test (In-Game)
- [ ] Sprites display correctly in Godot scenes
- [ ] Animations play smoothly without jitter
- [ ] Scale looks appropriate in gameplay
- [ ] Visual clarity during combat and exploration

---

## Workflow Summary Checklist

**Pre-Generation:**
- [ ] Review audit documents (identify missing sprites)
- [ ] Review VISUAL_STANDARDS.md (confirm requirements)
- [ ] Prepare generation prompts (use templates)
- [ ] Set up directory structure

**Generation:**
- [ ] Generate sprites using Gemini API
- [ ] Generate at 2x size for quality (64x64 → 32x32)
- [ ] Use detailed prompts with all required elements
- [ ] Generate multiple candidates, select best

**Post-Processing:**
- [ ] Run rip_sprites.py (background removal)
- [ ] Downscale to target size (NEAREST filter)
- [ ] Generate preview images for QA
- [ ] Clean up edge artifacts

**Quality Assurance:**
- [ ] Run automated size verification
- [ ] Manual visual QA (outline, transparency, artifacts)
- [ ] Color palette verification
- [ ] Visual distinctiveness test (player vs enemies)
- [ ] Readability test (items at UI scale)

**Integration:**
- [ ] Replace placeholder nodes in Godot scenes
- [ ] Set up AnimatedSprite2D with SpriteFrames
- [ ] Wire animations to state machines
- [ ] Test in-game appearance and behavior

**Final Review:**
- [ ] All quality gates passed
- [ ] Playtest confirms visual clarity
- [ ] No visual confusion or aesthetic inconsistencies
- [ ] Ready for production

---

## References

- **Visual Standards:** `.auto-claude/specs/005-visual-polish-sprite-consistency/VISUAL_STANDARDS.md`
- **Character Audit:** `.auto-claude/specs/005-visual-polish-sprite-consistency/character_sprite_audit.md`
- **Enemy Audit:** `.auto-claude/specs/005-visual-polish-sprite-consistency/enemy_sprite_audit.md`
- **Item Audit:** `.auto-claude/specs/005-visual-polish-sprite-consistency/item_sprite_audit.md`
- **Environment Audit:** `.auto-claude/specs/005-visual-polish-sprite-consistency/environment_audit.md`
- **QA Checklist:** `.auto-claude/specs/005-visual-polish-sprite-consistency/SPRITE_QA_CHECKLIST.md` (upcoming)

---

**Document Version:** 1.0
**Last Updated:** 2026-02-01
**Maintained By:** Auto-Claude (Task 005 - Visual Polish & Sprite Consistency)
