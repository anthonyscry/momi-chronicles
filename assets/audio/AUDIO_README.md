# Audio Files for Momi's Adventure

Drop your Suno-generated audio files here. The AudioManager will automatically load them.

## Required File Format
- **Format**: `.ogg` (OGG Vorbis) - recommended for Godot
- **Alternative**: `.wav` or `.mp3` (update paths in `audio_manager.gd` if using different format)

## Music Files (`music/` folder)

| Filename | Description | Loop? | Duration |
|----------|-------------|-------|----------|
| `title.ogg` | Title screen music | Yes | 90 sec |
| `neighborhood.ogg` | Neighborhood zone exploration | Yes | 2 min |
| `backyard.ogg` | Backyard zone (tense) | Yes | 2 min |
| `combat.ogg` | Battle music (future use) | Yes | 90 sec |
| `game_over.ogg` | Game over screen | No | 20 sec |
| `victory.ogg` | Victory fanfare | No | 15 sec |
| `pause.ogg` | Pause menu (optional) | Yes | 60 sec |

## SFX Files (`sfx/` folder)

| Filename | Description | Duration |
|----------|-------------|----------|
| `attack.ogg` | Player attack swoosh | 0.5 sec |
| `hit.ogg` | Attack connects | 0.2 sec |
| `player_hurt.ogg` | Player takes damage | 0.3 sec |
| `enemy_hurt.ogg` | Enemy takes damage | 0.3 sec |
| `enemy_death.ogg` | Enemy defeated | 0.5 sec |
| `player_death.ogg` | Player dies | 0.5 sec |
| `dodge.ogg` | Dodge/roll sound | 0.3 sec |
| `menu_select.ogg` | Menu button press | 0.1 sec |
| `menu_navigate.ogg` | Menu cursor move | 0.1 sec |
| `zone_transition.ogg` | Entering new zone | 1 sec |
| `health_pickup.ogg` | Collecting health | 0.5 sec |

## Converting Suno Files

Suno outputs MP3. To convert to OGG:

### Option 1: Online Converter
1. Go to https://cloudconvert.com/mp3-to-ogg
2. Upload your MP3
3. Download OGG

### Option 2: FFmpeg (Command Line)
```bash
ffmpeg -i input.mp3 -c:a libvorbis -q:a 6 output.ogg
```

### Option 3: Audacity
1. Open MP3 in Audacity
2. File > Export > Export as OGG
3. Quality: 6 (default is fine)

## Setting Up Looping

For music that should loop:

1. In Godot, select the `.ogg` file in FileSystem
2. In Import tab, check "Loop"
3. Click "Reimport"

Or create `.import` files - see `music/neighborhood.ogg.import.example`

## Quick Test

After adding files, run the game:
- Title screen should play `title.ogg`
- Starting game should play `neighborhood.ogg`
- Entering backyard should crossfade to `backyard.ogg`
- Attacking should play `attack.ogg`
- Getting hit should play `player_hurt.ogg`

## Troubleshooting

**No sound?**
1. Check file names match exactly (case-sensitive)
2. Check files are in correct folders
3. Check AudioManager is loaded (should print "AudioManager ready" in console)
4. Check volume isn't muted in pause menu

**Music doesn't loop?**
1. Select the file in Godot
2. Import tab > enable "Loop"
3. Click "Reimport"

**Wrong format?**
- Update paths in `autoloads/audio_manager.gd` (lines 20-40)
- Change `.ogg` to `.mp3` or `.wav`
