# Session Resume — Browser Automation Ready

## Status: READY TO GENERATE SPRITES

**Last activity:** Setting up Playwright browser automation for pixel art sprites
**Next step:** Run `tools/gemini_automation.py` to generate missing sprites

---

## What's Ready

### ✅ Completed
- Updated all prompts to **8 frames** per animation
- Fixed scripts for Windows (removed unicode errors)
- Replaced bad API sprites with your good pixel art references
- Ran sprite ripper (73 sprites processed, transparent backgrounds)
- Committed all changes

### 📋 To Do (After Restart)

**Priority 1 — Generate via Browser:**
1. Open PowerShell
2. Run: `cd "C:\Users\major\momi-chronicles"`
3. Run: `python tools\gemini_automation.py --single 5`
4. Press Enter → Chrome opens
5. Sign into Google
6. Click Send for momi_dig prompt
7. Save image to `art\generated\characters\momi_dig.png`
8. Press Enter → repeat for next sprite

**Missing Sprites (14 total):**
- momi_dig (5)
- momi_happy (8)
- cinnamon_slam (12)
- philo_run_motivated (15)
- philo_bark_heal (16)
- philo_jealous (17)
- roomba_cranky (18)
- gnome_possessed (19)
- goose_angry (20)
- squirrel_evil (21)
- grass_seamless (22)
- sidewalk_seamless (23)
- street_asphalt (24)
- wood_floor (25)

---

## Quick Commands

**Generate one sprite:**
```powershell
cd "C:\Users\major\momi-chronicles"
python tools\gemini_automation.py --single 5
```

**Generate all missing characters:**
```powershell
python tools\gemini_automation.py --category characters
```

**Generate enemies:**
```powershell
python tools\gemini_automation.py --category enemies
```

---

## Key Files

| File | Purpose |
|------|---------|
| `tools/gemini_automation.py` | Playwright browser automation script |
| `art/prompts_v2_pixel_art.json` | 26 pixel art prompts (8 frames each) |
| `art/GENERATION_WORKFLOW.md` | Full workflow guide |
| `art/generated/characters/` | Output folder for sprites |

---

## When You Come Back

Say **"continue"** or **"run it"** and I'll start the browser automation!
