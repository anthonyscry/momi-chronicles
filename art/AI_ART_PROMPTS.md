# Momi's Adventure — AI Pixel Art Generation Prompts

> **Art Direction**: 16-bit pixel art, top-down action RPG style (think Secret of Mana / Link to the Past).
> **Resolution**: 32x32 characters, 16x16 items/pickups, 64x64 bosses, tilesets at 16x16 per tile.
> **Palette**: Warm, friendly neighborhood tones. Dogs are the heroes. Enemies are urban wildlife.
> **Perspective**: 3/4 top-down view (slight elevation angle showing front and top).

---

## HOW TO USE THESE PROMPTS

Each prompt below is designed for AI image generators (Midjourney, DALL-E, Stable Diffusion, Leonardo AI, etc.).

**Recommended workflow:**
1. Generate via Gemini (outputs ~1024x1024)
2. Run `rip_sprites.py` — flood-fills white background to transparency, downscales to target res
3. Review `_preview.png` files on checkerboard for quality
4. Move approved sprites to `assets/sprites/` for Godot import

**Prompt suffix (applied automatically by gemini_automation.py):**
```
pixel art, 16-bit SNES style, top-down RPG perspective, isolated character on plain white background, no ground no shadows no gradients, clean pixel edges, vibrant colors, game sprite
```

**Background strategy:** Request "plain white background, no shadows, no gradients" — AI generators
respect this reliably. `rip_sprites.py` flood-fills from corners to make transparent. Do NOT request
specific hex colors (e.g. #FF00FF) — AI generators ignore them.

---

## 1. PLAYER CHARACTER

### Momi (French Bulldog — Main Hero)
**Target**: 32x32 sprite, 8 directions, animation frames for each state
**Current color**: Tan/Golden (#D9B373)

```
IDLE (4 directions):
"A cute tan French Bulldog puppy standing alert, seen from top-down 3/4 view, big bat ears pointing up, short stocky body, stubby tail, wearing a small brown leather collar, pixel art, 16-bit SNES style RPG character sprite, facing [down/up/left/right]"

WALK (4 directions × 4 frames):
"A tan French Bulldog puppy walking, top-down 3/4 view, stubby legs mid-stride, ears bouncing slightly, wearing brown collar, pixel art walk cycle animation frame, 16-bit SNES RPG style"

RUN (4 directions × 4 frames):
"A tan French Bulldog puppy running fast, top-down 3/4 view, ears pinned back from speed, legs in full sprint, motion blur lines behind, wearing brown collar, pixel art run animation, 16-bit SNES RPG"

ATTACK (4 directions × 3 frames — combo chain):
"A tan French Bulldog puppy lunging forward to bite/headbutt, top-down 3/4 view, mouth open showing teeth, body leaning forward aggressively, attack swoosh arc, pixel art attack animation frame, 16-bit action RPG"

CHARGE ATTACK (hold → release):
"A tan French Bulldog puppy charging up energy, glowing golden aura building around body, determined expression, pixel art charge-up effect, 16-bit SNES RPG"
"A tan French Bulldog puppy releasing a powerful charged headbutt, golden energy burst on impact, top-down 3/4 view, pixel art power attack, 16-bit action RPG"

GROUND POUND (special ability):
"A tan French Bulldog puppy leaping up then slamming down, circular shockwave ripple on ground, top-down view, pixel art AoE slam attack, 16-bit SNES RPG style"

DODGE ROLL (4 directions × 3 frames):
"A tan French Bulldog puppy rolling/tumbling to dodge, tucked into a ball, dust trail behind, top-down 3/4 view, pixel art dodge animation, 16-bit RPG"

BLOCK/PARRY:
"A tan French Bulldog puppy in defensive stance, front paws braced, head ducked behind raised collar (shield), blue energy barrier in front, pixel art block pose, 16-bit RPG"

HURT:
"A tan French Bulldog puppy recoiling from a hit, eyes squeezed shut, knocked backward, red flash on body, pixel art hurt animation, 16-bit SNES RPG"

DEATH/KO:
"A tan French Bulldog puppy collapsed on the ground, eyes as X marks, tongue out, stars circling head, pixel art KO sprite, 16-bit RPG game over"
```

---

## 2. COMPANION CHARACTERS

### Cinnamon (English Bulldog — Tank)
**Target**: 32x32 sprite, same states as Momi
**Current color**: Brown (#BF804D)
**Personality**: Big, sturdy, overheats when fighting too hard

```
"A stocky brown English Bulldog with a wide chest and underbite, wearing a red tactical harness, top-down 3/4 view, bulky and tough-looking, pixel art RPG companion character, 16-bit SNES style"

OVERHEAT MECHANIC:
"A brown English Bulldog panting heavily, tongue out, steam rising from body, red-orange glow, overheated from combat, pixel art status effect, 16-bit RPG"
```

### Philo (Boston Terrier — Support)
**Target**: 32x32 sprite, same states as Momi
**Current color**: Grey-Blue (#4D4D59)
**Personality**: Smaller, tuxedo pattern, lazy but motivated when allies are hurt

```
"A small grey-and-white Boston Terrier with tuxedo markings, big round eyes, wearing a blue bandana, top-down 3/4 view, slim and alert, pixel art RPG support character, 16-bit SNES style"

MOTIVATED STATE:
"A Boston Terrier with determined glowing eyes, golden sparkle aura, standing proud and energized, pixel art buff state, 16-bit RPG companion"

LAZY STATE:
"A Boston Terrier half-asleep, droopy eyes, yawning, low energy posture, pixel art idle/lazy animation, 16-bit RPG"
```

---

## 3. ENEMIES

### Raccoon (Basic — Neighborhood)
**Target**: 24x24 sprite
**Current color**: Muted Brown (#806659)

```
"A mischievous raccoon with black mask markings around eyes, grey-brown fur, bushy striped tail, standing on hind legs in fighting pose, top-down 3/4 view, pixel art enemy sprite, 16-bit SNES RPG style"

PATROL: "A raccoon waddling around sniffing the ground, curious and sneaky, top-down view, pixel art patrol animation, 16-bit RPG"
CHASE: "An aggressive raccoon running on all fours toward the viewer, snarling, top-down 3/4 view, pixel art chase animation, 16-bit RPG"
ATTACK: "A raccoon swiping with sharp claws, lunging forward, pixel art melee attack, 16-bit RPG"
```

### Crow (Fast — Neighborhood/Backyard)
**Target**: 20x20 sprite
**Current color**: Dark Purple (#332640)

```
"A black crow with glossy purple-black feathers, beady red eyes, sharp beak, wings spread in flight, seen from above/top-down, pixel art flying enemy sprite, 16-bit SNES RPG"

DIVE ATTACK: "A crow swooping down beak-first in a dive bomb attack, motion lines, top-down view, pixel art aerial attack, 16-bit RPG"
PERCHED: "A crow perched with wings folded, head tilting menacingly, pixel art idle enemy, 16-bit RPG"
```

### Stray Cat (Stealth — Neighborhood)
**Target**: 24x24 sprite
**Current color**: Orange (#D98C33)

```
"A scrappy orange tabby cat with torn ear and scar, crouching low in ambush position, green glowing eyes, top-down 3/4 view, pixel art stealth enemy, 16-bit SNES RPG style"

STEALTH (semi-transparent): "An orange tabby cat fading into shadows, partially invisible/translucent, only eyes glowing green, pixel art stealth mode, 16-bit RPG"
POUNCE: "An orange tabby cat mid-leap pouncing forward with claws extended, top-down action pose, pixel art attack animation, 16-bit RPG"
RETREAT: "An orange tabby cat running away fast, tail puffed up, darting to safety, pixel art flee animation, 16-bit RPG"
```

### Sewer Rat (Swarm — Sewers)
**Target**: 16x16 sprite (smaller, appears in packs of 3-4)
**Current color**: Grey-Brown (#73594D)

```
"A small dirty sewer rat with beady eyes and long pink tail, matted grey-brown fur, hunched posture, top-down 3/4 view, pixel art swarm enemy, 16-bit RPG style, very small"

POISON BITE: "A sewer rat biting with green-tinted fangs, poison dripping, pixel art poison attack, 16-bit RPG"
PACK FORMATION: "Three sewer rats running in a V formation, swarming toward player, pixel art pack behavior, 16-bit RPG"
```

### Shadow Creature (Ranged — Sewers)
**Target**: 28x28 sprite
**Current color**: Deep Void Purple (#260D40)

```
"A mysterious shadowy creature, amorphous dark purple blob with glowing white eyes, wispy ethereal edges dissolving into darkness, floating slightly above ground, top-down view, pixel art dark magic enemy, 16-bit SNES RPG"

PHASE IN: "A shadow creature materializing from thin air, particles coalescing into form, glowing eyes appearing first, pixel art phase-in animation, 16-bit RPG"
PHASE OUT: "A shadow creature dissolving into black mist, fading transparent, pixel art phase-out animation, 16-bit RPG"
SHADOW BOLT: "A dark purple energy bolt projectile with trailing dark particles, pixel art magic projectile, 16-bit RPG"
TELEPORT: "A shadow creature vanishing in a puff of dark smoke, leaving afterimage, pixel art teleport effect, 16-bit RPG"
```

---

## 4. MINI-BOSSES

### Alpha Raccoon (Neighborhood Mini-Boss)
**Target**: 48x48 sprite (1.8x normal raccoon)
**Current color**: Slate (#594D66)

```
"A massive raccoon standing upright like a gorilla, dark slate fur, golden crown on head, battle scar across face, muscular arms raised menacingly, top-down 3/4 view, pixel art mini-boss, 16-bit SNES RPG boss sprite"

GROUND SLAM: "A huge raccoon slamming both fists into the ground, circular shockwave spreading outward, dust and debris flying, pixel art AoE attack, 16-bit RPG boss"
SUMMON: "A huge raccoon roaring/howling, calling smaller raccoons from the edges of screen, pixel art summon ability, 16-bit RPG boss"
```

### Crow Matriarch (Backyard Mini-Boss)
**Target**: 40x40 sprite (1.5x normal crow)
**Current color**: Black with purple (#1A1426)

```
"A large mother crow with magnificent purple-black plumage, ornate purple feather crest on head, piercing red eyes glowing, wings spread wide, seen from above, pixel art mini-boss sprite, 16-bit SNES RPG"

DIVE BOMB: "A large crow diving down at incredible speed, beak glowing red, impact crater forming, pixel art dive attack, 16-bit RPG boss"
CROW SWARM: "A flock of small crows spiraling around a large crow matriarch, dark tornado of feathers, pixel art swarm attack, 16-bit RPG boss"
```

### Rat King (Sewers Mini-Boss)
**Target**: 48x48 sprite (2.0x normal rat)
**Current color**: Mud (#4D4733)

```
"A grotesque giant sewer rat king with three rat heads fused together, intertwined tails forming a crown, dirty mud-brown fur, red eyes, sitting on a pile of garbage, top-down 3/4 view, pixel art mini-boss, 16-bit SNES RPG"

POISON CLOUD: "A rat king spewing a cloud of green toxic gas, expanding poison AoE circle, pixel art poison attack, 16-bit RPG boss"
SPLIT: "A rat king splitting apart into four smaller rats, body fragmenting, pixel art split mechanic animation, 16-bit RPG boss"
POST-SPLIT: "A smaller, faster, angrier rat king after splitting, shrunken but glowing with rage, pixel art enrage state, 16-bit RPG"
```

---

## 5. FINAL BOSS

### Raccoon King (Boss Arena)
**Target**: 64x64 sprite (2.5x normal raccoon)
**Current color**: Dark Grey (#40384D)

```
"An enormous raccoon king sitting on a throne made of garbage, wearing a large golden crown with jewels, royal purple cape draped over shoulders, massive body with powerful arms, scarred and battle-hardened face, top-down 3/4 view, pixel art final boss, 16-bit SNES RPG, imposing and regal"

NORMAL PHASE:
"A giant raccoon king in fighting stance, crown gleaming, cape flowing, swinging massive clawed arms, pixel art boss battle sprite, 16-bit RPG"

ENRAGE (50% HP):
"An enraged raccoon king, eyes glowing red, fur standing on end, crown cracked, purple energy aura erupting around body, faster more aggressive pose, pixel art boss enrage phase, 16-bit RPG"

ATTACK PATTERNS:
"A raccoon king performing a devastating overhead claw slam, ground cracking on impact, pixel art boss heavy attack, 16-bit RPG"
"A raccoon king doing a spinning tail whip attack, circular sweep, pixel art boss spin attack, 16-bit RPG"
"A raccoon king charging forward in a shoulder tackle, dust cloud behind, pixel art boss charge attack, 16-bit RPG"

DEATH SEQUENCE:
"A raccoon king collapsing dramatically, crown falling off, cape deflating, flashing white, exploding into golden particles, pixel art boss defeat animation, 16-bit RPG victory"
```

---

## 6. NPCs

### Nutkin the Squirrel (Shop NPC)
**Target**: 24x24 sprite
**Current color**: Squirrel Brown (#BF8040) with cream belly

```
"A friendly cartoon squirrel shopkeeper, warm brown fur with cream belly, big bushy curled tail, wearing a tiny green apron and merchant hat, sitting behind a small wooden stall with items displayed, top-down 3/4 view, pixel art NPC sprite, 16-bit SNES RPG"

IDLE: "A squirrel shopkeeper waving cheerfully, tail swishing, pixel art friendly NPC animation, 16-bit RPG"
TALKING: "A squirrel shopkeeper gesturing excitedly while talking, speech bubble with acorn icon, pixel art NPC dialogue, 16-bit RPG"
```

---

## 7. ITEMS & PICKUPS

### Consumable Items (for inventory/ring menu icons)
**Target**: 16x16 each

```
HEALTH POTION: "A small red glass bottle with cork stopper, glowing red liquid inside, white cross symbol, pixel art healing item icon, 16-bit RPG"
MEGA POTION: "A large magenta glass flask with swirling liquid, ornate stopper, pixel art rare healing item, 16-bit RPG"
FULL HEAL: "A sparkling pink crystal vial with golden cap, radiating light, pixel art legendary healing item, 16-bit RPG"
ACORN: "A small brown acorn with cap, simple food item, pixel art collectible, 16-bit RPG"
BIRD SEED: "A small pouch of golden seeds spilling out, pixel art food item, 16-bit RPG"
POWER TREAT: "An orange dog bone treat with flame icon, glowing with attack power, pixel art buff item, 16-bit RPG"
SPEED TREAT: "A cyan dog bone treat with lightning bolt icon, crackling with speed energy, pixel art buff item, 16-bit RPG"
TOUGH TREAT: "A purple-blue dog bone treat with shield icon, shimmering with defense, pixel art buff item, 16-bit RPG"
GUARD SNACK: "A blue cookie with star shape, guard meter restore, pixel art item icon, 16-bit RPG"
REVIVAL BONE: "A golden glowing dog bone with sparkles and halo, revival item, pixel art rare item, 16-bit RPG"
ANTIDOTE: "A small green bottle with leaf symbol, bright green liquid, cure poison item, pixel art medicine icon, 16-bit RPG"
SMOKE BOMB: "A round grey bomb with fuse, trailing wisps of smoke, pixel art tactical item, 16-bit RPG"
ENERGY TREAT: "A golden glowing dog bone with rainbow sparkles, all-buff super item, pixel art legendary consumable, 16-bit RPG"
```

### Equipment Items (for ring menu display)
**Target**: 16x16 each

```
COLLARS:
"A simple brown leather dog collar with buckle, pixel art equipment icon, 16-bit RPG" (Basic Collar)
"A black spiked dog collar with metal studs, pixel art equipment icon, 16-bit RPG" (Spiked Collar)
"A shiny golden dog collar with gem, pixel art rare equipment, 16-bit RPG" (Lucky Collar)
"A glowing dark brown collar with rat motif, pixel art boss loot, 16-bit RPG" (Rat King's Collar)

HARNESSES:
"A blue training harness with buckles, pixel art dog equipment, 16-bit RPG" (Training Harness)
"A purple padded harness with soft lining, pixel art equipment, 16-bit RPG" (Padded Harness)
"An olive military tactical harness with pouches, pixel art equipment, 16-bit RPG" (Tactical Harness)

LEASHES:
"A red retractable leash with spring mechanism, pixel art equipment, 16-bit RPG" (Retractable Leash)
"A silver chain leash with heavy links, pixel art equipment, 16-bit RPG" (Chain Leash)
"A green bungee leash with elastic cord, pixel art equipment, 16-bit RPG" (Bungee Leash)

COATS:
"A yellow raincoat for a dog, cute and protective, pixel art equipment, 16-bit RPG" (Raincoat)
"A pink cozy knitted sweater for a dog, pixel art equipment, 16-bit RPG" (Cozy Sweater)
"A black leather biker jacket for a dog, cool and tough, pixel art equipment, 16-bit RPG" (Leather Jacket)
"A dark purple coat made of crow feathers, mystical and flowing, pixel art rare equipment, 16-bit RPG" (Crow Feather Coat)
"A royal purple cape with gold trim, legendary boss drop, pixel art legendary equipment, 16-bit RPG" (King's Mantle)

HATS:
"A red baseball cap for a dog, worn sideways, pixel art equipment, 16-bit RPG" (Baseball Cap)
"A navy blue bandana tied around head, pixel art equipment, 16-bit RPG" (Bandana)
"A steel grey guard helmet with visor, pixel art equipment, 16-bit RPG" (Guard Helmet)
"A golden crown with jewels, trophy from alpha raccoon, pixel art rare equipment, 16-bit RPG" (Raccoon Crown)
```

### World Pickups
**Target**: 12x12 each

```
HEALTH PICKUP: "A bright green pulsing heart shape floating and bobbing, green sparkle particles, pixel art health pickup, 16-bit RPG"
COIN PICKUP: "A shiny gold coin spinning, star sparkle effect, pixel art coin collectible, 16-bit RPG"
```

---

## 8. EFFECTS & PARTICLES

**Target**: Various sizes, animation sequences

```
HIT SPARK: "Yellow-white starburst explosion of sparks on impact, radiating lines, pixel art hit effect, 16-bit RPG combat"
DEATH POOF: "A large white flash expanding into grey smoke cloud with particles, pixel art enemy death effect, 16-bit RPG"
DUST PUFF: "Small tan-brown dust cloud rising from ground, pixel art movement effect, 16-bit RPG"
DAMAGE NUMBER: "Floating red number '-25' rising and fading, pixel art damage text, 16-bit RPG combat UI"
HEAL EFFECT: "Green sparkles and plus signs rising upward, pixel art healing effect, 16-bit RPG"
BUFF GLOW: "Colored aura surrounding character — orange for attack, cyan for speed, purple for defense, pixel art buff visual, 16-bit RPG"
POISON DOT: "Green toxic bubbles popping on character, sickly green tint, pixel art poison status effect, 16-bit RPG"
LEVEL UP: "Golden light pillar with sparkles erupting around character, text 'LEVEL UP!', pixel art celebration effect, 16-bit RPG"
PARRY FLASH: "Blue energy shield flash with radiating ring, pixel art perfect block effect, 16-bit RPG"
GUARD BREAK: "Shield shattering into fragments, red cracks spreading, pixel art guard break effect, 16-bit RPG"
```

---

## 9. UI ELEMENTS

**Target**: Various sizes

```
HEALTH BAR: "A red health bar with heart icon on left, dark border, segmented fill, pixel art RPG HUD element, 16-bit style"
GUARD BAR: "A blue guard/stamina bar with shield icon, pixel art RPG HUD element, 16-bit style"
EXP BAR: "A yellow experience bar with star icon, filling left to right, pixel art RPG HUD element, 16-bit style"
BOSS HEALTH BAR: "A large ornate red health bar at top of screen with skull icon and boss name, pixel art RPG boss fight UI, 16-bit"
MINI-BOSS BAR: "A medium orange health bar with crown icon, pixel art RPG mini-boss UI, 16-bit"
RING MENU: "A circular radial menu with icons arranged in a ring, glowing highlight on selected item, dark semi-transparent background, pixel art Secret of Mana style ring menu, 16-bit RPG"
COMBO COUNTER: "Pixel art combo counter showing '3 HIT!' with escalating fire effect, 16-bit RPG combat UI"
```

---

## 10. ZONE TILESETS & BACKGROUNDS

### Neighborhood Zone
**Target**: 16x16 tileset

```
GROUND: "Green grass tile, few blades of grass detail, pixel art top-down tileset, 16-bit RPG overworld"
PATH: "Light brown dirt/stone pathway tile, pixel art top-down tileset, 16-bit RPG"
HOUSE (Momi's): "A cute yellow house with blue door and red roof, seen from top-down 3/4 view, pixel art building, 16-bit RPG neighborhood"
HOUSE (Neighbor): "A blue house with white trim and grey roof, top-down 3/4 view, pixel art RPG building"
FENCE: "A white picket fence section, top-down view, pixel art environmental tile, 16-bit RPG"
PET STORE: "A small tan/orange shop building with 'PET' sign and paw print, top-down 3/4 view, pixel art RPG shop building"
MAILBOX: "A small blue mailbox on a post, pixel art environmental prop, 16-bit RPG"
FIRE HYDRANT: "A red fire hydrant, pixel art environmental prop, 16-bit RPG"
PARK BENCH: "A wooden park bench, top-down view, pixel art environmental prop, 16-bit RPG"
NUTKIN'S STALL: "A small wooden market stall with green awning, items displayed on counter, acorn sign, pixel art NPC shop, 16-bit RPG"
MANHOLE COVER: "A round grey metal manhole cover with cross pattern, slightly ajar with green glow underneath, pixel art entrance to sewers, 16-bit RPG"
```

### Backyard Zone
**Target**: 16x16 tileset

```
GROUND: "Dark green grass tile, denser vegetation, pixel art top-down tileset, 16-bit RPG"
TREE: "A leafy green tree with brown trunk, round canopy, top-down view showing crown, pixel art nature tile, 16-bit RPG"
BUSH: "A small dark green bush/shrub, top-down view, pixel art vegetation, 16-bit RPG"
SHED: "A small wooden garden shed with tools, brown walls and grey roof, top-down 3/4 view, pixel art building, 16-bit RPG"
FLOWER BED: "Colorful flowers in a garden bed, top-down view, pixel art decoration, 16-bit RPG"
GARDEN ROCKS: "Small grey rocks and pebbles, top-down view, pixel art environmental detail, 16-bit RPG"
```

### Sewers Zone
**Target**: 16x16 tileset

```
FLOOR: "Dark grey stone sewer floor with cracks, water stains, pixel art dungeon tileset, 16-bit RPG"
WALL: "Dark brick sewer wall, mossy and damp, top-down 3/4 view, pixel art dungeon wall, 16-bit RPG"
WATER CHANNEL: "Murky green-brown sewer water flowing in a channel, pixel art water tile, 16-bit RPG dungeon"
TOXIC PUDDLE: "A glowing green toxic puddle on sewer floor, bubbling and pulsing, pixel art environmental hazard, 16-bit RPG"
PIPE: "A steel grey industrial pipe segment, horizontal/vertical, pixel art sewer infrastructure, 16-bit RPG"
SEWER GRATE: "A metal drainage grate in the floor, pixel art dungeon detail, 16-bit RPG"
BOSS DOOR: "A large reinforced metal door with skull emblem, glowing red cracks, pixel art dungeon boss entrance, 16-bit RPG"
RAT NEST: "A pile of garbage and debris forming a rat nest, pixel art dungeon prop, 16-bit RPG"
DARKNESS OVERLAY: "Dark fog/shadow encroaching from edges, leaving only a circle of light around player, pixel art darkness effect for dungeon, 16-bit RPG"
```

### Boss Arena
**Target**: 16x16 tileset

```
FLOOR: "Dark grey-purple stone arena floor with ancient symbols, pixel art boss arena tileset, 16-bit RPG"
WALL: "Tall dark stone walls with claw marks and torches, pixel art boss arena border, 16-bit RPG"
LOCKED DOOR: "Heavy iron door with chains and lock, pixel art arena entrance, closed during boss fight, 16-bit RPG"
THRONE: "A large throne made of garbage, bones, and scrap metal, where the Raccoon King sits, pixel art boss arena centerpiece, 16-bit RPG"
TORCH: "A wall-mounted flaming torch, flickering orange light, pixel art dungeon lighting, 16-bit RPG"
VICTORY EXIT: "A golden glowing doorway with light streaming through, opened after boss defeat, pixel art victory portal, 16-bit RPG"
```

---

## 11. SPRITE SHEET SPECIFICATIONS

### Animation Frame Counts
| Entity | Idle | Walk | Run | Attack | Hurt | Death | Special |
|--------|------|------|-----|--------|------|-------|---------|
| Momi | 2 | 4 | 4 | 3×3 (combo) | 2 | 3 | Charge(3), Ground Pound(4), Block(2), Dodge(3) |
| Cinnamon | 2 | 4 | 4 | 3 | 2 | 3 | Overheat(2) |
| Philo | 2 | 4 | 4 | 3 | 2 | 3 | Motivated(2), Lazy(2) |
| Raccoon | 2 | 4 | - | 2 | 2 | 3 | - |
| Crow | 2 | - | 4 (fly) | 2 | 2 | 3 | Dive(3) |
| Stray Cat | 2 | 4 | 4 | 2 (pounce) | 2 | 3 | Stealth(2), Retreat(3) |
| Sewer Rat | 2 | 4 | - | 2 | 1 | 2 | Poison(2) |
| Shadow Creature | 3 (float) | - | 3 (drift) | 2 | 2 | 3 | Phase(3), Teleport(2) |
| Mini-Bosses | 2 | 4 | - | 3 | 2 | 4 | Varies |
| Raccoon King | 3 | 4 | - | 3×3 (patterns) | 2 | 6 | Enrage(3) |
| Nutkin | 3 | - | - | - | - | - | Wave(3), Talk(3) |

### Recommended Export Format
- **Individual sprites**: `{character}_{state}_{direction}_{frame}.png`
- **Sprite sheets**: `{character}_sheet.png` (grid layout, all frames)
- **Tilesets**: `{zone}_tileset.png` (16x16 grid, all tiles)
- **Items**: `items_sheet.png` (16x16 grid, all items)
- **Effects**: `effects_sheet.png` (individual sizes, all frames)

---

## 12. COLOR PALETTE REFERENCE

### Character Palette
| Entity | Primary | Secondary | Accent |
|--------|---------|-----------|--------|
| Momi | #D9B373 (Tan) | #C49A5C (Dark Tan) | #FFE4B5 (Cream) |
| Cinnamon | #BF804D (Brown) | #8B5E3C (Dark Brown) | #D4A574 (Light Brown) |
| Philo | #4D4D59 (Grey) | #333340 (Dark Grey) | #FFFFFF (White tuxedo) |

### Enemy Palette
| Entity | Primary | Secondary | Accent |
|--------|---------|-----------|--------|
| Raccoon | #806659 (Brown) | #4D3D33 (Dark) | #1A1A1A (Mask) |
| Crow | #332640 (Purple-Black) | #1A1326 (Deep) | #CC3333 (Red eyes) |
| Stray Cat | #D98C33 (Orange) | #B37326 (Dark Orange) | #33CC33 (Green eyes) |
| Sewer Rat | #73594D (Grey-Brown) | #594033 (Dark) | #FF9999 (Pink tail/nose) |
| Shadow Creature | #260D40 (Void) | #1A0A2E (Deep) | #FFFFFF (Eyes) |

### Zone Palette
| Zone | Ground | Walls | Accent |
|------|--------|-------|--------|
| Neighborhood | #618C59 (Grass) | #D9C27A (Houses) | #FFFFFF (Fences) |
| Backyard | #407340 (Deep Grass) | #8B6F47 (Wood) | #228B22 (Bushes) |
| Sewers | #0F0A1A (Dark) | #38332E (Stone) | #1A382E (Toxic Green) |
| Boss Arena | #1F1A26 (Grim) | #2E2838 (Wall) | #FFD700 (Gold accents) |
