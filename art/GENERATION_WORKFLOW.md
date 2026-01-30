# Momi's Adventure - Pixel Art Sprite Generation Workflow

## Quick Start (Use This!)

### Step 1: Use Your Existing Good Sprites
You already have good pixel art sprites in `C:\Projects\MomiAdventure\gemini_images`:
- **momi_idle_v2.png** → Copy to `art/generated/characters/momi_idle.png`
- **momi_walk_8frames.png** → Copy to `art/generated/characters/momi_walk.png`
- **momi_run_8frames.png** → Copy to `art/generated/characters/momi_run.png`

These are already in the right pixel art style with proper frames.

### Step 2: Generate Missing Sprites via Gemini Web UI

For sprites you don't have yet, use this streamlined process:

#### A. Open Gemini Web UI
1. Go to https://gemini.google.com
2. Log in with your Google account
3. Make sure you're in "Image generation" mode

#### B. Use These Corrected Prompts (Copy-Paste Ready)

**MASTER PROMPT TEMPLATE:**
```
Create a pixel art sprite sheet for a 2D top-down action RPG.

TECHNICAL SPECS:
- 64x64 pixels per frame
- 3/4 top-down perspective (like Zelda/Stardew Valley)
- Clean 1px black outline around character
- Cel-shading with 2-3 value steps per color
- Transparent background (PNG with alpha)
- Horizontal sprite strip layout

CHARACTER: [NAME]
[Breed, colors, key features]

ANIMATION: [TYPE]
- [Frame count] frames
- [Description of motion]
- [Direction facing]

STYLE: High-quality pixel art, SNES-era quality, consistent lighting from top-left.
```

**Example - Momi Attack:**
```
Create a pixel art sprite sheet for a 2D top-down action RPG.

TECHNICAL SPECS:
- 64x64 pixels per frame, 4 frames total
- 3/4 top-down perspective
- Clean 1px black outline
- Cel-shading (2-3 value steps)
- Transparent background
- Horizontal strip layout

CHARACTER: Momi (French Bulldog)
- Black brindle coat (charcoal base #1a1a1a, tan streaks #8b6914)
- White chest shield and chin (#ffffff)
- Large bat ears, flat muzzle, stubby tail
- Stocky compact build

ANIMATION: Bite attack facing down
- Frame 1: Wind up lean back
- Frame 2: Lunge forward jaws open
- Frame 3: Teeth clench impact
- Frame 4: Recovery close mouth

STYLE: SNES-quality pixel art, expressive eyes, readable silhouette.
```

### Step 3: Batch Download with Browser Console Script

When you have multiple images generated and want to download them all:

1. **Open Browser Console**
   - Press `F12` in Chrome/Edge
   - Click "Console" tab

2. **Run This Script** (Copy-paste):

```javascript
(async () => {
  // Get all image URLs from the page
  const images = Array.from(document.querySelectorAll('img'))
    .filter(img => img.src.includes('googleusercontent.com') || img.src.includes('gstatic.com'))
    .map(img => img.src);
  
  // Remove duplicates
  const uniqueUrls = [...new Set(images)];
  
  console.log(`Found ${uniqueUrls.length} images`);
  
  for (let i = 0; i < uniqueUrls.length; i++) {
    try {
      // Create image element and load
      const img = new Image();
      img.crossOrigin = 'anonymous';
      
      await new Promise((resolve, reject) => {
        img.onload = resolve;
        img.onerror = reject;
        img.src = uniqueUrls[i];
      });
      
      // Draw to canvas
      const canvas = document.createElement('canvas');
      canvas.width = img.naturalWidth;
      canvas.height = img.naturalHeight;
      const ctx = canvas.getContext('2d');
      ctx.drawImage(img, 0, 0);
      
      // Trigger download
      const a = document.createElement('a');
      a.href = canvas.toDataURL('image/png');
      a.download = `gemini_${String(i+1).padStart(3, '0')}.png`;
      a.click();
      
      console.log(`Downloaded ${i+1}/${uniqueUrls.length}`);
      
      // Small delay between downloads
      await new Promise(r => setTimeout(r, 500));
    } catch (e) {
      console.error(`Failed ${i+1}: ${e.message}`);
    }
  }
  console.log('All downloads complete!');
})();
```

3. **Organize Downloads**
   - Move downloaded files to `art/generated/[category]/`
   - Rename to match the IDs in `art/prompts_v2_pixel_art.json`

### Step 4: Post-Processing

Run the sprite ripper to remove backgrounds and downscale:
```bash
cd C:\Users\major\momi-chronicles
python art/rip_sprites.py
```

This will:
- Remove white/transparent backgrounds
- Clean edge pixels
- Downscale to game-ready sizes

---

## Priority Sprite List (Generate in Order)

### CRITICAL (Core Gameplay)
1. ✅ momi_idle (copy from existing)
2. ✅ momi_walk (copy from existing)
3. ✅ momi_run (copy from existing)
4. ⬜ momi_attack (needs generation)
5. ⬜ momi_hurt (needs generation)
6. ⬜ momi_death (needs generation)

### HIGH (Combat)
7. ⬜ cinnamon_idle
8. ⬜ cinnamon_walk
9. ⬜ cinnamon_attack
10. ⬜ philo_idle_lazy
11. ⬜ philo_walk_lazy

### MEDIUM (Polish)
12-18. All other character states
19-30. Enemy sprites
31-40. Equipment/items

---

## Tips for Best Results

### Do:
- ✅ Generate ONE sprite at a time (not batches)
- ✅ Use "v2" or "revised" to iterate on failed attempts
- ✅ Download immediately after good generation
- ✅ Check that frames are consistent (same size, alignment)
- ✅ Use reference: paste existing good sprite as visual reference

### Don't:
- ❌ Ask for 8+ frames in one prompt (harder to control)
- ❌ Use vague descriptions ("cute dog")
- ❌ Forget to specify transparent background
- ❌ Accept blurry or anti-aliased results

### Troubleshooting:
- **Wrong colors?** Add hex codes: "Black #1a1a1a, tan #8b6914"
- **Not pixel art?** Add: "Sharp pixel edges, no anti-aliasing"
- **Wrong perspective?** Add: "3/4 top-down view, not side view"
- **Background not transparent?** Add: "Transparent PNG, alpha channel"

---

## Files Reference

| File | Purpose |
|------|---------|
| `art/prompts_v2_pixel_art.json` | Updated prompts with correct pixel art specs |
| `art/generated/` | Output folder for raw AI-generated sprites |
| `art/rip_sprites.py` | Post-processing (background removal, downscale) |
| `tools/gemini_automation.py` | Browser automation (optional fallback) |

---

## Next Steps

1. Copy your existing good sprites
2. Try generating ONE missing sprite with the corrected prompt
3. If it looks good, generate the rest in batches of 3-5
4. Run rip_sprites.py when all done
5. Proceed to Phase 32: Sprite Integration
