# Audio Files for Momi's Adventure

All audio files are `.wav` format. The AudioManager loads them automatically.

## Music Files (`music/` folder)

### Active Tracks (used by AudioManager)

| Filename | Description | Loop? |
|----------|-------------|-------|
| `title.wav` | Title screen music | Yes |
| `title_a.wav` / `title_b.wav` | Title screen A/B variants | Yes |
| `neighborhood.wav` | Neighborhood zone exploration | Yes |
| `neighborhood_a.wav` / `neighborhood_b.wav` | Neighborhood A/B variants | Yes |
| `neighborhood_morning_a/b.wav` | Morning time-of-day variant | Yes |
| `neighborhood_evening_a/b.wav` | Evening time-of-day variant | Yes |
| `neighborhood_night_a/b.wav` | Night time-of-day variant | Yes |
| `backyard.wav` | Backyard zone (tense) | Yes |
| `backyard_a.wav` / `backyard_b.wav` | Backyard A/B variants | Yes |
| `backyard_deep_a/b.wav` | Deep backyard area | Yes |
| `backyard_shed_a/b.wav` | Shed area | Yes |
| `combat.wav` | Battle music | Yes |
| `combat_a.wav` / `combat_b.wav` | Combat A/B variants | Yes |
| `boss_fight_a.wav` / `boss_fight_b.wav` | Boss battle music | Yes |
| `low_health_a.wav` / `low_health_b.wav` | Low health tension music | Yes |
| `surrounded_a.wav` / `surrounded_b.wav` | Surrounded by enemies | Yes |
| `winning_a.wav` / `winning_b.wav` | Winning combat state | Yes |
| `crow_theme_a.wav` / `crow_theme_b.wav` | Crow enemy theme | Yes |
| `first_encounter_a/b.wav` | First enemy encounter | Yes |
| `pause.wav` | Pause menu music | Yes |
| `pause_a.wav` / `pause_b.wav` | Pause A/B variants | Yes |
| `game_over.wav` | Game over screen | No |
| `game_over_a.wav` / `game_over_b.wav` | Game over A/B variants | No |
| `victory.wav` | Victory fanfare | No |
| `victory_a.wav` / `victory_b.wav` | Victory A/B variants | No |

### Named AI-Generated Tracks (Suno v4 — `momi_chronicle-*`)

These are named Suno tracks generated with specific zone/purpose prompts. Each has
a matching `.wav`, `.wav.txt` (metadata), and `.wav.import` (Godot import config).

| Filename Prefix | Purpose | Count |
|-----------------|---------|-------|
| `momi_chronicle-Backyard_Zone_Danger_*` | Backyard danger variant | 2 tracks |
| `momi_chronicle-Canine_Clash_*` | Combat music variant | 2 tracks |
| `momi_chronicle-Game_Over_Screen_*` | Game over variant | 2 tracks |
| `momi_chronicle-Momi's_Theme_(Emotional)_*` | Emotional cutscene music | 2 tracks |
| `momi_chronicle-Momi's_Theme_(Hero)_*` | Hero overworld theme | 2 tracks |
| `momi_chronicle-Neighborhood_Zone_*` | Neighborhood exploration | 2 tracks |
| `momi_chronicle-Pause_Screen_*` | Pause menu variant | 2 tracks |
| `momi_chronicle-Title_Screen_*` | Title screen variant | 2 tracks |
| `momi_chronicle-Victory_Fanfare_*` | Victory jingle variant | 2 tracks |

### Untitled AI-Generated Tracks (Suno v5 — `momichronicles2-Untitled-*`)

Six unassigned tracks from the v5 generation batch. These are candidates for
assignment to zones that need music (sewers, rooftops).

| UUID (short) | Suno Prompt | Duration | Tags | Recommendation |
|--------------|-------------|----------|------|----------------|
| **2bce5495** | Heartfelt 16-bit SNES character theme, loyal dog protecting home, bittersweet pixel art melody, gentle Super Nintendo emotional depth, small hero big heart, nostalgic retro RPG music, string samples and soft piano, 85 BPM | 2:22 | chiptune, retro gaming, soundtrack | **Rooftops candidate** — emotional, atmospheric, moonlit rooftop vibe |
| **a6cf7d0f** | *(same prompt as 2bce5495)* | 1:41 | chiptune, retro gaming, soundtrack | **Rooftops candidate** — same mood, shorter variant |
| **7678d381** | Brave little hero 16-bit SNES theme, determined French bulldog energy, pixel art protagonist melody, courageous but cute, marching rhythm with orchestral samples, loyal guardian vibes, Super Nintendo adventure style, 110 BPM | 2:33 | video game music, chiptune | Hero theme — could work as alternate neighborhood or overworld |
| **f2313b7a** | *(same prompt as 7678d381)* | 2:22 | video game music, chiptune | Hero theme variant — paired with 7678d381 |
| **c57dcc13** | Mischievous 16-bit SNES villain theme, sneaky raccoon troublemakers, playfully menacing Super Nintendo style, pixel art antagonist music, trash panda chaos energy, comedic but threatening, minor key with jazzy samples, 95 BPM | 0:50 | chiptune, jazz, instrumental | **Sewers candidate** — villain/raccoon theme fits underground lair |
| **e019e246** | *(same prompt as c57dcc13)* | 1:00 | chiptune, jazz, instrumental | **Sewers candidate** — same mood, slightly longer |

**Listening links (Suno CDN):**
- 2bce5495: https://cdn1.suno.ai/2bce5495-d428-4037-85f8-a9f9a5e8b2e7.mp3
- a6cf7d0f: https://cdn1.suno.ai/a6cf7d0f-21e8-445b-91b5-155de1538a0d.mp3
- 7678d381: https://cdn1.suno.ai/7678d381-74f7-4d8c-ae33-44aad401c9b5.mp3
- f2313b7a: https://cdn1.suno.ai/f2313b7a-a40f-41b9-b479-3713d4a9f3eb.mp3
- c57dcc13: https://cdn1.suno.ai/c57dcc13-4f91-4ae5-8658-279ccfdb4689.mp3
- e019e246: https://cdn1.suno.ai/e019e246-12f9-49db-b133-79f743560e44.mp3

## SFX Files (`sfx/` folder) — 34 files

| Filename | Description |
|----------|-------------|
| `attack.wav` | Player attack swoosh |
| `block.wav` | Block/guard sound |
| `buff_applied.wav` | Buff effect applied |
| `buff_expired.wav` | Buff effect wore off |
| `charge_release.wav` | Charge attack released |
| `charge_start.wav` | Charge attack started |
| `coin.wav` | Coin pickup |
| `combo_complete.wav` | Combo chain completed |
| `dodge.wav` | Dodge/roll sound |
| `enemy_death.wav` | Enemy defeated |
| `enemy_hurt.wav` | Enemy takes damage |
| `footstep_run.wav` | Running footstep |
| `footstep_walk.wav` | Walking footstep |
| `ground_pound.wav` | Ground pound attack |
| `guard_broken.wav` | Guard/shield broken |
| `health_pickup.wav` | Health item pickup |
| `heartbeat.wav` | Low health heartbeat |
| `hit.wav` | Attack connects |
| `inventory_close.wav` | Inventory menu closed |
| `inventory_open.wav` | Inventory menu opened |
| `item_equip.wav` | Equipment changed |
| `item_use.wav` | Consumable used |
| `level_up.wav` | Level up fanfare |
| `menu_close.wav` | Menu closed |
| `menu_navigate.wav` | Menu cursor move |
| `menu_open.wav` | Menu opened |
| `menu_select.wav` | Menu button press |
| `parry.wav` | Successful parry |
| `player_death.wav` | Player dies |
| `player_hurt.wav` | Player takes damage |
| `ring_menu_close.wav` | Ring menu closed |
| `ring_menu_open.wav` | Ring menu opened |
| `shop_purchase.wav` | Shop item purchased |
| `zone_transition.wav` | Entering new zone |

## Missing Audio

The following zones are wired in AudioManager but have **no `.wav` files** yet:

- **Sewers zone** — mapped to `sewers` track key, needs `sewers_a.wav` + `sewers_b.wav`
  - Recommended candidates: **c57dcc13** (0:50) and **e019e246** (1:00) — raccoon villain theme, jazzy minor key
- **Rooftops zone** — mapped to `rooftops` track key, needs `rooftops_a.wav` + `rooftops_b.wav`
  - Recommended candidates: **2bce5495** (2:22) and **a6cf7d0f** (1:41) — heartfelt emotional theme, piano+strings

The remaining hero-theme tracks (**7678d381**, **f2313b7a**) could serve as alternate
neighborhood/overworld music or be held for future use.

## Cleanup Log

- **Phase 44**: Deleted 22 orphaned `.wav.txt` metadata files (no matching `.wav` existed).
  Kept 6 `.wav.txt` files that have matching audio. Wired rooftops zone in AudioManager.
