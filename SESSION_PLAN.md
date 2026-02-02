# Momi's Adventure — Next Session Plan

## Status: Ready to Generate Fresh Sprites

All code, prompts, and style fixes are DONE. The next session is purely generation + picking favorites.

## What's Been Fixed (Already Applied)
- Momi is BLACK (not brown), all-black face, white chin only, NO TAIL (tiny nub), NO COLLAR
- Momi's eyes: BIG, round, adorable, Puss in Boots cute energy, visible catchlights
- Cinnamon: NO red tactical harness
- Philo: NO blue bandana
- Enemy prompts rewritten: 8 enemies now (4 idle + 4 attack), all 8-frame animation strips
- Total prompts: 36 (24 characters + 8 enemies + 4 tiles)
- Generator script has CHARACTER_APPEARANCE dict injected per-prompt + per-character reference image support

## Current Generated Files (ALL STALE — need regeneration)
- `art/generated/characters/` — batch 4 copies, OLD (before eye fix, before accessory removal)
- `art/generated/enemies/` — batch 4 copies, OLD filenames (roomba_cranky.png etc.)
- `art/generated/batch_1/` through `batch_4/` — all OLD batches (before latest fixes)
- `art/generated/zones/` — tiles are fine, unchanged
- `art/generated/archive/` — even older pre-session sprites

## Step-by-Step Plan

### Step 1: Clear Old Output
Delete stale sprites from `characters/` and `enemies/` output folders:
```powershell
Remove-Item "art/generated/characters/*" -Force
Remove-Item "art/generated/enemies/*" -Force
```

### Step 2: Generate Batch 5 — Full Run (all 36 prompts)
First batch with ALL fixes applied:
```powershell
cd C:\Users\major\momi-chronicles
python tools/gemini_api_generate.py
```
This generates into `art/generated/characters/` and `art/generated/enemies/` and `art/generated/zones/` (zones will skip since they already exist).

Move results to batch_5:
```powershell
mkdir art/generated/batch_5/characters
mkdir art/generated/batch_5/enemies  
mkdir art/generated/batch_5/zones
Copy-Item art/generated/characters/* art/generated/batch_5/characters/
Copy-Item art/generated/enemies/* art/generated/batch_5/enemies/
Copy-Item art/generated/zones/* art/generated/batch_5/zones/
```

### Step 3: Generate Batches 6-8 — Characters Only (3 more batches)
Clear characters folder between each run, generate characters only:
```powershell
# Batch 6
Remove-Item "art/generated/characters/*" -Force
python tools/gemini_api_generate.py --category characters
mkdir art/generated/batch_6/characters
Copy-Item art/generated/characters/* art/generated/batch_6/characters/

# Batch 7
Remove-Item "art/generated/characters/*" -Force  
python tools/gemini_api_generate.py --category characters
mkdir art/generated/batch_7/characters
Copy-Item art/generated/characters/* art/generated/batch_7/characters/

# Batch 8
Remove-Item "art/generated/characters/*" -Force
python tools/gemini_api_generate.py --category characters
mkdir art/generated/batch_8/characters
Copy-Item art/generated/characters/* art/generated/batch_8/characters/
```

### Step 4: Update compare.html
Update the comparison page for:
- New enemy filenames (roomba_idle, roomba_attack, gnome_idle, gnome_attack, etc.)
- Batches 5-8
- Character-only comparison mode

### Step 5: Pick Favorites + Set Up Reference Images
1. Open compare.html, pick best idle sprite per character
2. Create reference folders:
```powershell
mkdir art/reference/momi
mkdir art/reference/cinnamon
mkdir art/reference/philo
mkdir art/reference/shared
```
3. Copy chosen idle sprites into reference folders
4. Regenerate with consistency:
```powershell
python tools/gemini_api_generate.py --character-refs art/reference
```

### Step 6: QA Review
Analyze generated images checking:
- Momi: BLACK coat? All-black face? White chin only? No collar? No tail? Big cute eyes?
- Cinnamon: Black and tan? No harness/vest?
- Philo: Black and white tuxedo? Grey muzzle? No bandana?
- Enemies: 8-frame strips (not single sprites)?

## Key Files
| File | Purpose |
|------|---------|
| `art/style_context.txt` | Master style guide (36 lines) |
| `art/prompts_v2_pixel_art.json` | All 36 prompts |
| `tools/gemini_api_generate.py` | Generator script (718 lines) |
| `art/generated/compare.html` | Batch comparison page (needs update) |
| `art/rip_sprites.py` | Post-processing: bg removal + downscale |
| `.env` | Contains GEMINI_API_KEY |

## Quick Start Next Session
Just say: **"Let's run the sprite generation plan"** and I'll start from Step 1.
