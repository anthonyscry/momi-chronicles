# Suno Automation for Momi's Adventure

Automates pasting music prompts into Suno.com so you don't have to copy/paste manually.

## Quick Start

### Option 1: Double-click to run
```
Double-click: run_suno.bat
```

### Option 2: Command line
```bash
cd C:\Users\major\momi-chronicles\tools
python suno_automation.py
```

## First Time Setup

If you haven't used Playwright before:
```bash
pip install playwright
playwright install chromium
```

## Usage

### Generate Essential Tracks (Recommended First)
```bash
python suno_automation.py --category essential
```
This generates the 7 core tracks:
- Title Screen
- Neighborhood Zone
- Backyard Zone
- Combat Music
- Game Over
- Victory Fanfare
- Pause Menu

### Other Categories
```bash
# Character themes (Momi, Raccoons, Crows)
python suno_automation.py --category character_themes

# Zone variations (morning/evening/night, shed)
python suno_automation.py --category zone_variations

# Combat variations (boss, surrounded, low health)
python suno_automation.py --category combat_variations

# ALL tracks
python suno_automation.py --category all
```

### See All Prompts
```bash
python suno_automation.py --list
```

### Generate a Single Track
```bash
python suno_automation.py --single 0  # First prompt
python suno_automation.py --single 3  # Fourth prompt
```

## How It Works

1. **Browser opens** to Suno.com
2. **Sign in** if needed (the script will wait)
3. For each track:
   - Script fills in the **Style** field automatically
   - You click **Create** button
   - Wait for generation (~30-60 seconds)
   - Press **Enter** in terminal for next track
4. After all tracks: **Download** from your Suno library

## Tips

- **Suno Free Tier**: 50 credits/day = ~10 songs
- **Generate 2 versions** of each track for A/B testing
- **Instrumental only**: The script tries to toggle this automatically
- **Download as WAV** for best quality

## File Locations

| File | Purpose |
|------|---------|
| `suno_automation.py` | Main automation script |
| `suno_prompts.json` | All prompts in JSON format |
| `run_suno.bat` | Easy launcher for Windows |

## After Generating

1. Download tracks from Suno library
2. Rename to match game expectations:
   - `title.wav`
   - `neighborhood.wav`
   - `backyard.wav`
   - `combat.wav`
   - `game_over.wav`
   - `victory.wav`
   - `pause.wav`
3. Place in `assets/audio/music/`
4. Run game and test!

## Troubleshooting

### "Playwright not installed"
```bash
pip install playwright
playwright install chromium
```

### "Can't find styles input"
The Suno UI may have changed. Try:
1. Click "Advanced" manually
2. Paste the prompt from the terminal output

### "Need to sign in"
- Script will pause and wait
- Sign in via Google/Discord/etc
- Press Enter in terminal to continue
