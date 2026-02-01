# Sprite Generation QA Checklist
**Version:** 1.0
**Date:** 2026-02-01
**Purpose:** Quality assurance checklist for AI-generated sprites before integration into Momi's Adventure

---

## Overview

This checklist must be completed for EVERY sprite before it is integrated into scene files. All items must pass (✓) before the sprite is approved for use. Any failures (✗) must be documented and addressed with regeneration or post-processing.

**Related Documents:**
- [VISUAL_STANDARDS.md](./VISUAL_STANDARDS.md) - Pixel scale and color palette requirements
- [GENERATION_WORKFLOW.md](../../art/GENERATION_WORKFLOW.md) - AI generation process

---

## Quick Reference: Asset Type Requirements

| Asset Type | Dimensions | Outline | Lighting | Transparency | Notes |
|------------|------------|---------|----------|--------------|-------|
| Characters (Player/Companions) | 32x32 | 1px black | Top-left | Required | Warm colors, friendly eyes |
| Regular Enemies | 24x24 | 1px black | Top-left | Required | Cool colors, hostile appearance |
| Mini-Bosses | 36-40px | 1px black | Top-left | Required | Larger, imposing presence |
| Major Bosses | 48x48 | 1px black | Top-left | Required | Double player size |
| Items | 16x16 | 1px black | Top-left | Required | Simple, readable icons |
| Equipment | 16x16 | 1px black | Top-left | Required | Slot-recognizable shapes |
| Environment Tiles | 16x16 | 1px black | Top-left | Required | Tileable edges (if ground/wall) |

---

## Section 1: Scale Verification

### 1.1 Pixel Dimensions ✓ / ✗

**CRITICAL:** Incorrect dimensions will break sprite integration and visual consistency.

#### Automated Verification
```bash
# Use this command to check sprite dimensions:
python -c "from PIL import Image; img = Image.open('SPRITE_PATH.png'); print(f'Size: {img.size}')"
```

#### Manual Verification Checklist

- [ ] **Character Sprites:** Exactly 32x32 pixels
  - [ ] Momi sprites (idle, walk, run, attack, hurt, death)
  - [ ] Cinnamon sprites (idle, walk, run, attack, hurt, death)
  - [ ] Philo sprites (idle, walk, run, attack, hurt, death)

- [ ] **Regular Enemy Sprites:** Exactly 24x24 pixels
  - [ ] Crow (idle, move, attack, hurt, death)
  - [ ] Raccoon (idle, move, attack, hurt, death)
  - [ ] Sewer Rat (idle, move, attack, hurt, death)
  - [ ] Shadow Creature (idle, move, attack, hurt, death)
  - [ ] Stray Cat (idle, move, attack, hurt, death)

- [ ] **Mini-Boss Sprites:** 36-40px (varies by type)
  - [ ] Alpha Raccoon: 36x36 pixels (ground-based)
  - [ ] Crow Matriarch: 40x40 pixels (aerial, needs wing space)

- [ ] **Major Boss Sprites:** Exactly 48x48 pixels
  - [ ] Rat King (all phases)
  - [ ] Raccoon King (Phase 1 and Phase 2)

- [ ] **Item Sprites:** Exactly 16x16 pixels
  - [ ] All potions (health, mega, full heal)
  - [ ] All treats (power, speed, tough, energy)
  - [ ] All food items (acorn, seeds, etc.)

- [ ] **Equipment Sprites:** Exactly 16x16 pixels
  - [ ] All collars (by tier)
  - [ ] All harnesses (by tier)
  - [ ] All leashes (by tier)
  - [ ] All coats (by tier)
  - [ ] All hats (by tier)

- [ ] **Environment Tiles:** Exactly 16x16 pixels
  - [ ] All ground tiles (grass, asphalt, dirt, stone)
  - [ ] All wall tiles (fence, brick, house walls)
  - [ ] All props (mailbox, trash can, bench, etc.)

**FAIL Actions:**
- If dimensions are incorrect, regenerate sprite with correct target size
- Use NEAREST NEIGHBOR downscaling if sprite is larger (preserves pixel art)
- NEVER use bilinear/bicubic scaling (creates blur)

---

## Section 2: Color Consistency

### 2.1 Color Palette Compliance ✓ / ✗

**CRITICAL:** Color palette violations can cause player vs enemy confusion.

#### Player/Companion Palette Check (FRIENDLY - Warm Tones)

- [ ] **Momi (French Bulldog):**
  - [ ] Primary color: Tan/golden brown `#D9B373` (or similar warm tan)
  - [ ] NO cool/hostile colors (blue, purple, green-gray)
  - [ ] Friendly expressive eyes (brown, blue, or black pupils)
  - [ ] Warm highlights, no glowing/hostile effects

- [ ] **Cinnamon (English Bulldog):**
  - [ ] Primary color: Rich brown `#BF804D` (or similar brown)
  - [ ] NO enemy colors (dirty gray-brown `#7F6659` used by Raccoon)
  - [ ] Friendly expressive eyes
  - [ ] Warm, saturated tones

- [ ] **Philo (Boston Terrier):**
  - [ ] Primary color: Gray-blue tuxedo `#4D4D59` (cool gray-blue)
  - [ ] Black and white tuxedo pattern
  - [ ] Friendly expressive eyes
  - [ ] NO hostile appearance despite cool colors

#### Enemy Palette Check (HOSTILE - Cool/Desaturated Tones)

- [ ] **Crow:**
  - [ ] Primary: Black `#1A1420`, dark gray, purple shadows
  - [ ] Eyes: Red or yellow glowing (NOT friendly brown/blue)
  - [ ] NO warm friendly tones

- [ ] **Raccoon:**
  - [ ] Primary: Dirty gray-brown `#7F6659` (NOT Cinnamon's `#BF804D`)
  - [ ] Black mask, yellow hostile eyes
  - [ ] Desaturated, NOT vibrant

- [ ] **Sewer Rat:**
  - [ ] Primary: Sickly green-gray `#728066`
  - [ ] Red glowing eyes, diseased patches
  - [ ] NO warm healthy tones

- [ ] **Shadow Creature:**
  - [ ] Primary: Pure black `#261438`, dark purple
  - [ ] Glowing purple/red core
  - [ ] Otherworldly, threatening appearance

- [ ] **Stray Cat:**
  - [ ] Primary: Orange tabby `#D98C33` OR black with white
  - [ ] Green/yellow slit eyes (hostile, NOT friendly round)
  - [ ] Aggressive appearance despite being an animal

- [ ] **All Bosses:**
  - [ ] Use darker/richer versions of regular enemy colors
  - [ ] Royal or corruption-themed accents
  - [ ] Hostile eye design (glowing, menacing)

#### Item/Equipment Color Coding Check

- [ ] **Healing Items:**
  - [ ] Health Potion: Bright red `#FF4D4D`
  - [ ] Mega Potion: Magenta/pink `#FF197F`
  - [ ] Full Heal: Light pink/white `#FFE6F0`

- [ ] **Buff Items:**
  - [ ] Power Treat: Orange `#FF7F00` (attack buff)
  - [ ] Speed Treat: Cyan `#4DE6FF` (speed buff)
  - [ ] Tough Treat: Purple-blue `#7F7FCC` (defense buff)
  - [ ] Energy Treat: Gold `#FFD900` (all stats buff)

- [ ] **Equipment Tiers:**
  - [ ] Tier 1: Natural colors (brown, blue, red, yellow)
  - [ ] Tier 2: Richer/darker versions
  - [ ] Tier 3: Metallic, ornate, saturated
  - [ ] Boss Loot: Dark/regal with special accents

**FAIL Actions:**
- Regenerate sprite with corrected color palette
- Use VISUAL_STANDARDS.md color references in AI prompt
- For enemies that resemble player (Raccoon, Cat), ensure COOLER and DESATURATED tones

---

## Section 3: Aesthetic Match

### 3.1 Earthbound-meets-Ghibli Style ✓ / ✗

**Visual References:**
- Earthbound/Mother 3: Bright colors, quirky charm, suburban settings
- Studio Ghibli: Expressive characters, nature/whimsy, heartfelt personality
- CrossCode: Visual consistency, readable sprites, polished pixel art

#### Style Compliance Checklist

- [ ] **SNES 16-bit Aesthetic:**
  - [ ] Pixel art style (NOT blurry or high-res)
  - [ ] Limited color palette (NOT gradient-heavy)
  - [ ] Clean pixels (NO anti-aliasing halos)

- [ ] **Cute but Not Childish:**
  - [ ] Characters are adorable but have personality/depth
  - [ ] NOT overly simplified or cartoony
  - [ ] Appropriate detail level for pixel scale

- [ ] **Expressive Design:**
  - [ ] Character poses convey emotion clearly
  - [ ] Eyes/faces are readable and expressive
  - [ ] Body language is clear (friendly vs hostile)

- [ ] **Suburban Fantasy Theme:**
  - [ ] Modern neighborhood setting elements (for neighborhood zone)
  - [ ] Nature/wilderness elements (for backyard zone)
  - [ ] Underground/dungeon elements (for sewers zone)
  - [ ] NO medieval fantasy or high-tech sci-fi elements

- [ ] **Visual Personality:**
  - [ ] Player/companions look heroic and lovable
  - [ ] Enemies look threatening but fit the world
  - [ ] Items/equipment are thematically appropriate
  - [ ] Tiles match zone aesthetic (bright suburban / wild nature / dark dungeon)

**FAIL Actions:**
- If style is off, regenerate with updated AI prompt emphasizing "SNES 16-bit Earthbound pixel art"
- Reference existing approved sprites (Momi, Cinnamon) for style consistency
- Avoid AI artifacts (text, distortions, wrong art style)

---

## Section 4: Animation Frame Alignment

### 4.1 Frame Consistency ✓ / ✗

**CRITICAL:** Misaligned frames cause jitter and look unprofessional.

#### Multi-Frame Animation Checks

For EACH animation sequence (idle, walk, run, attack, hurt, death):

- [ ] **Canvas Size Consistency:**
  - [ ] All frames in sequence are EXACT same dimensions
  - [ ] Example: All "momi_walk" frames are 32x32 (not 32x32, 31x32, 32x33)

- [ ] **Pivot Point Alignment:**
  - [ ] Character's bottom-center is consistently positioned across frames
  - [ ] Character doesn't "drift" or "shift" during animation playback
  - [ ] Use overlay test: stack frames and check alignment

- [ ] **Bounding Box Stability:**
  - [ ] Character fits within same visual bounds in all frames
  - [ ] No frames where character is clipped or extends beyond canvas
  - [ ] Parts like tails/ears stay within consistent bounds

- [ ] **Center Alignment:**
  - [ ] Character is centered in canvas in all frames
  - [ ] NOT shifted left/right/up/down in different frames
  - [ ] Prevents animation "jitter" or "bobbing"

#### Visual Alignment Test

**Manual Test Procedure:**
1. Open all frames of an animation in image editor
2. Stack frames as layers with 50% opacity
3. Toggle visibility between frames
4. Look for:
   - ✓ Character stays in same position (good)
   - ✗ Character jumps/shifts between frames (FAIL)

**Automated Test (if available):**
```python
from PIL import Image
import os

def check_frame_alignment(frame_paths):
    """Verify all frames have same dimensions and rough alignment"""
    sizes = [Image.open(f).size for f in frame_paths]

    # Check size consistency
    if len(set(sizes)) > 1:
        print(f"✗ FAIL: Inconsistent sizes: {sizes}")
        return False

    print(f"✓ OK: All frames are {sizes[0]}")
    return True

# Example usage:
check_frame_alignment([
    "art/generated/characters/momi_walk_0.png",
    "art/generated/characters/momi_walk_1.png",
    "art/generated/characters/momi_walk_2.png",
    "art/generated/characters/momi_walk_3.png"
])
```

**FAIL Actions:**
- Regenerate frames with stricter AI prompt specifying exact positioning
- Use post-processing to center sprite in canvas
- Manually adjust frames to align pivot points

---

## Section 5: Transparency

### 5.1 Background Transparency ✓ / ✗

**CRITICAL:** Opaque backgrounds or artifacts will show in-game and look terrible.

#### Automated Transparency Check
```python
from PIL import Image

def check_transparency(sprite_path):
    """Verify sprite has transparent background"""
    img = Image.open(sprite_path)

    # Check if image has alpha channel
    if img.mode != 'RGBA':
        print(f"✗ FAIL: {sprite_path} - No alpha channel (mode: {img.mode})")
        return False

    # Check for fully transparent pixels (background)
    pixels = img.getdata()
    transparent_count = sum(1 for p in pixels if p[3] == 0)

    if transparent_count == 0:
        print(f"✗ FAIL: {sprite_path} - No transparent pixels found")
        return False

    print(f"✓ OK: {sprite_path} - {transparent_count} transparent pixels")
    return True
```

#### Manual Transparency Checks

- [ ] **Alpha Channel Present:**
  - [ ] Image mode is RGBA (NOT RGB, NOT indexed)
  - [ ] Transparent pixels have alpha = 0
  - [ ] Sprite pixels have alpha = 255 (fully opaque)

- [ ] **Clean Background:**
  - [ ] Background is FULLY transparent (alpha = 0)
  - [ ] NO semi-transparent halos around sprite
  - [ ] NO white/colored edges or artifacts
  - [ ] NO leftover AI generation background elements

- [ ] **Edge Quality:**
  - [ ] Sprite outline is clean and crisp
  - [ ] NO anti-aliasing blur on edges (use clean alpha cutoff)
  - [ ] Edges align with 1px black outline
  - [ ] NO double-outlines or edge artifacts

- [ ] **Interior Transparency:**
  - [ ] Interior hollow areas (e.g., between legs) are transparent
  - [ ] NO accidentally filled transparent areas
  - [ ] Sprite silhouette is correct

#### Post-Processing Requirement

**ALL AI-generated sprites MUST be processed:**
```bash
# Run background removal on all sprites
python art/rip_sprites.py art/generated/characters/
python art/rip_sprites.py art/generated/enemies/
python art/rip_sprites.py art/generated/bosses/
python art/rip_sprites.py art/generated/items/
python art/rip_sprites.py art/generated/equipment/
```

**Visual Test:**
- Open sprite in image editor with checkerboard background
- Verify: Sprite edges are clean, background is transparent
- Look for: White halos, colored edges, leftover background elements (FAIL)

**FAIL Actions:**
- Re-run `rip_sprites.py` with stricter background removal settings
- Manually clean up edges in image editor if automated tools fail
- Regenerate sprite if AI included too much background noise

---

## Section 6: Technical Quality

### 6.1 Outline Standards ✓ / ✗

- [ ] **1px Black Outline Present:**
  - [ ] Entire sprite silhouette has 1px outline
  - [ ] Outline color is pure black `#000000` or very dark `#0A0A0A`
  - [ ] NO gaps in outline (complete coverage)
  - [ ] Outline is consistent thickness (1px, not thicker)

- [ ] **Outline Coverage:**
  - [ ] Outer silhouette is outlined
  - [ ] Interior details (eyes, patterns) do NOT need outlines
  - [ ] Outline doesn't bleed into sprite body

### 6.2 Lighting Direction ✓ / ✗

- [ ] **Light Source: Top-Left:**
  - [ ] Top-left surfaces are lighter (highlights)
  - [ ] Bottom-right surfaces are darker (shadows)
  - [ ] Consistent with other sprites (not random lighting)

- [ ] **Shading Consistency:**
  - [ ] Shading matches pixel art style (NOT realistic gradients)
  - [ ] Limited shading levels (typically 2-3 tones per color)
  - [ ] Shading enhances readability, not overly complex

### 6.3 Perspective ✓ / ✗

- [ ] **Top-Down 3/4 View:**
  - [ ] Slight angle (NOT pure top-down or side view)
  - [ ] Character face/front is visible for readability
  - [ ] Matches perspective of other sprites in game

- [ ] **Viewpoint Consistency:**
  - [ ] Tiles use same 3/4 perspective
  - [ ] Items use straight-on or slight 3/4 for icon clarity
  - [ ] All sprites viewable from same general angle

---

## Section 7: Visual Distinctiveness

### 7.1 Player vs Enemy Distinction ✓ / ✗

**CRITICAL TEST:** Can you instantly identify Momi vs enemies in a cluttered combat scene?

#### Side-by-Side Comparison Test

Place Momi sprite next to EACH enemy sprite:

- [ ] **Momi vs Crow:**
  - [ ] Color: Momi is warm tan, Crow is black/purple (DISTINCT)
  - [ ] Size: Momi 32x32, Crow 24x24 (Momi larger)
  - [ ] Eyes: Momi friendly, Crow glowing hostile

- [ ] **Momi vs Raccoon (HIGH RISK - both quadrupeds):**
  - [ ] Color: Momi `#D9B373` warm tan vs Raccoon `#7F6659` dirty gray (DISTINCT)
  - [ ] Posture: Momi upright/heroic vs Raccoon hunched/sneaky (DISTINCT)
  - [ ] Eyes: Momi friendly vs Raccoon hostile yellow (DISTINCT)
  - [ ] Size: Momi 32x32 vs Raccoon 24x24 (Momi larger)

- [ ] **Momi vs Sewer Rat:**
  - [ ] Color: Momi warm tan vs Rat sickly green-gray (DISTINCT)
  - [ ] Size: Momi 32x32, Rat 24x24 (Momi larger)
  - [ ] Eyes: Momi friendly vs Rat glowing red (DISTINCT)

- [ ] **Momi vs Shadow Creature:**
  - [ ] Color: Momi warm tan vs Shadow black/purple (DISTINCT)
  - [ ] Appearance: Momi solid vs Shadow ethereal/glowing (DISTINCT)

- [ ] **Momi vs Stray Cat (HIGH RISK - both quadrupeds):**
  - [ ] Color: Momi warm tan vs Cat orange tabby OR black/white (DISTINCT)
  - [ ] Posture: Momi stocky/upright vs Cat lean/arched aggressive (DISTINCT)
  - [ ] Eyes: Momi friendly round vs Cat slit/hostile (DISTINCT)
  - [ ] Size: Momi 32x32 vs Cat 24x24 (Momi larger)

**FAIL Criteria:**
- If ANY enemy could be confused with Momi, regenerate with stricter color/posture constraints
- Pay special attention to Raccoon and Stray Cat (animal enemies)

---

## Section 8: Asset-Specific Checks

### 8.1 Character Sprites (Player/Companions) ✓ / ✗

- [ ] **Friendly Appearance:**
  - [ ] Cute, lovable, heroic design
  - [ ] Expressive friendly eyes
  - [ ] Warm inviting colors
  - [ ] Upright confident posture

- [ ] **Animation Completeness:**
  - [ ] Idle animation (looping)
  - [ ] Walk animation (4+ frames)
  - [ ] Run animation (faster than walk)
  - [ ] Attack animation (shows action)
  - [ ] Hurt animation (shows pain)
  - [ ] Death animation (falls/fades)

### 8.2 Enemy Sprites ✓ / ✗

- [ ] **Hostile Appearance:**
  - [ ] Threatening, aggressive design
  - [ ] Hostile eyes (glowing, slit, or no visible eyes)
  - [ ] Cool/desaturated colors
  - [ ] Aggressive posture (hunched, arched, menacing)

- [ ] **Size Appropriate:**
  - [ ] Regular enemies: 24x24 (smaller than player)
  - [ ] Mini-bosses: 36-40px (larger than player)
  - [ ] Major bosses: 48x48 (double player size)

### 8.3 Item Sprites ✓ / ✗

- [ ] **Readability at 16x16:**
  - [ ] Sprite is clearly identifiable at small scale
  - [ ] Silhouette is iconic (bottle, bone, etc.)
  - [ ] Limited colors (3-4 max)
  - [ ] NO fine details that become noise at small scale

- [ ] **Category Consistency:**
  - [ ] Potions use bottle shape
  - [ ] Treats use bone shape
  - [ ] Color matches item type (red = health, orange = power, etc.)

### 8.4 Equipment Sprites ✓ / ✗

- [ ] **Slot Recognizable:**
  - [ ] Collar: Circular shape with buckle
  - [ ] Harness: X or H strap pattern
  - [ ] Leash: Linear/curved (rope, chain)
  - [ ] Coat: Garment with collar/sleeves
  - [ ] Hat: Headwear with distinguishing features

- [ ] **Tier Progression:**
  - [ ] Tier 1: Simple, natural materials
  - [ ] Tier 2: Enhanced detail
  - [ ] Tier 3: Ornate, special effects
  - [ ] Boss Loot: Unique design with boss theme

### 8.5 Environment Tiles ✓ / ✗

- [ ] **Tileability (if ground/wall):**
  - [ ] Edges tile seamlessly with itself
  - [ ] NO visible seams when tiled 4x4
  - [ ] Pattern doesn't create unintended shapes when tiled

- [ ] **Zone Aesthetic Match:**
  - [ ] Neighborhood: Bright suburban, safe wholesome
  - [ ] Backyard: Wild nature, slightly mysterious
  - [ ] Sewers: Dark dungeon, damp foreboding

---

## Section 9: Final Approval

### 9.1 Pre-Integration Checklist ✓ / ✗

Before marking a sprite as "APPROVED" and integrating into scene files:

- [ ] **Section 1: Scale** - All checks pass (correct pixel dimensions)
- [ ] **Section 2: Color** - All checks pass (palette compliance, no conflicts)
- [ ] **Section 3: Aesthetic** - All checks pass (Earthbound-Ghibli style)
- [ ] **Section 4: Animation** - All checks pass (frame alignment, no jitter)
- [ ] **Section 5: Transparency** - All checks pass (clean background, no artifacts)
- [ ] **Section 6: Technical** - All checks pass (outline, lighting, perspective)
- [ ] **Section 7: Distinctiveness** - All checks pass (player vs enemy clarity)
- [ ] **Section 8: Asset-Specific** - All checks pass (appropriate for asset type)

### 9.2 Integration Readiness ✓ / ✗

- [ ] Sprite file is in correct directory:
  - [ ] Characters: `art/generated/characters/`
  - [ ] Enemies: `art/generated/enemies/`
  - [ ] Bosses: `art/generated/bosses/`
  - [ ] Items: `art/generated/items/`
  - [ ] Equipment: `art/generated/equipment/`
  - [ ] Tiles: `art/generated/tiles/` or `assets/tiles/`

- [ ] File naming follows convention:
  - [ ] Format: `{character}_{animation}_{frame}.png`
  - [ ] Example: `momi_walk_0.png`, `crow_attack_1.png`
  - [ ] Lowercase, underscores (not spaces or hyphens)

- [ ] Post-processing completed:
  - [ ] `rip_sprites.py` run successfully (transparent background)
  - [ ] Preview image generated (`*_preview.png` exists)
  - [ ] No errors or warnings in post-processing log

---

## QA Sign-Off Template

```
SPRITE: [sprite_name.png]
ASSET TYPE: [Character / Enemy / Boss / Item / Equipment / Tile]
DIMENSIONS: [WxH pixels]
QA DATE: [YYYY-MM-DD]
QA REVIEWER: [Name]

CHECKLIST STATUS:
- Scale Verification:        [ ✓ / ✗ ]
- Color Consistency:         [ ✓ / ✗ ]
- Aesthetic Match:           [ ✓ / ✗ ]
- Animation Frame Alignment: [ ✓ / ✗ ]
- Transparency:              [ ✓ / ✗ ]
- Technical Quality:         [ ✓ / ✗ ]
- Visual Distinctiveness:    [ ✓ / ✗ ]
- Asset-Specific Checks:     [ ✓ / ✗ ]

OVERALL STATUS: [ APPROVED / NEEDS REWORK ]

ISSUES FOUND (if any):
- [List any issues or failures]

FIX ACTIONS (if needed):
- [List regeneration or post-processing actions required]

APPROVED FOR INTEGRATION: [ YES / NO ]
```

---

## Common Issues & Solutions

### Issue: Incorrect Dimensions
**Symptom:** Sprite is 64x64 instead of 32x32
**Solution:** Regenerate at target size OR downscale with nearest-neighbor
**Prevention:** Specify exact dimensions in AI prompt

### Issue: Color Palette Violation
**Symptom:** Enemy Raccoon uses same brown as companion Cinnamon
**Solution:** Regenerate with cooler/desaturated palette
**Prevention:** Include color constraints in AI prompt, reference VISUAL_STANDARDS.md

### Issue: White Background Artifacts
**Symptom:** White halo around sprite edges
**Solution:** Re-run `rip_sprites.py` with stricter settings
**Prevention:** Use high-quality AI generation with transparent backgrounds

### Issue: Animation Frame Jitter
**Symptom:** Character "jumps" between frames during animation
**Solution:** Regenerate with consistent positioning OR manually center frames
**Prevention:** Use strict frame alignment guidelines in AI prompt

### Issue: Style Inconsistency
**Symptom:** Sprite looks realistic/3D instead of pixel art
**Solution:** Regenerate with "SNES 16-bit pixel art Earthbound style" emphasis
**Prevention:** Reference approved sprites (Momi, Cinnamon) in prompt

### Issue: Player vs Enemy Confusion
**Symptom:** Enemy animal looks too friendly or similar to player
**Solution:** Regenerate with hostile features (glowing eyes, aggressive posture)
**Prevention:** Use side-by-side comparison test during generation

---

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-01 | Initial QA checklist created for sprite generation workflow |

---

**Document Owner:** Auto-Claude (Task 005 - Visual Polish & Sprite Consistency)
**Usage Phase:** Phase 3 (Sprite Generation) and Phase 5 (QA Verification)
**Related Documents:**
- [VISUAL_STANDARDS.md](./VISUAL_STANDARDS.md)
- [GENERATION_WORKFLOW.md](../../art/GENERATION_WORKFLOW.md)
- character_sprite_audit.md
- enemy_sprite_audit.md
- item_sprite_audit.md
