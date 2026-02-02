# Momi's Adventure - Project State

## Current Position

Phase: 43 — Title Screen Fix (COMPLETE)
Plan: 43-01 (complete)
Status: Phase 43 COMPLETE — Title screen New Game fixed, all paths verified.
Last activity: 2026-02-01 - Fixed title screen placeholder, verified all game entry paths

Progress: ██████████████████████████████████████████░░░░░░░░░░░░░░░░ ~87% (to v2.0)

## Current Milestone: v1.9 Stabilization & Audio

| Phase | Name | Requirements | Status |
|-------|------|-------------|--------|
| 43 | Title Screen Fix | Fix New Game placeholder, verify all paths | ✅ COMPLETE |
| 44 | Audio Completion | Curate tracks, fill zone gaps, SFX audit | Not started |

## Accumulated Decisions (from v1.0-v1.5)
| Decision | Rationale |
|----------|-----------|
| Component-based architecture | Composable, reusable systems |
| Events autoload signal bus | Decoupled communication |
| call-down-signal-up pattern | Clear data flow |
| Path-based extends (not class_name) | Avoids autoload scope issues |
| Programmatic UI (code-built in _ready) | Full control, matches ring_menu pattern |
| preload() for all scene references | Eliminates runtime stutter |
| Save version v3 with .get() defaults | Backward compatible migration |
| First-in-first-revived ordering for Revival Bone | Simple, deterministic knocked_out.keys()[0] |
| Cache scenes with load() at zone init | Dynamic scene paths can't use preload(); init-time load() is equivalent |
| Re-emit Events signals for HUD refresh on load | All HUD elements already listen — zero child script changes needed |
| Clear only Inventory.active_buffs on restart | Only autoload child state survives scene reload |
| Dual-audience PROJECT.md (overview + technical) | Accessible to anyone; detailed for developers |
| White background prompts for AI art generation | AI generators ignore hex color requests; flood-fill from corners works reliably |
| Suno pattern for Gemini automation | Consistent Playwright sync API, argparse CLI, try/except import guard |
| 3-tier image download fallback | Gemini DOM varies; blob extraction → JS fetch → manual save prevents crashes |
| DialogueNPC Area2D pattern for story NPCs | Matches ShopNPC pattern; reusable, programmatic, no .tscn per NPC |
| Reputation per NPC (0-100) in GameManager | Simple dict, saved/loaded, mini-boss defeats boost all +10 |
| Programmatic quest definitions (code, not .tres) | Matches ItemDatabase/EquipmentDatabase pattern |
| Event-driven quest objectives | dialogue_started + zone_entered signals drive completion |
| NPC quest markers with hardcoded map | Simple for 2 quests, generalize in Phase 42 |
| Companions already have unique abilities | Momi=Zoomies, Cinnamon=Overheat/Block, Philo=Motivation/Heal — no "ability expansion" needed |
| AudioManager is feature-complete in code | 1079 lines: crossfade, health-based, combat, zone, time-of-day, A/B testing — needs audio assets not code |

## Session Continuity
Last session: 2026-02-01
Stopped at: Phase 43 COMPLETE — Title screen fixed
Next: Phase 44 — Audio Completion (curate tracks, fill zone gaps, SFX audit)

## Known Bugs
No known blockers. All previously identified bugs resolved or confirmed as false positives.

---

## Phase 42 Completed Summary

**42-01 (Quest Engine Extensions):**
- Added `requires_prior_complete` flag to QuestObjective for sequential objectives
- Added `quest_giver_id` to QuestData for data-driven NPC-quest association
- Added `objective_requires_prior` array to QuestData
- Wired Events.enemy_defeated → _check_enemy_kill_objectives (supports "any" and specific types)
- Wired Events.pickup_collected → _check_item_collect_objectives
- All 4 objective checkers respect requires_prior_complete flag
- Reputation rewards in _grant_rewards ({"reputation": {"npc_id": amount}})
- Replaced hardcoded quest auto-start with generic quest_giver_id loop
- Added `npc_id` stable identifier to dialogue_npc.gd, removed hardcoded npc_quest_map
- NPC quest markers fully data-driven ("!" from quest_giver_id, "?" respects requires_prior)
- Set npc_id on all 4 neighborhood NPCs
- Progress counts in QuestTracker ("Objective (3/5)") and QuestLog ("[✓] Objective (3/5)")
- Created quest_item_pickup.gd component (Area2D, quest-gated visibility, collection animation)

**42-02 (Quest Content):**
- 7 new quests (q3-q9) covering all 5 quest types: Fetch, Elimination, Delivery, Chain (4-part)
- Henderson reputation gate (>= 30) for pest_control quest
- Lost ball pickup in Backyard (300, 80), quest-gated to find_lost_ball
- Mail package pickup in Neighborhood (420, 310), quest-gated to special_delivery
- Total: 9 quests, 565 coins + 280 EXP in new rewards, reputation gains across all NPCs

---

## Phase 41 Completed Summary

**41-01 (Quest Backend Wiring):**
- Fixed Events.quest_updated signal to 2 params (quest_id, objective_index)
- Replaced all print() → DebugLogger.log_system() in quest_manager.gd
- Extended QuestObjective with trigger_type, trigger_id, target_count, current_count + advance() method
- Updated QuestData with objective_trigger_types/ids/counts arrays
- Added 2 sample quests: "Meet the Neighbors" (talk to 3 NPCs) + "Community Watch" (visit 2 zones)
- Wired Events.dialogue_started → auto-start quests + complete dialogue objectives
- Wired Events.zone_entered → complete zone objectives
- Wired SaveManager for quest persistence (save/load)
- Wired GameManager.reset_game() for quest state reset

**41-02 (Quest UI Integration):**
- Added QuestTracker to GameHUD (top-right corner, auto-shows on active quest)
- Added quest reward notification popup (gold text, slide-up fade animation)
- Added "Quest Log" option to ring menu OPTIONS ring
- Quest log opens as dark overlay (CanvasLayer 100) with quest_log.tscn
- ESC/dodge/ring_menu closes quest log overlay
- Added NPC quest markers: yellow "!" for available quests, gray "?" for in-progress objectives
- Markers update dynamically on quest events + bob animation
- Fixed print() → DebugLogger in ring_menu.gd

---

## Phase 40 Completed Summary

**40-01 (Story NPCs + Dialogue Content):**
- Created `characters/npcs/dialogue_npc.gd` — reusable Area2D-based dialogue NPC script
  - Follows ShopNPC pattern: collision detection, [E] Talk prompt, body bob animation
  - Programmatic visuals: colored oval body + head shapes, name label, prompt label
  - Connects to DialogueManager.start_dialogue() on interact
  - Listens to Events.dialogue_ended for re-enabling interaction
- Created 4 dialogue JSON files with branching choices (5-7 nodes each):
  - `resources/dialogues/gertrude.json` — Old Lady Gertrude (lore hints, Raccoon King warnings)
  - `resources/dialogues/maurice.json` — Mailman Maurice (neighborhood news, delivery hooks)
  - `resources/dialogues/kids_gang.json` — Kids Gang (playful fans, scouting reports)
  - `resources/dialogues/henderson.json` — Mr. Henderson (3 tiers: grumpy, warming, friendly)
- Placed all 4 NPCs in neighborhood zone at specified coordinates:
  - Gertrude (120, 220) — near houses, lavender color
  - Maurice (400, 300) — main road, blue color
  - Kids Gang (180, 480) — park area, orange color
  - Mr. Henderson (280, 180) — north houses, brown color

**40-02 (Reputation System):**
- Added `npc_reputation` Dictionary to GameManager (0-100 scale per NPC)
  - Default values: gertrude=20, maurice=20, kids_gang=30, henderson=0
  - API: get_reputation(), set_reputation(), add_reputation(), boost_all_reputation()
- Added `reputation_changed(npc_id, old_value, new_value)` signal to Events bus
- Wired mini_boss_defeated → boost_all_reputation(10) in GameManager
- Henderson dialogue is reputation-gated at zone load: grumpy (0-29), warming (30-59), friendly (60+)
- Reputation persists via save/load (added to GameManager.save_game() + SaveManager)
- Reputation resets on new game via GameManager.reset_game()

---

## Phase 39 Completed Summary

**39-01 (Boss Door Gating):**
- Added MINI_BOSSES_REQUIRED = 2 constant to sewers.gd
- Added _count_mini_bosses_defeated() helper function
- Boss door shows "X/2 BOSSES" status (orange) when locked, "ENTER..." (green) when unlocked
- Door color changes: dark when locked, brighter when unlocked
- ZoneExit to boss_arena only created when gate requirements met

**39-02 (Victory Screen + Re-entry):**
- Added game_complete flag to GameManager (persists via save, resets on new game)
- Boss arena re-entry check: if boss_defeated, shows peaceful message + exit (no respawn)
- Victory screen overlay: gold title, stats (level/coins/mini-bosses), flavor text, two buttons
- Continue Playing: saves, dismisses overlay, spawns exit
- Title Screen: saves, changes to title_screen.tscn
- Fixed bare print() → DebugLogger.log_zone()

---

## Phase 38 Completed Summary

**38-01 (AutoBot Rooftops):**
- AutoBot game loop: neighborhood → backyard → rooftops → sewers → boss_arena
- Platform-based patrol points for rooftops zone

**38-02 (Encounter Waves):**
- Wave-based enemy spawning (trigger on walkway crossing)
- Encounter announcement text per platform area

---

## Phase 37 Completed Summary

**37-01 (Zone Foundation):**
- Verified existing Rooftops zone (835 lines, 4 platforms, 3 walkways, moonlit atmosphere)
- Fixed GameManager reset_game() to include pigeon_king in mini_bosses_defeated
- Added Neighborhood → Rooftops ladder + zone exit with visual + "ROOFTOPS" label

**37-02 (Enemies + Pigeon King):**
- Placed ~20 enemies across 4 platforms (3 pigeon flocks, 4 gnomes, 5 roof rats)
- Created Pigeon King mini-boss (120 HP, 2 attack patterns: SwoopDive + Reinforcement)
- Added mini-boss trigger Area2D with gold octagon warning at Boss Overlook

---

## ALL PREVIOUS MILESTONES COMPLETE

| Milestone | Phases | Status |
|-----------|--------|--------|
| v1.0 MVP | 1-7 | ✅ COMPLETE |
| v1.1 Combat & Progression | 8-11 | ✅ COMPLETE |
| v1.2 New Mechanics | 12-16 | ✅ COMPLETE |
| v1.3 Content & Variety | 17-20 | ✅ COMPLETE |
| v1.3.1 Tech Debt & Polish | 21-22 | ✅ COMPLETE |
| v1.3.2 Companion Save Fix | 23 | ✅ COMPLETE |
| v1.4 AutoBot Overhaul | 24-27 | ✅ COMPLETE |
| v1.5 Integration & Quality Audit | 28-29 | ✅ COMPLETE |
| v1.6 Visual Polish | 30-35 | ✅ COMPLETE |
| v1.7 Rooftops Zone | 36-39 | ✅ COMPLETE |
| v1.8 Quest System | 40-42 | ✅ COMPLETE |
| 36-01 Pigeon Enemy | Flock behavior, aerial swoop | ✅ COMPLETE |
| 36-02 Garden Gnome | Stationary turret, bomb throwing | ✅ COMPLETE |
| 37-01 Zone Foundation | Rooftops layout + transitions | ✅ COMPLETE |
| 37-02 Enemies + Pigeon King | Enemy placement + mini-boss | ✅ COMPLETE |
| 38-01 AutoBot Rooftops | AutoBot zone awareness | ✅ COMPLETE |
| 38-02 Encounter Waves | Wave spawning + encounter announcements | ✅ COMPLETE |
| 39-01 Boss Door Gating | Mini-boss gate for sewers boss door | ✅ COMPLETE |
| 39-02 Victory Screen | Victory overlay + re-entry + game_complete | ✅ COMPLETE |
| 40-01 Story NPCs | 4 NPCs + dialogue trees + zone placement | ✅ COMPLETE |
| 40-02 Reputation System | Reputation tracking + Henderson gating + save/load | ✅ COMPLETE |
| 41-01 Quest Backend | Signal fixes, trigger metadata, sample quests, save/load | ✅ COMPLETE |
| 41-02 Quest UI | HUD tracker, ring menu journal, NPC markers, reward popup | ✅ COMPLETE |
| 42-01 Quest Engine | New triggers, sequential objectives, data-driven markers, pickup component | ✅ COMPLETE |
| 42-02 Quest Content | 7 new quests (fetch, elimination, delivery, chain), zone pickups | ✅ COMPLETE |

---

*v1.8 Quest System started: 2026-02-01*
