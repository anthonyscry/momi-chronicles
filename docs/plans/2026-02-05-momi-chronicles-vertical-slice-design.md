# MOMI-CHRONICLES Vertical Slice Design (Neighborhood -> Sewers)

## Goal
Define a shippable 30-60 minute vertical slice that feels Chrono Trigger / Stardew-ish in charm, while remaining realistic for a small solo build. Scope emphasizes a single hub, a single dungeon zone, and a short narrative payoff.

## High-Concept Pitch
MOMI-CHRONICLES is a cozy action RPG where a small-town canine watch crew uncovers a creeping threat beneath their neighborhood. You play Momi, a scrappy French Bulldog balancing everyday kindness with sudden bursts of heroics. By day, you gather rumors, help neighbors, and prep in the town hub; by night, you descend into a moody sewer labyrinth to confront scavenger gangs and a looming Raccoon King. The vibe blends Chrono Trigger's adventure pacing with Stardew's warmth and routine, delivering short, satisfying loops with a strong found-family core.

## Pillars
- Cozy community, real stakes
- Readable, playful combat
- Progress through relationships

## Vertical Slice Spec (30-60 minutes)

### Core Loop (minute-to-minute)
Start in the Neighborhood hub, scan quest markers and dialogue hints, accept a short objective, buy a consumable or equip a new piece, then transition into the Sewers zone. Inside, fight small packs, collect one key item, solve a simple route choice (two corridors, one locked by a lever), and clear a mini-boss arena. Return to town, turn in, get a reward and new hook, and repeat once to build momentum toward the final challenge.

### Quests / Objectives (3)
1) Missing Bait (Fetch): recover a bait box from the sewers after defeating three Sewer Rats.
2) Echoes in the Pipes (Investigation): find the source of a voice and return with a clue.
3) Guard the Grate (Combat/Defense): survive a timed ambush wave and restore a broken valve.

### Major Challenge
Emotional set-piece: The Echo Room. A short, quiet cutscene in the sewer chapel where Momi hears a recording from a past watch captain. It reveals why the Raccoon King is hoarding items and grounds the slice in community stakes.

### Locations
- Town hub: Neighborhood (NPCs, shop, quest turn-ins, training dummy)
- Dungeon zone: Sewers (3 micro-rooms + Echo Room + mini-boss arena)

## World + Story Bible (Short)

### Setting Summary
A cozy urban neighborhood with a sunny park and aging storm drains. The surface is safe and friendly, but the underground infrastructure hides a scavenger syndicate of raccoons stealing items and destabilizing daily life.

### Main Cast (6)
- Momi (protagonist): brave and stubborn; secret: once failed a rescue and overcompensates; hook: tries to prove she can lead.
- Cinnamon (tank companion): loyal and protective; secret: terrified of water; hook: courage grows when Momi trusts her.
- Philo (support companion): chill and funny; secret: tracking raccoon patterns; hook: sees the threat as organized.
- Gertrude (elder): neighborhood historian; secret: knows the sewer chapel's history; hook: stories reveal clues.
- Maurice (mail carrier): friendly connector; secret: delivered mystery packages unknowingly; hook: must choose to help or stay neutral.
- Henderson (gruff neighbor): distrustful; secret: lost something personal; hook: reputation-based trust arc.

### Tone Guide
Warm, earnest, and slightly melancholy. Like a Saturday morning adventure with a soft undercurrent of mystery. The world feels kind but frayed, and the player helps stitch it back together.

## Systems Design

### Combat Style
Hybrid active-time (real-time action with brief tactical pauses via ring menu). Minimum viable: light hit-stun, clear telegraphs, 3-hit combo, dodge roll, and guard/parry with a simple guard meter.

### Progression
- Levels 1-5 with small stat boosts and one ability unlock (ground pound at level 3).
- Gear: 3 slots (weapon, charm, boots) with flat bonuses.
- Rewards: quests grant coins, EXP, and small reputation boosts that unlock dialogue tiers.

### Slice Systems (max 2)
- Social (reputation): unlocks dialogue tiers and quest branches.
- Crafting (minimal): two shop recipes using found items (Rat Glands + Herbs = Antidote, Rusted Valve + Oil = Repair Kit).
Connection to loop: social unlocks quests; crafting provides safety valves for sewer encounters.

## Art Direction Plan

### Pixel Art Constraints
- Tile size: 16x16
- Sprite size: 24x24 or 32x32
- Anim frames: idle 4, walk 6, attack 6, hurt 4, death 4
- Palette: warm neighborhood (cream, terracotta, muted greens), cool sewer (teal, navy, moss), accents for enemies (yellow/orange eyes, toxic green). Keep <= 32 colors per tileset.

### UI Style Guide
- Fonts: primary rounded pixel font; secondary small caps for headers.
- Panels: soft rounded rectangles, 2px outline, subtle drop shadow.
- Icons: bold silhouettes with 1-2 color highlights.
- Contrast: text always on dark panel; highlight color for interact prompts.

### Asset List (Vertical Slice)
Characters: Momi, Cinnamon, Philo, Gertrude, Maurice, Henderson.
Enemies: Sewer Rat, Shadow Creature, Alpha Raccoon (mini-boss).
Tilesets: Neighborhood (houses, park path, fence, shop), Sewers (pipes, grates, water, sludge).
Props: mailbox, bulletin board, sewer hatch, valve wheel, altar/echo chamber.
VFX: hit spark, guard flash, poison drip, echo shimmer, quest marker icon.
UI: quest tracker frame, dialogue box, ring menu, inventory panel.

## Tech Plan (Godot 4.5)

### Scene Architecture
- Neighborhood and Sewers are separate scenes connected by ZoneExit.
- NPCs use DialogueNPC pattern with data-driven IDs.
- Enemies use component-based EnemyBase + StateMachine pattern.
- Echo Room is a sub-area within Sewers with its own trigger.

### Save System
Use existing SaveManager v3 with quest/reputation flags and auto-save on zone entry and boss defeat.

### Dialogue System
JSON dialogue per NPC loaded into DialogueManager; choices emit Events for quest and reputation updates.

### Content Pipeline
JSON for dialogues/quests, GDScript databases for items/equipment. Favor data-driven configuration and reuse of existing autoloads.

## Production Plan

### 4-Week Milestones
1) Week 1: finalize vertical slice design, quests, dialogue, Echo Room event.
2) Week 2: implement slice content (quests, sewer layout, mini-boss arena).
3) Week 3: polish (UI, pacing, reward tuning, VFX).
4) Week 4: playtest + bugfix + balance pass + capture trailer GIFs.

### 12-Week Milestones
1) Weeks 1-4: vertical slice complete + polish.
2) Weeks 5-8: expand content (extra quests, second mini-boss, more NPCs).
3) Weeks 9-12: art/audio upgrade, narrative pass, build pipeline + marketing assets.

## Risks and Cuts

### Risks
- Scope creep in quests/dialogues.
- Overbuilding combat complexity.
- Art pipeline delays.

### Cut List (drop first)
- Crafting recipes beyond 2.
- Extra enemy types.
- Additional dialogue branches.
- Optional side rooms in the sewer.

## Architecture and Data Flow

### Components
- Player: CharacterBody2D + StateMachine + Hitbox/Hurtbox + Guard component.
- Enemies: EnemyBase + StateMachine + Hitbox/Hurtbox + DetectionArea.
- NPCs: DialogueNPC script (Area2D) + interaction prompt.
- Pickups: QuestItemPickup (Area2D) gated by quest state.

### Data Flow
Player interaction -> Events.dialogue_started -> QuestManager objective checks -> Quest updates -> UI updates via Events.quest_updated. Zone transitions -> Events.zone_entered -> auto-save + objective checks. Combat -> Events.enemy_defeated -> quest checks and reputation boosts.

### Error Handling
- Dialogue/quest JSON validation with defaults on missing keys.
- Save load uses .get() defaults (v3 compatibility).
- Missing resource paths log via DebugLogger and fall back to safe defaults.

### Testing
- Manual playtest: complete all three quests, confirm Echo Room set-piece trigger, confirm rewards and reputation updates, verify save/load at hub and sewer entry.
- Run existing HUD and quest UI checks; verify no console errors in zone transitions.

## Next Actions (Checklist)
1) Confirm the 3 quests and name them in quest JSON.
2) Draft 6-8 dialogue nodes per NPC (Gertrude/Maurice/Henderson).
3) Map Sewer layout: 3 rooms + Echo Room + mini-boss arena.
4) Implement Echo Room cutscene trigger.
5) Add quest pickups (bait box, valve wheel, echo token).
6) Place mini-boss encounter + reward chest.
7) Add 2 crafting recipes in shop.
8) Tune combat pacing in sewers (enemy density, patrol paths).
9) Update UI: quest tracker + reward popup styling.
10) Run a 30-60 minute playtest and log pacing issues.
