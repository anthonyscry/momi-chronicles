# Enemy & Boss Sprite Audit Report
**Date:** 2026-02-01
**Auditor:** Auto-Claude
**Scope:** Enemy and Boss Characters (Regular Enemies + Mini-Bosses + Final Boss)

---

## Executive Summary

This audit assesses the current state of enemy and boss sprites for Momi's Adventure. The audit evaluates existing sprite assets against visual consistency standards, pixel scale requirements, animation completeness, and **critical visual distinctiveness from player/companion characters**.

### Key Findings
- **Art Directory Status:** ❌ Enemy/boss sprite directories DO NOT EXIST (`art/generated/enemies/`, `art/generated/bosses/`)
- **Sprite Count:** 0 sprite files found
- **Current Visual State:** All enemies use placeholder Polygon2D nodes in scene files
- **Enemy Count:** 5 regular enemies + 4 bosses = 9 total enemy types (excluding test_dummy)
- **Scale Targets:**
  - Regular enemies: **24x24 pixels**
  - Mini-bosses: **32x32 to 40x40 pixels** (larger than regular enemies, smaller than final boss)
  - Final boss: **48x48 pixels**
- **Critical Requirement:** Enemies MUST be visually distinct from Momi (French Bulldog) and companions (Cinnamon, Philo)

### Visual Distinctiveness Strategy
**Primary Risk:** Since the protagonist is a **dog (French Bulldog)**, and several enemies are also **animals (Crow, Raccoon, Rat, Cat)**, there is a HIGH RISK of visual confusion if not carefully designed.

**Required Differentiation Techniques:**
1. **Color Palette:** Enemies use darker, desaturated, or hostile colors (grays, blacks, purples, reds) vs. player's warm tans/golds
2. **Visual Language:** Enemies have aggressive poses, angular shapes, sharp edges vs. player's friendly, rounded design
3. **Eye Design:** Enemies have glowing red/yellow eyes or no visible eyes vs. player's friendly expressive eyes
4. **Silhouette:** Each enemy has a unique, recognizable silhouette distinct from player
5. **Context Cues:** Enemies may have corruption effects, shadows, or hostile auras

---

## Regular Enemy Sprite Inventory

### 1. **Crow** (Flying Enemy - Neighborhood Zone)
**Enemy Type:** Aerial, fast, low HP
**Behavior:** Dive attacks, patrol flight patterns
**Visual Identity:** Dark-feathered bird, aggressive stance
**Target Size:** 24x24 pixels
**Scene File:** `characters/enemies/crow.tscn`

**Required Animations:**
- ❌ `crow_idle.png` - Perched/hovering (wings spread, idle flap cycle)
- ❌ `crow_fly.png` - Horizontal flight animation (4-6 frames, smooth wing flap)
- ❌ `crow_dive.png` - Attack dive toward player (3-4 frames, wings back)
- ❌ `crow_attack.png` - Peck/claw attack (2-3 frames)
- ❌ `crow_hurt.png` - Taking damage (recoil, feathers ruffle)
- ❌ `crow_death.png` - Defeat animation (falling, feathers scatter)

**Visual Distinctiveness Requirements:**
- ✅ **Low Confusion Risk** - Birds are clearly different from dog protagonist
- **Color:** Black/dark gray feathers with purple/red eye glow
- **Posture:** Aggressive, hunched attack stance vs. player's upright heroic pose
- **Details:** Sharp beak, talons, ruffled feathers (hostile look)
- **Size:** Smaller wingspan to fit 24x24 constraint

**Current Status:** ❌ **MISSING** - All sprites need generation
**Priority:** 🟡 **MEDIUM** - Common early-game enemy

---

### 2. **Raccoon** (Ground Enemy - Neighborhood Zone)
**Enemy Type:** Medium HP, trash-themed attacks
**Behavior:** Patrol, chase, melee attacks
**Visual Identity:** Scrappy raccoon with trash can lid shield/weapon
**Target Size:** 24x24 pixels
**Scene File:** `characters/enemies/raccoon.tscn`

**Required Animations:**
- ❌ `raccoon_idle.png` - Standing guard (shifty eyes, trash can lid held)
- ❌ `raccoon_walk.png` - Patrol cycle (4-6 frames, sneaky gait)
- ❌ `raccoon_run.png` - Chase animation (faster, aggressive charge)
- ❌ `raccoon_attack.png` - Shield bash or claw swipe (3 frames)
- ❌ `raccoon_hurt.png` - Damage reaction (flinch, lid drops slightly)
- ❌ `raccoon_death.png` - Defeat (collapses, lid clatters away)

**Visual Distinctiveness Requirements:**
- ⚠️ **MEDIUM Confusion Risk** - Both are quadrupeds, similar size category
- **Color:** Gray/brown with black mask (bandit look) + dirty/grubby appearance vs. player's clean tan coat
- **Posture:** Hunched, sneaky stance vs. player's proud, upright heroic pose
- **Accessory:** Trash can lid weapon/shield (makes it clearly an enemy)
- **Eyes:** Yellow glow or shifty expression vs. player's friendly eyes
- **Body Shape:** Longer tail, pointier snout, lankier build vs. French Bulldog's stocky muscular build

**CRITICAL:** Must NOT look like a friendly neighborhood animal. Needs hostile design cues.

**Current Status:** ❌ **MISSING** - All sprites need generation
**Priority:** 🔴 **HIGH** - Common enemy, high confusion risk requires careful design

---

### 3. **Sewer Rat** (Ground Enemy - Sewers Zone)
**Enemy Type:** Fast, swarm enemy, low HP
**Behavior:** Rush attacks, travel in packs
**Visual Identity:** Diseased/corrupted sewer rat
**Target Size:** 24x24 pixels (may render slightly smaller in-game)
**Scene File:** `characters/enemies/sewer_rat.tscn`

**Required Animations:**
- ❌ `sewer_rat_idle.png` - Sniffing, twitching (nervous energy)
- ❌ `sewer_rat_run.png` - Scurrying charge (6-8 frames, very fast cycle)
- ❌ `sewer_rat_attack.png` - Bite lunge (2 frames, quick snap)
- ❌ `sewer_rat_hurt.png` - Hit reaction (squeak pose)
- ❌ `sewer_rat_death.png` - Defeat (flops over)

**Visual Distinctiveness Requirements:**
- ✅ **LOW Confusion Risk** - Clearly rodent, not canine
- **Color:** Sickly green-gray, matted fur, glowing red eyes
- **Details:** Visible ribs, diseased patches, dripping slime/corruption
- **Size:** Noticeably smaller than player character (rats should look small)
- **Posture:** Low to ground, feral, twitchy vs. player's confident stance

**Current Status:** ❌ **MISSING** - All sprites need generation
**Priority:** 🟡 **MEDIUM** - Zone-specific enemy

---

### 4. **Shadow Creature** (Special Enemy - All Zones)
**Enemy Type:** Magic-based, mysterious
**Behavior:** Teleport, ranged shadow attacks
**Visual Identity:** Shadowy, amorphous entity (NOT an animal)
**Target Size:** 24x24 pixels
**Scene File:** `characters/enemies/shadow_creature.tscn`

**Required Animations:**
- ❌ `shadow_creature_idle.png` - Floating/pulsing (ethereal breathing)
- ❌ `shadow_creature_float.png` - Movement (drift/glide, smoky trail)
- ❌ `shadow_creature_attack.png` - Shadow projectile cast (3 frames, energy gather)
- ❌ `shadow_creature_teleport.png` - Disappear/reappear effect (4 frames, fade)
- ❌ `shadow_creature_hurt.png` - Damage (flickers, destabilizes)
- ❌ `shadow_creature_death.png` - Defeat (dissipates into smoke)

**Visual Distinctiveness Requirements:**
- ✅ **ZERO Confusion Risk** - Completely non-animal, supernatural entity
- **Color:** Pure black/dark purple with glowing core or eyes
- **Form:** Amorphous, flowing, ghost-like (no solid animal features)
- **Effect:** Transparency, particle effects, ethereal glow
- **Animation:** Floats above ground (no walking cycle)

**Design Notes:**
- This enemy is SAFE from player confusion due to non-animal design
- Can use more abstract, flowing pixel art style
- Emphasize otherworldly, magical threat

**Current Status:** ❌ **MISSING** - All sprites need generation
**Priority:** 🟢 **LOW-MEDIUM** - Unique design reduces urgency

---

### 5. **Stray Cat** (Ground Enemy - Neighborhood Zone)
**Enemy Type:** Quick, evasive, scratch attacks
**Behavior:** Hit-and-run tactics, dodge rolls
**Visual Identity:** Feral alley cat, aggressive
**Target Size:** 24x24 pixels
**Scene File:** `characters/enemies/stray_cat.tscn`

**Required Animations:**
- ❌ `stray_cat_idle.png` - Stalking stance (tail swish, ears back)
- ❌ `stray_cat_walk.png` - Prowl cycle (4 frames, stealthy)
- ❌ `stray_cat_run.png` - Sprint (fast, agile)
- ❌ `stray_cat_attack.png` - Claw swipe (3 frames, quick slash)
- ❌ `stray_cat_dodge.png` - Evasive roll/leap (3 frames)
- ❌ `stray_cat_hurt.png` - Yowl reaction (back arched)
- ❌ `stray_cat_death.png` - Defeat (collapses)

**Visual Distinctiveness Requirements:**
- ⚠️ **MEDIUM Confusion Risk** - Both are small quadrupeds, pet animals
- **Color:** Orange tabby OR black with white patches (distinct from player's tan)
- **Posture:** Arched back, hissing, aggressive vs. player's friendly heroic stance
- **Eyes:** Slit pupils, green/yellow glow vs. player's round friendly eyes
- **Body Shape:** Lean, lanky, wiry vs. French Bulldog's stocky muscular build
- **Details:** Bristling fur, bared fangs, ears flattened back (hostile cues)
- **Tail:** Long expressive tail (clear feline identifier vs. bulldog's stubby tail)

**CRITICAL:** Must look FERAL and HOSTILE, not like a pet. Needs clear aggression signals.

**Current Status:** ❌ **MISSING** - All sprites need generation
**Priority:** 🔴 **HIGH** - Common enemy, medium confusion risk requires careful design

---

## Boss & Mini-Boss Sprite Inventory

### 6. **Alpha Raccoon** (Mini-Boss - Neighborhood Zone)
**Boss Type:** Mini-boss, leader of raccoon trash bandits
**Behavior:** Slam attacks, summons regular raccoons
**Visual Identity:** LARGER, tougher raccoon with crown/cape, trash armor
**Target Size:** 36x36 pixels (larger than regular enemies, smaller than final boss)
**Scene File:** `characters/enemies/alpha_raccoon.tscn`

**Required Animations:**
- ❌ `alpha_raccoon_idle.png` - Imposing stance (arms crossed, commanding)
- ❌ `alpha_raccoon_walk.png` - Heavy patrol (4 frames, confident stride)
- ❌ `alpha_raccoon_slam.png` - Ground slam special attack (5 frames, wind-up + impact)
- ❌ `alpha_raccoon_summon.png` - Call minions (4 frames, howl/gesture)
- ❌ `alpha_raccoon_attack.png` - Melee strike (3 frames, heavy bash)
- ❌ `alpha_raccoon_hurt.png` - Damage reaction (staggers, armor clanks)
- ❌ `alpha_raccoon_death.png` - Defeat (epic fall, armor breaks)

**Visual Distinctiveness Requirements:**
- ⚠️ **MEDIUM Confusion Risk** - Still a raccoon, but MUCH larger and decorated
- **Size:** 36x36 (50% larger than regular raccoons, clearly "boss" scale)
- **Color:** Darker gray/brown, richer tones, metallic armor accents
- **Accessories:** Trash lid crown, makeshift armor plates, cape/banner
- **Posture:** Upright, bipedal stance (more humanoid than regular raccoons)
- **Details:** Battle scars, more detailed design, intimidating presence
- **Eyes:** Glowing red vs. regular raccoon's yellow

**Current Status:** ❌ **MISSING** - All sprites need generation
**Priority:** 🟡 **MEDIUM** - Mini-boss, less common encounter

---

### 7. **Crow Matriarch** (Mini-Boss - Neighborhood/Backyard Border)
**Boss Type:** Mini-boss, queen of the crow flock
**Behavior:** Wind attacks, summons crow minions, aerial superiority
**Visual Identity:** LARGER crow with regal feathers, possibly multiple wings
**Target Size:** 40x40 pixels (larger wingspan requires more space)
**Scene File:** `characters/enemies/crow_matriarch.tscn`

**Required Animations:**
- ❌ `crow_matriarch_idle.png` - Perched majestically (wing spread display)
- ❌ `crow_matriarch_fly.png` - Flight cycle (6 frames, powerful wing beats)
- ❌ `crow_matriarch_dive.png` - Aerial attack (4 frames, talons extended)
- ❌ `crow_matriarch_wind.png` - Wind gust special attack (4 frames, wing flap burst)
- ❌ `crow_matriarch_summon.png` - Call flock (3 frames, caw animation)
- ❌ `crow_matriarch_hurt.png` - Damage reaction (feathers scatter, wobble)
- ❌ `crow_matriarch_death.png` - Defeat (dramatic falling, feather explosion)

**Visual Distinctiveness Requirements:**
- ✅ **LOW Confusion Risk** - Bird form clearly distinct from dog player
- **Size:** 40x40 to accommodate larger wingspan
- **Color:** Iridescent black/purple with glowing accents
- **Details:** Crown-like crest feathers, multiple wing layers, ornate tail
- **Eyes:** Piercing yellow or purple glow, very prominent
- **Effect:** Wind particles, feather trails, aura of power

**Current Status:** ❌ **MISSING** - All sprites need generation
**Priority:** 🟡 **MEDIUM** - Mini-boss, story-significant

---

### 8. **Rat King** (Boss - Sewers Zone)
**Boss Type:** Major boss, ruler of the sewers
**Behavior:** Summon rat swarms, poison/disease attacks, multi-phase fight
**Visual Identity:** Grotesque rat overlord, possibly multiple rats fused/tangled together
**Target Size:** 48x48 pixels (full boss scale)
**Scene File:** `characters/enemies/rat_king.tscn`

**Required Animations:**
- ❌ `rat_king_idle.png` - Writhing mass (multiple rats moving in unison)
- ❌ `rat_king_move.png` - Crawling/slithering (6 frames, disturbing motion)
- ❌ `rat_king_attack.png` - Multi-bite attack (4 frames, several heads strike)
- ❌ `rat_king_summon.png` - Spawn rat swarm (4 frames, rats emerge from mass)
- ❌ `rat_king_poison.png` - Poison cloud special (4 frames, spew toxic gas)
- ❌ `rat_king_hurt.png` - Damage (mass destabilizes, rats scatter/regroup)
- ❌ `rat_king_death.png` - Defeat (mass breaks apart, dramatic collapse)

**Visual Distinctiveness Requirements:**
- ✅ **ZERO Confusion Risk** - Grotesque horror design, completely unlike player
- **Size:** 48x48 (DOUBLE the player size, imposing boss presence)
- **Color:** Sickly green, diseased gray, glowing pustules or plague marks
- **Design:** Multiple rat heads/bodies tangled together (king rat folklore)
- **Details:** Visible bones, matted fur, dripping corruption, crown of bones
- **Effect:** Poison particles, disease aura, unsettling animation

**Design Notes:**
- This is a HORROR enemy, should be visually disturbing
- Based on "Rat King" folklore (rats with tails knotted together)
- Emphasize body horror, disease, corruption

**Current Status:** ❌ **MISSING** - All sprites need generation
**Priority:** 🔴 **HIGH** - Major boss, critical story encounter

---

### 9. **Raccoon King** (Final Boss - Multiple Phases)
**Boss Type:** Final boss, ultimate antagonist
**Behavior:** Multi-phase fight, all raccoon abilities + special powers
**Visual Identity:** MASSIVE raccoon king with royal regalia, trash kingdom throne
**Target Size:** 48x48 pixels (full boss scale, may scale up in final phase)
**Scene File:** `characters/enemies/boss_raccoon_king.tscn`

**Required Animations:**
- ❌ `raccoon_king_idle.png` - Throne pose (sitting/standing, regal)
- ❌ `raccoon_king_walk.png` - Commanding stride (slow, powerful)
- ❌ `raccoon_king_attack.png` - Royal strike (heavy weapon swing)
- ❌ `raccoon_king_slam.png` - Ground pound AOE (5 frames, massive impact)
- ❌ `raccoon_king_summon.png` - Call all minions (4 frames, raise arms)
- ❌ `raccoon_king_special.png` - Ultimate attack (6 frames, charge + release)
- ❌ `raccoon_king_hurt.png` - Damage (staggers, crown tilts)
- ❌ `raccoon_king_phase2.png` - Transformation (removes armor, enters rage mode)
- ❌ `raccoon_king_death.png` - Final defeat (epic 8-frame collapse)

**Visual Distinctiveness Requirements:**
- ⚠️ **MEDIUM Confusion Risk** - Still a raccoon, but MAXIMUM size and detail
- **Size:** 48x48 (SAME size as player but MUCH more detailed and imposing)
- **Color:** Rich royal colors (purple, gold, red accents) on gray/brown base
- **Accessories:** Full royal regalia - crown, cape, scepter, armor
- **Posture:** Fully bipedal, humanoid stance (king not beast)
- **Details:** Maximum pixel art detail - fur texture, fabric folds, metallic sheen
- **Eyes:** Intelligent, glowing, menacing (vs. player's heroic friendly eyes)
- **Phase 2:** Darker, more bestial form (armor breaks, feral rage)

**CRITICAL:** This is the FINAL BOSS - must be IMMEDIATELY INTIMIDATING while still recognizable as a raccoon king.

**Current Status:** ❌ **MISSING** - All sprites need generation (8+ sprites!)
**Priority:** 🔴 **CRITICAL** - Final boss, highest visual quality required

---

## Scale Verification Methodology

To ensure visual consistency and proper enemy-player distinction:

### Pixel Scale Standards
```
Sewer Rat:       20x20 to 24x24 (smallest, should look tiny)
Regular Enemies: 24x24 (Crow, Raccoon, Cat, Shadow Creature)
Player (Momi):   32x32 (REFERENCE STANDARD)
Mini-Bosses:     36x36 to 40x40 (Alpha Raccoon, Crow Matriarch)
Major Bosses:    48x48 (Rat King, Raccoon King)
```

### Verification Checklist (Phase 2)
When sprites are generated, verify:
- [ ] All regular enemies are SMALLER than player (24x24 vs 32x32)
- [ ] Mini-bosses are SLIGHTLY larger than player (36-40 vs 32)
- [ ] Major bosses are SIGNIFICANTLY larger (48x48 vs 32x32)
- [ ] Size differences are VISUALLY OBVIOUS in gameplay
- [ ] No enemy sprite exceeds its designated pixel boundary

---

## Visual Distinctiveness Assessment

### HIGH RISK Enemies (Require Extra Care)
1. **Raccoon** - Quadruped, similar size class → Needs hostile color, bandit accessories, aggressive posture
2. **Stray Cat** - Quadruped pet animal → Needs feral look, arched back, bared fangs, contrasting color
3. **Raccoon King** - Same species as regular enemy → Needs MAXIMUM detail, royal regalia, intimidating presence

### MEDIUM RISK Enemies
1. **Alpha Raccoon** - Larger raccoon → Size + armor differentiation should be sufficient
2. **Crow Matriarch** - Large bird → Size + regal design should be sufficient

### LOW RISK Enemies (Naturally Distinct)
1. **Crow** - Flying bird vs. ground dog, clear silhouette difference
2. **Sewer Rat** - Rodent vs. dog, size difference, diseased look
3. **Shadow Creature** - Non-animal supernatural entity, completely different design language
4. **Rat King** - Grotesque horror design, nothing like player

---

## Color Palette Strategy

### Player & Companions (FRIENDLY Palette)
- Warm tans, golds, browns
- Bright, saturated colors
- Clean, healthy appearance
- Friendly eye colors (brown, blue)

### Enemies (HOSTILE Palette)
- **Crows:** Black, dark gray, purple shadows, red/yellow glowing eyes
- **Raccoons:** Dirty gray/brown, black mask, yellow eyes, trash/metallic accessories
- **Rats:** Sickly green-gray, diseased patches, red glowing eyes
- **Shadow Creature:** Pure black/dark purple, glowing core (purple/red)
- **Stray Cat:** Orange tabby OR black with white, green/yellow slit eyes, bristling fur
- **Bosses:** Richer, darker versions of base colors + royal/corruption accents

### Contrast Requirements
- Enemies use COOLER tones (blues, greens, purples, grays)
- Player uses WARMER tones (browns, tans, golds)
- Enemies have DESATURATED colors vs. player's vibrant colors
- Boss enemies can have RICH colors but still maintain hostile tone

---

## Animation Frame Estimates

### Regular Enemies (5 enemies × ~5-6 animations each)
- Crow: 6 animations × 3 frames avg = ~18 frames
- Raccoon: 6 animations × 4 frames avg = ~24 frames
- Sewer Rat: 5 animations × 3 frames avg = ~15 frames
- Shadow Creature: 6 animations × 3 frames avg = ~18 frames
- Stray Cat: 7 animations × 3 frames avg = ~21 frames
**Subtotal: ~96 frames**

### Bosses (4 bosses × ~7-9 animations each)
- Alpha Raccoon: 7 animations × 4 frames avg = ~28 frames
- Crow Matriarch: 7 animations × 4 frames avg = ~28 frames
- Rat King: 7 animations × 4 frames avg = ~28 frames
- Raccoon King: 9 animations × 5 frames avg = ~45 frames (complex final boss)
**Subtotal: ~129 frames**

### **TOTAL ESTIMATED SPRITES: ~225 sprite frames**

This is a MASSIVE art generation task. Consider:
- Batching generation by enemy type
- Starting with high-priority enemies (Raccoon, Stray Cat, Raccoon King)
- Using simpler animations for low-priority enemies
- Reusing idle frames where appropriate

---

## Quality Assurance Requirements

### Pre-Generation Checklist
- [ ] AI prompts emphasize HOSTILE appearance for all enemies
- [ ] Color palette constraints documented for each enemy type
- [ ] Size constraints (24x24, 36x36, 48x48) set in generation parameters
- [ ] Reference images prepared showing player character (to ensure contrast)

### Post-Generation QA
For EACH enemy sprite, verify:
- [ ] **Size:** Matches target pixel dimensions (24x24 / 36x36 / 48x48)
- [ ] **Color:** Uses hostile palette, contrasts with player warm tones
- [ ] **Silhouette:** Unique, recognizable, distinct from player
- [ ] **Eyes:** Hostile (glowing, slit, menacing) vs. player's friendly eyes
- [ ] **Posture:** Aggressive, threatening vs. player's heroic stance
- [ ] **Transparency:** Clean alpha channel, no edge artifacts
- [ ] **Style:** Matches Earthbound-meets-Ghibli aesthetic
- [ ] **Outline:** 1px black outline consistent with player sprites
- [ ] **Animation:** Frames align properly, smooth motion

### Visual Confusion Test (Critical)
- [ ] Place Momi sprite next to each enemy sprite side-by-side
- [ ] Verify NO visual confusion (color, shape, size all clearly different)
- [ ] Test in-game with multiple entities on screen
- [ ] Confirm player can INSTANTLY identify Momi vs. enemies in combat

---

## Implementation Priority

### Phase 1 - High Priority (Generate First)
1. **Raccoon** (common enemy, medium confusion risk)
2. **Stray Cat** (common enemy, medium confusion risk)
3. **Raccoon King** (final boss, critical)
4. **Rat King** (major boss, critical)

### Phase 2 - Medium Priority
5. **Alpha Raccoon** (mini-boss)
6. **Crow Matriarch** (mini-boss)
7. **Crow** (common enemy, low confusion risk)

### Phase 3 - Lower Priority
8. **Sewer Rat** (zone-specific, low confusion risk)
9. **Shadow Creature** (unique design, zero confusion risk)

---

## Recommendations for Phase 3 (Sprite Generation)

### 1. Create Reference Sheet First
Before generating enemy sprites, create a visual reference sheet showing:
- Momi's color palette (friendly warm tans/golds)
- Momi's silhouette (stocky French Bulldog)
- Momi's eye design (friendly, expressive)
- Enemy palette constraints (hostile cool tones)

### 2. Test Generation on High-Risk Enemies First
- Generate Raccoon and Stray Cat FIRST
- If these pass visual distinctiveness test, others will be easier
- If confusion detected, adjust prompts before batch generation

### 3. Use Comparative Prompts
Example prompt structure:
```
"24x24 pixel art of a hostile raccoon enemy carrying a trash can lid shield.
Dark gray fur with black bandit mask, yellow glowing eyes, aggressive hunched posture,
dirty and scrappy appearance. Uses cool desaturated colors (grays, blacks).
MUST look threatening and feral, NOT friendly or cute.
Reference: Player character is a friendly tan French Bulldog - this enemy must contrast clearly.
Style: SNES 16-bit, Earthbound-meets-Ghibli, 1px black outline, transparent background."
```

### 4. Batch Similar Enemies
- Generate all crow sprites together (regular + matriarch)
- Generate all raccoon sprites together (regular + alpha + king)
- Generate all rat sprites together (swarm + king)
- Ensures visual consistency within enemy families

### 5. Animation Simplification Options
If 225 frames is too much:
- Reuse idle frame for hurt (just add flash effect)
- Combine walk + run into single movement animation
- Use simpler death animations (3 frames instead of 6)
- Mini-bosses can share some animations with regular versions

---

## Final Status Summary

| Enemy Type | Scene File Exists | Sprites Exist | Pixel Scale | Priority | Confusion Risk |
|------------|------------------|---------------|-------------|----------|----------------|
| Crow | ✅ Yes | ❌ No | 24x24 | Medium | Low |
| Raccoon | ✅ Yes | ❌ No | 24x24 | **HIGH** | **Medium** |
| Sewer Rat | ✅ Yes | ❌ No | 24x24 | Medium | Low |
| Shadow Creature | ✅ Yes | ❌ No | 24x24 | Low-Med | Zero |
| Stray Cat | ✅ Yes | ❌ No | 24x24 | **HIGH** | **Medium** |
| Alpha Raccoon | ✅ Yes | ❌ No | 36x36 | Medium | Medium |
| Crow Matriarch | ✅ Yes | ❌ No | 40x40 | Medium | Low |
| Rat King | ✅ Yes | ❌ No | 48x48 | **HIGH** | Low |
| Raccoon King | ✅ Yes | ❌ No | 48x48 | **CRITICAL** | **Medium** |

**Overall Status:** ❌ **ALL ENEMY SPRITES MISSING - REQUIRES FULL GENERATION PIPELINE**

**Estimated Workload:** 9 enemy types × 6 avg animations × 4 avg frames = ~216 sprite frames

**Blockers:** None - scene files ready, art pipeline exists, just needs execution

**Next Steps:**
1. Proceed to Phase 2: Document visual standards with enemy-specific color palettes
2. Create reference comparison sheet (player vs. enemy design language)
3. Phase 3: Begin sprite generation starting with high-priority enemies
4. Run visual distinctiveness tests before batch generation

---

**Audit Complete** | Generated: 2026-02-01 | Document Version: 1.0
