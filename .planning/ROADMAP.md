# Momi's Adventure - Development Roadmap

## Phase 1: Foundation
**Goal**: Playable character that can move around a test zone

**Requirements Covered**: MOV-01, MOV-02, MOV-03, MOV-04, CAM-01, CAM-02, CAM-03, STA-01, STA-03, TEC-03, TEC-04

**Deliverables**:
- Project configured for pixel art
- Input actions defined
- State machine system
- Player with movement states (idle, walk, run)
- Camera following player
- Test zone for development

---

## Phase 2: Combat Core
**Goal**: Player can attack and damage enemies

**Requirements Covered**: CMB-01, CMB-02, CMB-05, CMB-06, HLT-01, HLT-02, ANI-04, STA-02

**Deliverables**:
- Hitbox/Hurtbox component system
- Health component
- Attack state for player
- Damage dealing and receiving
- Visual feedback (flash on hit)

---

## Phase 3: Enemy Foundation
**Goal**: Basic enemy that can be fought

**Requirements Covered**: ENM-01, ENM-02, ENM-03, ENM-04, ENM-05, ANI-07

**Deliverables**:
- Base enemy class
- Raccoon enemy with AI
- Enemy states (idle, patrol, chase, attack, hurt, death)
- Contact damage

---

## Phase 4: Combat Polish
**Goal**: Combat feels complete and satisfying

**Requirements Covered**: CMB-03, CMB-04, HLT-04, ANI-05, ANI-06, ENM-06

**Deliverables**:
- Dodge/roll state with i-frames
- Hurt state with i-frames
- Second enemy type (crow)
- Knockback on hit

---

## Phase 5: UI/HUD
**Goal**: Player can see health and access menus

**Requirements Covered**: UI-01, UI-02, UI-03, UI-04, UI-05, HLT-05

**Deliverables**:
- Health bar HUD
- Pause menu
- Title screen
- Game over screen

---

## Phase 6: World Building
**Goal**: Actual playable zone with structure

**Requirements Covered**: WLD-01, WLD-02, WLD-03, WLD-04, MOV-05, CAM-04

**Deliverables**:
- Proper tilemap system
- Collision layers setup
- First real zone (neighborhood area)
- Zone transitions

---

## Phase 7: Polish & Audio
**Goal**: Game feels complete

**Status**: PLANNED - Ready for execution

**Requirements Covered**: AUD-01, AUD-02, AUD-03, AUD-04, AUD-05, HLT-03, STA-04, STA-05, TEC-01, TEC-02, TEC-05

**Plans:**
- [x] 07-01-PLAN.md - Audio Placeholder & Integration
- [x] 07-02-PLAN.md - Game Flow & Death State
- [x] 07-03-PLAN.md - Final Polish & Testing

**Deliverables**:
- Background music (placeholder, user can upgrade with Suno)
- Sound effects (placeholder, user can upgrade)
- Death state and game over flow verified
- Performance optimization
- Windows export
- Final testing

---

## Milestone: v1.0 MVP ✅
All 47 requirements implemented. Game playable from start to game over.

---

# v1.1 COMBAT & PROGRESSION

---

## Phase 8: Combo Attack System
**Goal**: Fluid attack chains with timing-based combos

**Deliverables**:
- 3-hit combo chain (light → medium → heavy)
- Combo timing window (0.4s between attacks)
- Visual feedback (flash, screen shake escalation)
- Damage scaling per combo hit (1x → 1.25x → 1.75x)
- Combo counter UI

**Plans:**
- [ ] 08-01-PLAN.md — Combo state machine & timing
- [ ] 08-02-PLAN.md — Combo UI & visual feedback

---

## Phase 9: EXP & Level Up System
**Goal**: Progression system that rewards combat

**Deliverables**:
- EXP gained from defeating enemies (10-50 based on enemy type)
- Level system (1-20, scaling XP curve)
- Stat increases on level up (HP, Attack, Speed)
- EXP bar in HUD
- Level up visual/audio feedback
- Persistent stats in GameManager

**Plans:**
- [ ] 09-01-PLAN.md — EXP component & level math
- [ ] 09-02-PLAN.md — Level up effects & stat scaling
- [ ] 09-03-PLAN.md — HUD integration (EXP bar, level display)

---

## Phase 10: Special Abilities
**Goal**: Expanded combat moveset beyond basic attacks

**Deliverables**:
- Charge Attack (hold attack → release for power hit, 2.5x damage)
- Ground Pound (jump + down, AoE stun, unlocked at level 5)
- Ability cooldowns & UI indicators
- Unlock abilities via leveling

**Plans:**
- [ ] 10-01-PLAN.md — Charge attack state & mechanics
- [ ] 10-02-PLAN.md — Ground pound AoE & stun system
- [ ] 10-03-PLAN.md — Ability unlock & cooldown UI

---

## Phase 11: Boss Enemy & Arena
**Goal**: Epic boss encounter as backyard finale

**Deliverables**:
- Boss: Giant Raccoon King (200 HP, 3 attack patterns)
- Boss arena zone (locked doors until boss defeated)
- Boss health bar (large, top of screen)
- Phase transitions (enrage at 50% HP)
- Victory celebration & rewards

**Plans:**
- [ ] 11-01-PLAN.md — Boss enemy base & AI patterns
- [ ] 11-02-PLAN.md — Boss arena & zone lock
- [ ] 11-03-PLAN.md — Boss UI & phase transitions

---

## Milestone: v1.1 Combat & Progression ✅
Full combat expansion with combos, abilities, leveling, and boss fight.

---

# v1.2 NEW MECHANICS

---

## Phase 12: Block & Parry System ✅
**Goal**: Defensive combat options with skill-based parry mechanic

**Status**: COMPLETE

**Deliverables**:
- Block state (hold V to reduce incoming damage by 50%)
- Guard meter (depletes at 30/sec, regens at 20/sec after 1s delay)
- Parry window (first 0.15s of block = perfect parry)
- Perfect parry reflects 50% damage back, stuns attacker 1s
- Guard bar UI in HUD (fades when full, solid when depleting)

**Plans:**
- [x] 12-01-PLAN.md — Block state & guard meter component
- [x] 12-02-PLAN.md — Parry mechanics & guard bar UI

---

## Phase 13: Items & Pickups ✅
**Goal**: Collectible items that drop from enemies

**Status**: COMPLETE

**Deliverables**:
- Health pickup with magnet effect (heart, restores 20 HP)
- Coin pickup (currency for future shop)
- Enemy drop tables (configurable per enemy type)
- Drop spawning on enemy death
- Pickup collection effects (sound, particles)
- Coin counter in HUD

**Plans:**
- [x] 13-01-PLAN.md — Enhance health pickup with magnet & signals
- [x] 13-02-PLAN.md — Coin system & enemy drop tables
- [x] 13-03-PLAN.md — Coin counter HUD & collection effects

---

## Phase 14: Save System ✅
**Goal**: Persist player progress between sessions

**Status**: COMPLETE

**Deliverables**:
- SaveManager autoload (save/load logic)
- Save data: level, EXP, coins, current zone, boss defeated flags
- Auto-save on zone transitions
- Manual save from pause menu
- Load game option on title screen
- Single save slot (simple, no slot management)

**Plans:** 2 plans

Plans:
- [x] 14-01-PLAN.md — SaveManager autoload with atomic write & backup
- [x] 14-02-PLAN.md — Auto-save triggers & UI integration (title, pause)

---

## Phase 15: UI Testing Automation ✅
**Goal**: Automated testing for all UI flows and HUD elements

**Status**: COMPLETE

**Deliverables**:
- UITester mode in AutoBot (F2 to toggle)
- Test scenarios: title → gameplay → pause → game over → retry
- HUD verification (health bar, guard bar, coin counter, EXP bar)
- Menu interaction tests (button clicks, slider changes)
- New feature smoke tests (block/parry feedback, pickup collection)
- Test report output to console with pass rate percentage

**Plans:** 3 plans

Plans:
- [x] 15-01-PLAN.md — UITester foundation, F2 toggle, screenshot capture
- [x] 15-02-PLAN.md — HUD verification, title screen & gameplay scenarios
- [x] 15-03-PLAN.md — Pause/game over scenarios, new features smoke test, final reporting

---

## Phase 16: Ring Menu System (Secret of Mana Style)
**Goal**: Radial menu for items, equipment, companions, and game options

**Deliverables**:
- Ring menu UI (circular icon arrangement, smooth rotation)
- Multiple rings: Items, Equipment, Companions, Options
- Item system (usable consumables with effects)
- Equipment system (collars/accessories with stat bonuses)
- Companion system: The Bulldog Squad!
  - **Momi** (French Bulldog) - DPS, Zoomies mechanic
  - **Cinnamon** (English Bulldog) - Tank, Overheat mechanic
  - **Philo** (Boston Terrier) - Support, Lazy/Motivated mechanic
- Input: Tab to open, Left/Right to rotate, Up/Down to switch rings, Confirm to use

**Plans:** 4 plans

Plans:
- [ ] 16-01-PLAN.md — Ring menu core UI & navigation (Wave 1)
- [ ] 16-02-PLAN.md — Item system & usable consumables (Wave 2)
- [ ] 16-03-PLAN.md — Equipment system with 5 slots (Wave 2)
- [ ] 16-04-PLAN.md — Bulldog party system - all 3 fight together (Wave 3)

---

## Milestone: v1.2 New Mechanics ✅
Defensive combat, item drops, persistent progression, ring menu, and automated UI testing.

---

# v1.3 CONTENT & VARIETY

---

## Phase 17: New Enemy Types ✅
**Goal**: Three new enemies with unique combat behaviors that force different tactics

**Status**: COMPLETE

**Deliverables**:
- Stray Cat enemy (stealthy ambusher - hides, pounces from stealth, fast retreat)
- Sewer Rat enemy (swarm behavior - weak alone, spawns in packs of 3-4, poison bite)
- Shadow Creature enemy (mysterious threat from the lore - phases in/out, ranged shadow bolt)
- New enemy states: Stealth, Pounce, Swarm, Phase, RangedAttack
- Poison DoT system on HealthComponent
- Projectile system (shadow bolt, reusable)
- Unique drop tables per enemy type

**Plans:** 3 plans

Plans:
- [x] 17-01-PLAN.md — Stray Cat enemy with stealth/pounce/retreat (Wave 1)
- [x] 17-02-PLAN.md — Sewer Rat enemy pack with poison DoT system (Wave 1)
- [x] 17-03-PLAN.md — Shadow Creature with projectile system (Wave 2)

---

## Phase 18: Shop System ✅
**Goal**: Spend coins on items and equipment from a friendly shopkeeper

**Status**: COMPLETE

**Deliverables**:
- Shop NPC (Nutkin the Squirrel, placed in Neighborhood zone)
- Shop UI panel (browse, buy, sell interface with keyboard navigation)
- Price catalog for all existing items and equipment
- Sell-back system (50% of buy price)
- Restock mechanic (shop refreshes on zone re-entry)
- Stock tracking (limited quantities per restock cycle)
- Integration with existing coin/inventory systems

**Plans:** 3 plans

Plans:
- [x] 18-01-PLAN.md — Shop NPC (Nutkin) + price catalog + interaction system (Wave 1)
- [x] 18-02-PLAN.md — Shop UI panel with buy functionality (Wave 2)
- [x] 18-03-PLAN.md — Sell tab + restock mechanic + stock tracking (Wave 3)

---

## Phase 19: The Sewers Zone ✅
**Goal**: New dungeon zone with environmental hazards and tougher encounters

**Status**: COMPLETE

**Deliverables**:
- Sewers zone (darker atmosphere, tighter corridors, 3x larger than backyard)
- Zone entrance from Neighborhood (manhole cover interaction)
- Environmental hazards: toxic puddles (damage over time), dark areas (reduced visibility)
- Sewer-specific enemy spawns (rats + shadow creatures)
- Linear path leading to Rat King mini-boss room
- Sewer ambient effects (dripping, gloom particles)

**Plans:** 3 plans

Plans:
- [x] 19-01-PLAN.md — Toxic puddle component & sewer infrastructure (Wave 1)
- [x] 19-02-PLAN.md — Sewers zone scene: layout, darkness & atmosphere (Wave 2)
- [x] 19-03-PLAN.md — Neighborhood manhole & integration testing (Wave 3)

---

## Phase 20: Mini-Boss System
**Goal**: Unique mini-boss encounters in each zone for replayability

**Deliverables**:
- Mini-boss base class (extended from EnemyBase, 2 attack patterns each)
- Alpha Raccoon (Neighborhood) — 120 HP, calls raccoon reinforcements, ground slam AoE
- Crow Matriarch (Backyard) — 80 HP, summons crow swarm, dive bomb attack
- Rat King (Sewers) — 150 HP, splits into smaller rats at 50% HP, poison AoE cloud
- Mini-boss health bar (mid-size, top of screen)
- One-time defeat per save file, unique loot drops (rare equipment)
- Mini-boss spawn triggers (area-based, optional fights)

**Plans:** (created by /gsd-plan-phase)

Plans:
- [ ] TBD — planned by /gsd-plan-phase

---

## Milestone: v1.3 Content & Variety
New enemies with unique mechanics, a shop to spend coins, a dungeon zone, and challenging mini-bosses.
