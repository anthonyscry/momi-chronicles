# 🎮 "Good Girl" — Nano Banana Pro Art Production Bible

## Complete Prompting Strategy for AI-Generated Game Assets

This guide transforms your existing reference materials into production-ready pixel art sprites, animations, and game assets using Nano Banana Pro's advanced capabilities.

---

# 📋 TABLE OF CONTENTS

1. [Understanding Nano Banana Pro](#understanding-nano-banana-pro)
2. [The Golden Rules](#the-golden-rules)
3. [Master Reference Strategy](#master-reference-strategy)
4. [Character Sprite Prompts](#character-sprite-prompts)
5. [Animation Frame Generation](#animation-frame-generation)
6. [Environment & Tileset Prompts](#environment--tileset-prompts)
7. [UI & Effects Prompts](#ui--effects-prompts)
8. [Batch Generation Workflow](#batch-generation-workflow)
9. [Post-Processing Pipeline](#post-processing-pipeline)
10. [Troubleshooting & Tips](#troubleshooting--tips)

---

# 🧠 UNDERSTANDING NANO BANANA PRO

## What Makes It Different

Nano Banana Pro (Gemini 2.5/3 Flash Image) is a **"thinking" model** — it doesn't just match keywords, it understands intent, physics, and composition. This means:

- **Stop using "tag soups"** like `dog, park, 4k, realistic`
- **Start briefing it like a Creative Director** — use full sentences, natural language
- **Edit, don't re-roll** — if an image is 80% correct, ask for specific changes
- **Character consistency** is a core strength — use reference images to lock identity

## Key Capabilities for Game Dev

| Capability | How It Helps Your Game |
|------------|------------------------|
| **Character Consistency** | Same Momi across 100+ sprites |
| **Batch Sprite Generation** | 30 themed sprites per sheet |
| **Multi-turn Editing** | Refine without starting over |
| **Style Locking** | Maintain pixel art aesthetic |
| **Animation Frames** | Generate walk cycles, attacks, etc. |
| **4K Native Output** | Generate high-res, downscale for clean pixels |

---

# 🏆 THE GOLDEN RULES

## Rule 1: Edit, Don't Re-roll

If Momi's sprite is 80% correct but her ear is wrong:

❌ **Bad:** Generate a completely new image  
✅ **Good:** "Keep everything the same, but fix the left ear to match the right ear's shape"

## Rule 2: Natural Language, Full Sentences

❌ **Bad:** "frenchie, pixel, 32x32, game sprite, cute"  
✅ **Good:** "Create a 32x32 pixel art sprite of Momi, a black brindle French Bulldog with a white chest patch and white chin goatee, in an idle standing pose. Use a limited 32-color palette with clean pixel edges, suitable for a 3/4 perspective action RPG."

## Rule 3: Be Specific and Descriptive

Define the **subject**, **setting**, **style**, and **purpose**:

✅ **Excellent:** "Create a pixel art sprite for a 2D 3/4 perspective action RPG game. The character is Momi, a 5-year-old female French Bulldog with black brindle fur, a distinctive white tuxedo chest patch, and a white chin that looks like a goatee. She has big expressive brown eyes and classic bat ears. This sprite shows her idle pose in 3/4 view facing down-right (southeast), breathing gently. Style: 32x32 pixels, SNES-era aesthetic, limited palette, clean pixel edges, white background for easy extraction."

## Rule 4: Provide Context

Tell the model **what this is for**:

✅ "This is for a Godot 2D game inspired by Earthbound, with a Studio Ghibli warmth. The sprites need to match that quirky, heartfelt aesthetic with a 3/4 isometric perspective."

## Rule 5: Lock Your Reference First

Before generating variants:
1. Generate 8-12 candidates from your Momi photos
2. Select 2-4 "anchor" images that nail her look
3. Always reference these anchors in future prompts
4. Keep anchors in a dedicated folder

---

# 🎨 MASTER REFERENCE STRATEGY

## Phase 0: Create Your Style Bible

Before ANY sprite generation, establish canonical references.

### Step 1: Generate Momi's Character Reference Sheet

Upload your best Momi photo(s) and prompt:

```
Create a professional character reference sheet for video game development.

Subject: Momi, a 5-year-old female French Bulldog
Physical traits:
- Black brindle coat (dark base with subtle darker striping)
- Distinctive white "tuxedo" chest patch
- White chin marking that resembles a goatee
- Big, expressive brown eyes with soulful look
- Classic French Bulldog bat ears (dark, rounded)
- Compact, sturdy body with visible wrinkles
- Small nub tail (no full tail)

Show eight directional views for 3/4 perspective game:
- Down-right (SE) - primary view
- Down (S)
- Down-left (SW)
- Left (W)
- Up-left (NW)
- Up (N)
- Up-right (NE)
- Right (E)

All views at the same scale with consistent proportions
Clean white background, soft neutral lighting
Art style: Stylized cartoon suitable for pixel art conversion
Aesthetic influence: Studio Ghibli warmth meets Earthbound quirk
Aspect ratio: 16:9 landscape layout
```

### Step 2: Generate Expression Sheet

Using your approved reference sheet:

```
Create an expression/emotion sheet for Momi the French Bulldog.
Reference the attached character sheet for exact appearance.

Show 9 expressions in a 3x3 grid, all in 3/4 perspective (SE facing):
1. Happy (big smile, nub wiggling implied, whole body joy)
2. Alert (ears perked forward, eyes wide, ready stance)
3. Sleepy/Grumpy (droopy eyes, slight frown, classic Frenchie tired face)
4. Excited (open mouth panting, sparkling eyes, maximum wiggle energy)
5. Scared (ears back, wide eyes, low posture, tail tucked)
6. Curious (head tilt, one ear slightly raised, investigating)
7. Determined (focused eyes, slight lean forward, ready to act)
8. Sad (droopy ears, puppy eyes, no nub wiggle)
9. Angry/Defensive (showing teeth, protective stance, hackles up)

Each expression clearly readable at small sizes
Clean white background, consistent lighting
Same cartoon style as reference sheet
```

### Step 3: Lock Your Anchors

From all generated references, select your **CANONICAL ANCHORS**:
- 1 SE-view anchor (primary reference — 3/4 down-right)
- 1 NW-view anchor (3/4 up-left)
- 1 side-view anchor
- 1 expression anchor (happy Momi)

**Save these separately. Reference them in EVERY future prompt.**

---

# 🐕 CHARACTER SPRITE PROMPTS

## Momi — Complete Sprite Sheet

### Base Prompt Template

Always include this context block:

```
[STYLE CONTEXT]
Game: "Good Girl" - 2D 3/4 perspective action RPG
Engine: Godot 4
Aesthetic: SNES-era pixel art, Earthbound quirk, Studio Ghibli warmth
Perspective: 3/4 isometric view (not top-down, not side-view)
Resolution: 32x32 pixels per sprite
Palette: Maximum 32 colors, consistent across all sprites
Background: Pure white (#FFFFFF) for easy extraction
Animation Standard: 8 frames per animation

[CHARACTER: MOMI]
Species: French Bulldog (female, 5 years old)
Coat: Black brindle with subtle darker striping
Markings: White tuxedo chest patch, white chin "goatee"
Eyes: Big, expressive, brown
Ears: Classic bat ears, dark with lighter inner
Body: Compact, sturdy, slight wrinkles
Tail: Nub (wiggles when happy)
Personality: Fierce protector, startles easily, maximum love
```

### Individual Sprite Prompts

#### Idle Animation (8 frames)

```
Generate an 8-frame idle animation sprite sheet for Momi.

[Insert STYLE CONTEXT and CHARACTER blocks above]

Direction: Down-right (SE) — 3/4 perspective facing camera
Animation: Idle standing, gentle breathing, subtle life movements
Frame 1: Neutral standing, ears relaxed
Frame 2: Slight chest expansion (breathing in)
Frame 3: Ears twitch slightly left
Frame 4: Hold breath, subtle shift
Frame 5: Exhale begins, slight settle
Frame 6: Ears return to neutral
Frame 7: Tiny weight shift
Frame 8: Return to frame 1 position

Layout: Horizontal strip, 8 frames, evenly spaced
Each frame: 32x32 pixels, clean edges, no blur
Include subtle shadow under Momi (appropriate for 3/4 view)
Loop-ready animation — frame 8 flows seamlessly to frame 1
```

#### Walk Cycle — 8 Directions (8 frames each)

```
Generate an 8-frame walk cycle sprite sheet for Momi, facing DOWN-RIGHT (SE).

[Insert STYLE CONTEXT and CHARACTER blocks]

Direction: Southeast (3/4 view toward camera-right)
Animation: Casual trot, happy walk, natural quadruped gait
Frame 1: Contact - right front paw touches down
Frame 2: Loading weight onto right front
Frame 3: Passing - left rear swings forward
Frame 4: Right rear lifts
Frame 5: Contact - left front paw touches down
Frame 6: Loading weight onto left front
Frame 7: Passing - right rear swings forward
Frame 8: Left rear lifts, returning to frame 1

Include subtle ear bounce and body bob natural to walking
Smooth motion that loops perfectly

Layout: Horizontal strip, 8 frames
Each frame: 32x32 pixels
Clean pixel edges, consistent palette
```

Repeat with modifications for all 8 directions:
- "facing DOWN (S)"
- "facing DOWN-LEFT (SW)"
- "facing LEFT (W)"
- "facing UP-LEFT (NW)"
- "facing UP (N)"
- "facing UP-RIGHT (NE)"
- "facing RIGHT (E)"

#### Zoomies/Run Cycle (8 frames)

```
Generate an 8-frame running animation sprite sheet for Momi in MAXIMUM ZOOMIES mode.

[Insert STYLE CONTEXT and CHARACTER blocks]

Direction: Down-right (SE) — 3/4 perspective
Animation: Full sprint, post-brushing zoomies energy
Frame 1: Launch - rear legs push off
Frame 2: Full extension - all legs stretched
Frame 3: Front legs reaching forward
Frame 4: Front contact - gathering for next bound
Frame 5: Compression - body low, coiling
Frame 6: Rear legs driving forward
Frame 7: Mid-air moment - suspension phase
Frame 8: Preparing for next launch

Details:
- Ears pinned back from speed
- Mouth slightly open (happy panting)
- Body low and aerodynamic
- Pure chaos joy energy
- Visible motion in the nub area

This is Momi at maximum speed — she just got brushed and CANNOT be contained.

Layout: Horizontal strip, 8 frames
Each frame: 32x32 pixels
Smooth, fast loop
```

#### Bark Attack (8 frames)

```
Generate an 8-frame bark attack animation for Momi.

[Insert STYLE CONTEXT and CHARACTER blocks]

Direction: Down-right (SE) — 3/4 perspective
Animation: Powerful "WHO'S THERE?!" bark attack
Frame 1: Alert stance, ears forward
Frame 2: Body tenses, weight shifts back
Frame 3: Mouth begins to open, chest expands
Frame 4: BARK! Maximum mouth open, head thrust forward
Frame 5: Sonic wave implied, full extension
Frame 6: Sound releases, slight recoil
Frame 7: Recovery begins, mouth closing
Frame 8: Return to ready stance

This is Momi's primary attack — a startled defensive bark.
Should feel impactful but also cute.
Frame 4-5 should have the most visual punch.

Layout: Horizontal strip, 8 frames
Each frame: 32x32 pixels
```

#### Chomp/Bite Attack (8 frames)

```
Generate an 8-frame chomp attack animation for Momi.

[Insert STYLE CONTEXT and CHARACTER blocks]

Direction: Down-right (SE) — 3/4 perspective
Animation: Forward lunge bite attack
Frame 1: Ready stance, eyes locked on target
Frame 2: Crouch, preparing to spring
Frame 3: Launch forward, mouth opening
Frame 4: Mid-lunge, maximum reach
Frame 5: CHOMP! Jaws snap shut
Frame 6: Impact moment, bite connects
Frame 7: Pull back begins
Frame 8: Recovery to ready stance

This is Momi's melee attack — fierce but still adorable.

Layout: Horizontal strip, 8 frames
Each frame: 32x32 pixels
```

#### Sniff/Search (8 frames)

```
Generate an 8-frame sniffing animation for Momi.

[Insert STYLE CONTEXT and CHARACTER blocks]

Direction: Down-right (SE) — 3/4 perspective
Animation: Nose to ground, searching for secrets
Frame 1: Standing, head begins to lower
Frame 2: Head lowering, nose pointing down
Frame 3: Nose near ground level
Frame 4: First sniff - nose twitches
Frame 5: Second sniff - body shifts slightly
Frame 6: Third sniff - tail area wiggles with interest
Frame 7: Head raising - found something!
Frame 8: Alert pose, discovery made

This is how Momi discovers hidden items and secrets.

Layout: Horizontal strip, 8 frames
Each frame: 32x32 pixels
```

#### Dig Animation (8 frames)

```
Generate an 8-frame digging animation for Momi.

[Insert STYLE CONTEXT and CHARACTER blocks]

Direction: Down-right (SE) — 3/4 perspective
Animation: Furious digging, dirt flying
Frame 1: Nose down, front paws positioned
Frame 2: Right paw pulls back
Frame 3: Right paw digs in, dirt flies
Frame 4: Left paw pulls back
Frame 5: Left paw digs in, more dirt
Frame 6: Right paw mid-dig
Frame 7: Left paw mid-dig
Frame 8: Both paws reset for loop

Show dirt particles being flung behind her.
Rear end should be slightly elevated, classic dig posture.

Layout: Horizontal strip, 8 frames
Each frame: 32x32 pixels
```

#### Hurt/Damage (8 frames)

```
Generate an 8-frame hurt reaction animation for Momi.

[Insert STYLE CONTEXT and CHARACTER blocks]

Direction: Down-right (SE) — 3/4 perspective
Animation: Hit reaction and recovery
Frame 1: Impact! Flash frame, eyes squeeze
Frame 2: Body compresses from hit
Frame 3: Knockback begins, stumble
Frame 4: Maximum recoil position
Frame 5: Catching balance
Frame 6: Shaking it off
Frame 7: Regaining composure
Frame 8: Return to ready (slightly winded)

Should evoke sympathy — she's hurt but tough.
Don't make it too cartoonish; she's a scrappy fighter.

Layout: Horizontal strip, 8 frames
Each frame: 32x32 pixels
```

#### Sleep/Rest (8 frames)

```
Generate an 8-frame sleeping animation for Momi.

[Insert STYLE CONTEXT and CHARACTER blocks]

Direction: Down-right (SE) — 3/4 perspective
Animation: Peaceful sleep, gentle breathing cycle
Frame 1: Curled up, eyes closed, neutral
Frame 2: Chest begins to rise (inhale)
Frame 3: Chest expanded
Frame 4: Peak of breath, slight ear twitch
Frame 5: Exhale begins
Frame 6: Chest settling
Frame 7: Fully exhaled, peaceful
Frame 8: Tiny dream twitch, return to frame 1

This is Momi resting at a save point (fire hydrant or her bed).
Should be maximum cozy. Maybe a subtle Zzz implied.

Layout: Horizontal strip, 8 frames
Each frame: 32x32 pixels
```

#### Nub Wiggle / Happy Idle (8 frames)

```
Generate an 8-frame happy wiggle animation for Momi.

[Insert STYLE CONTEXT and CHARACTER blocks]

Direction: Down-right (SE) — 3/4 perspective
Animation: The signature nub wiggle — whole back end shaking with joy
Frame 1: Neutral happy, face bright
Frame 2: Back end shifts right
Frame 3: Maximum right wiggle
Frame 4: Swinging back through center
Frame 5: Back end shifts left
Frame 6: Maximum left wiggle
Frame 7: Swinging back through center
Frame 8: Reset with extra happy bounce

This is Momi's emotional indicator — the nub tells the truth.
When she's happy, her whole back end wiggles.
The wiggle should be visible and readable at game scale.

Layout: Horizontal strip, 8 frames
Each frame: 32x32 pixels
```

#### Roll Over / Play Dead (8 frames)

```
Generate an 8-frame roll over animation for Momi.

[Insert STYLE CONTEXT and CHARACTER blocks]

Direction: Down-right (SE) — 3/4 perspective
Animation: Dramatic roll over play dead
Frame 1: Standing, receives command/decides to flop
Frame 2: Beginning to lean
Frame 3: Tipping point, committing to flop
Frame 4: Mid-roll, side visible
Frame 5: Landing on back
Frame 6: Belly up, paws curling in air
Frame 7: Maximum "dead" pose, tongue starts to loll
Frame 8: Tongue fully out, complete drama, hold pose

This is both a trick and a defensive move (plays dead to confuse enemies).

Layout: Horizontal strip, 8 frames
Each frame: 32x32 pixels
```

#### Dodge/Dash (8 frames)

```
Generate an 8-frame dodge animation for Momi.

[Insert STYLE CONTEXT and CHARACTER blocks]

Direction: Down-right (SE) — 3/4 perspective, dodging to the side
Animation: Quick evasive dash/hop
Frame 1: Alert, sensing incoming
Frame 2: Crouch, preparing to spring
Frame 3: Launch sideways
Frame 4: Mid-air, tucked
Frame 5: Peak of dodge, blur effect implied
Frame 6: Landing begins
Frame 7: Touching down, absorbing impact
Frame 8: Recovery to ready stance

This is Momi's defensive i-frame move.
Should feel snappy and responsive.

Layout: Horizontal strip, 8 frames
Each frame: 32x32 pixels
```

#### Ability Charge/Power Up (8 frames)

```
Generate an 8-frame charging/power-up animation for Momi.

[Insert STYLE CONTEXT and CHARACTER blocks]

Direction: Down-right (SE) — 3/4 perspective
Animation: Gathering energy for special ability
Frame 1: Stance widens, focus begins
Frame 2: Energy gathering (subtle glow implied)
Frame 3: Particles drawing inward
Frame 4: Building intensity
Frame 5: Near maximum charge
Frame 6: Peak power, slight float/lift
Frame 7: Energy stabilizing
Frame 8: Ready to release, holding charge

This is the wind-up for Momi's special abilities.

Layout: Horizontal strip, 8 frames
Each frame: 32x32 pixels
```

---

## Cinnamon — Party Member

```
[CHARACTER: CINNAMON]
Species: English Bulldog (female)
Coat: Black and tan markings with distinctive white chest patch
Face: Classic bulldog wrinkles, broad and determined
Eyes: Dark, alert, slightly suspicious
Ears: Rose-shaped ears typical of English Bulldogs
Body: Stocky, muscular, low-slung bulldog build
Tail: Short, straight or screwed tail
Personality: Sassy, independent, actually very loyal underneath

Lives across the street from Momi with owners Ren and Jen.
Pretends she doesn't care, but always has Momi's back.
```

Use the same sprite template structure as Momi (all 8-frame animations), but swap the CHARACTER block.

---

## Philo — Party Member

```
[CHARACTER: PHILO]
Species: Boston Terrier (male, senior, older and distinguished)
Coat: Classic black and white tuxedo pattern
Face: Gray muzzle showing his age, distinguished gentleman
Eyes: Wise, patient, slightly tired of everyone's nonsense
Ears: Pointed, often one slightly more perked than other
Body: Smaller than Momi, refined, proper posture
Personality: Dignified, wise, secretly mischievous about toys

Lives at Auntie and Uncle's house.
Sometimes steals toys from Momi just because he can.
Auntie and Uncle scold him because "Momi is just a baby."
```

---

## Spuds Mackenzie — Rival

```
[CHARACTER: SPUDS MACKENZIE]
Species: Mixed breed (white with brown patches)
Coat: Mostly white with irregular brown spots
Build: Scrappy, ratty appearance, medium size
Face: Oblivious expression, not mean just clueless
Eyes: Slightly vacant but not unkind
Ears: Floppy, asymmetrical
Personality: Annoying rival, doesn't realize they're rivals

This is the dog Momi has beef with.
He's not actually a villain — just obliviously irritating.
```

---

# 🎬 ANIMATION FRAME GENERATION

## Multi-Frame Consistency Technique

For 8-frame animations, Nano Banana Pro can maintain consistency across frames when you:

### Method 1: Sequential Generation with Reference

```
Step 1: Generate Frame 1 as your anchor
"Create Frame 1 of Momi's walk cycle — right front paw contact, facing SE in 3/4 perspective."

Step 2: Generate subsequent frames referencing Frame 1
"Now create Frame 2. Keep Momi identical to Frame 1, but shift weight onto right front while left rear swings forward. Maintain exact same style, colors, and proportions."

Step 3: Continue the chain through all 8 frames
"Frame 3: Continue the walk cycle. Left rear passes under body..."

Step 4: Verify loop
"Frame 8 should transition seamlessly back to Frame 1."
```

### Method 2: Full Sheet Request

```
Generate a complete 8-frame walk cycle on a single horizontal strip.
All 8 frames must show the SAME character with IDENTICAL colors, proportions, and style.
The only change between frames is the leg positions for a smooth quadruped walk.

Perspective: 3/4 view facing down-right (SE)

Frame sequence for natural quadruped gait:
1. Right front contact
2. Right front load, left rear swing
3. Left rear contact, right rear lift
4. Pass through (diagonal pair support)
5. Left front contact
6. Left front load, right rear swing
7. Right rear contact, left rear lift
8. Pass through (return to frame 1 position)

Ensure the animation loops seamlessly from frame 8 back to frame 1.
```

### Method 3: Describe Animation Intent

```
Create an 8-frame attack animation for Momi.

Perspective: 3/4 view facing down-right (SE)

Tell the story of the animation across 8 beats:
- Frame 1: Alert, target acquired
- Frame 2: Wind-up begins, body coils
- Frame 3: Energy building, anticipation peak
- Frame 4: THE STRIKE — maximum action frame
- Frame 5: Impact/follow-through
- Frame 6: Energy release complete
- Frame 7: Recovery begins
- Frame 8: Return to ready stance

Frame 4 should have the most visual impact — this is the "key frame."
The viewer should feel the POWER of the attack.
The animation should feel impactful but still cute — this is an Earthbound-style game.
```

### 8-Direction Animation Matrix

For a complete character, you need:

| Animation | Frames | Directions | Total Sprites |
|-----------|--------|------------|---------------|
| Idle | 8 | 8 | 64 |
| Walk | 8 | 8 | 64 |
| Run | 8 | 8 | 64 |
| Attack 1 (Bark) | 8 | 8 | 64 |
| Attack 2 (Chomp) | 8 | 8 | 64 |
| Hurt | 8 | 1 (or 4) | 8-32 |
| Special | 8 | 4 | 32 |
| **Total** | | | **360-384** |

---

# 🏘️ ENVIRONMENT & TILESET PROMPTS

## Suburban Chula Vista Exterior Tileset

```
Generate a tileset for a suburban San Diego/Chula Vista neighborhood.

[STYLE CONTEXT]
Game: "Good Girl" - 2D 3/4 perspective action RPG
Perspective: Isometric/3/4 view (tiles should have depth)
Aesthetic: SNES-era pixel art, Earthbound suburban vibes, warm California feel
Tile size: 16x16 pixels (standard tilemap) or 32x16 for isometric
Palette: Warm, sunny, lived-in suburban colors

Include these tiles in an organized grid:

GROUND (with 3/4 depth shading):
- Grass (light, medium, dark variations)
- Sidewalk (concrete, clean, showing perspective)
- Street asphalt (with subtle wear)
- Driveway concrete
- Dirt path

NATURE:
- Small bushes (with shadow)
- Flowers (California native look)
- Palm tree trunk / fronds (tiling, with depth)
- Generic tree sections (canopy shows 3/4 angle)
- Succulents

STRUCTURES (showing depth/walls):
- House wall (stucco, various colors) - front and side faces
- Roof tiles (terracotta and shingle options) - angled
- Windows (lit and unlit)
- Front door
- Garage door
- Wall corners and edges

DETAILS:
- Mailbox (3/4 view)
- Fire hydrant (these are save points!)
- Fence sections (wood) - showing thickness
- Lawn ornaments
- Trash cans
- Parked cars (background element)

All tiles should connect seamlessly with proper depth.
White background for easy extraction.
```

## Momi's House Interior

```
Generate interior tileset for a cozy Southern California home.

[STYLE CONTEXT]
Perspective: 3/4 isometric view
Tile size: 16x16 or 32x16 for isometric depth

Include:

FLOORS:
- Hardwood (with plank direction showing perspective)
- Tile (kitchen/bathroom)
- Carpet
- Area rug

WALLS (showing 3/4 depth):
- Plain wall (front face and side face tiles)
- Wall with family photos
- Wall with window (showing depth/sill)
- Door frame and door
- Wall corners (inside and outside)

FURNITURE (as objects with 3/4 depth):
- Couch / sectional
- Recliner (Mama's spot and Daddy's spot)
- Coffee table
- TV entertainment center
- Kitchen island
- Dining table
- Chairs

MOMI'S ITEMS:
- Dog bed (save point!)
- Food and water bowls
- Toy basket
- Her favorite leg lamp toy

GARAGE GYM:
- Power rack (showing full 3/4 depth)
- Dumbbell rack (5-100lb visible)
- Assault bike
- Mirrors (reflective surface implied)
- Gym mats (rubber texture)
- Motorcycle (Daddy's)
```

## Strip Mall Tileset

```
Generate tileset for a Southern California strip mall.

[STYLE CONTEXT]
Perspective: 3/4 isometric view

Include:
- Storefront tiles (generic, can add signs) - showing depth
- Parking lot asphalt with perspective
- Parking space lines (angled for 3/4 view)
- Shopping cart
- Trash can
- Bench (3/4 view)
- Decorative palm in planter
- Store interiors (basic, visible through windows)
- Awnings with shadow
- Signage frames
```

---

# 🎯 UI & EFFECTS PROMPTS

## Health and Stamina UI

```
Generate UI elements for the game's health and stamina system.

[STYLE CONTEXT]
Perspective: Flat 2D (UI is not isometric)
Style: SNES-era pixel art, warm colors

HEALTH BAR (Kibble-based):
- Full kibble piece (represents 1 HP)
- Half-eaten kibble
- Quarter kibble
- Empty kibble outline
- Bar frame/container (fits 8-10 kibbles)

STAMINA BAR (Paw print-based):
- Full paw print (represents stamina)
- Faded paw print (used stamina)
- Paw print outline (empty)
- Bar frame/container

SPECIAL METER:
- Bone-shaped meter
- Fill states (empty, 25%, 50%, 75%, full)
- Glowing "ready" state

Style should match the game's warm, quirky aesthetic.
Each icon should read clearly at small sizes.
```

## Character Portraits

```
Generate character portrait icons for the party menu.

Create a portrait frame (rounded rectangle, pixel art border)
Inside the frame, show head/face shots in 3/4 view:
- Momi (happy, alert expression)
- Cinnamon (slightly smug bulldog look)
- Philo (dignified, wise)

Each portrait: 48x48 pixels
Include empty/locked portrait frame for unrecruited characters.
Include status effect overlay variants:
- Poisoned (green tint)
- Scared (blue tint, sweat drop)
- Powered up (golden glow)
```

## Visual Effects (8 frames each)

```
Generate visual effect sprites — all effects should be 8 frames.

BARK ATTACK VFX (8 frames):
- Frame 1-2: Sonic wave origin point
- Frame 3-4: Waves expanding outward
- Frame 5-6: Maximum expansion
- Frame 7-8: Fade out
- Include "BARK!" comic-style text option

CHOMP VFX (8 frames):
- Frame 1-2: Anticipation sparkle
- Frame 3-4: Bite impact flash
- Frame 5-6: Cartoon chomp lines radiate
- Frame 7-8: Fade/dissipate

HAPPY SPARKLES (8 frames):
- Looping sparkle/star particle animation
- Heart particles variant
- Suitable for 3/4 perspective attachment

ZOOMIES TRAIL (8 frames):
- Speed lines that follow character
- Dust cloud poof sequence
- Should work in all 8 directions

HIT FLASH (8 frames):
- Impact star burst
- Damage indicator
- Screen shake implied

DAMAGE NUMBERS:
- Pixel font numbers 0-9 for damage display
- Critical hit variant (larger, yellow/gold)
- Healing variant (green)
- Animation: pop up, hang, fade (across 8 frames when displayed)

All effects should be readable at game scale.
Transparent backgrounds where possible.
Effects should complement 3/4 perspective gameplay.
```

---

# 📦 BATCH GENERATION WORKFLOW

## The 30-Sprite Sheet Method

Nano Banana Pro can generate 30 themed sprites in one batch. Use this for:

### Items & Collectibles

```
Generate 30 unique item sprites for a dog-themed action RPG.

[STYLE CONTEXT]
Resolution: 32x32 pixels each
Perspective: 3/4 view (items have depth/volume)
Style: SNES-era pixel art, consistent palette
Layout: 5 rows × 6 columns grid
Background: White for extraction

Generate 30 items including:

TREATS (healing items):
- Basic kibble
- Premium kibble
- Bacon strip
- Cheese cube
- Peanut butter jar
- Dental chew
- Bully stick
- Freeze-dried liver

TOYS (equipment):
- Tennis ball
- Squeaky toy (generic)
- Rope toy
- Lamb Chop doll
- Leg lamp toy (Momi's signature!)
- Frisbee
- Kong toy
- Crinkle toy

COLLECTIBLES:
- Lost collar tags (various colors)
- Hidden bones
- Mysterious artifacts
- Keys (house key, gate key, etc.)
- Golden kibble (currency)

POWER-UPS:
- Speed boost (lightning bolt themed)
- Defense boost (shield themed)
- Attack boost (fire themed)

Fill remaining slots with logical dog-game items.
Each item should be instantly recognizable at small size.
Items should show 3/4 perspective depth.
```

### Enemy Sprites

```
Generate 30 enemy sprites for a suburban dog adventure game.

[STYLE CONTEXT]
Perspective: 3/4 view matching player characters
Resolution: 32x32 pixels each (bosses can be 64x64)

Generate enemies including:

HOUSEHOLD THREATS:
- Cranky Roomba (possessed vacuum)
- Aggressive Goose
- Suspicious Squirrel
- Enlightened Squirrel (variant, glowing)
- Trash Panda (raccoon)
- Possessed Sprinkler
- Angry Cat
- Skunk (ranged attacker)
- Rat
- Spider (small)

OUTDOOR THREATS:
- Skateboard Kid
- Lawn Gnome (animated!)
- HOA Drone
- Aggressive Jogger
- RC Car (out of control)
- Runaway Shopping Cart

HUMAN ENEMIES:
- Mailman (most are enemies, except Greg)
- Dog Catcher
- Mean Neighbor

BOSSES (larger, can span 64x64):
- Mega Raccoon (Trash King)
- The REAL Mailman (boss version)
- Alpha Goose
- Possessed Lawn Mower

Fill remaining with logical suburban threats.
Each enemy should have personality readable at small size.
All should match 3/4 perspective style.
```

---

# 🔧 POST-PROCESSING PIPELINE

## From AI Output to Game-Ready Asset

### Step 1: Review & Select

After generation:
- Compare outputs to your anchor references
- Check for consistency errors (wrong colors, proportions, perspective)
- Verify 3/4 perspective is maintained across all frames
- Rate each output: Keep / Fix / Reject
- Keep rate target: 1 good output per 3-5 generations

### Step 2: Aseprite Cleanup

In Aseprite (or similar):

```
1. Import PNG output
2. Sprite → Color Mode → Indexed
3. Reduce to your locked palette (32 colors max)
4. Clean up artifacts:
   - Fix stray pixels
   - Sharpen edges that got soft
   - Ensure consistent depth shading for 3/4 view
   - Ensure background is pure white (#FFFFFF)
5. Verify frame alignment for all 8 frames
6. Check that animation loops smoothly
7. Save your palette file for reuse
```

### Step 3: Background Removal

```
1. Magic wand select white background
2. Delete → transparent
3. Verify no white artifacts remain
4. Check edges are clean (no halo)
5. Save as PNG with transparency
```

### Step 4: Godot Import Settings

```
1. Import PNG into Godot
2. In Import tab:
   - Filter: OFF (keeps pixels crisp!)
   - Repeat: Disabled
   - Mipmaps: OFF
3. Click Reimport
4. For sprite sheets (8-frame animations):
   - Hframes = 8 (for horizontal strips)
   - Vframes = 1 (single row)
   OR for full sheets:
   - Hframes = 8
   - Vframes = number of directions/animations
```

### Step 5: Animation Assembly

```
1. Create AnimatedSprite2D node
2. Create SpriteFrames resource
3. Add animations by name:
   - "idle_se", "idle_s", "idle_sw", etc. (8 directions)
   - "walk_se", "walk_s", "walk_sw", etc.
   - "run_se", "attack_se", etc.
4. Set FPS: 10-12 for 8-frame animations (adjust to feel)
5. Test loop smoothness
6. Verify all 8 directions play correctly
```

### Step 6: Animation Tree Setup (Godot)

```
For 8-direction movement with 8-frame animations:

1. Create AnimationTree node
2. Use BlendSpace2D for directional blending
3. Map directions:
   - (0, 1) = South
   - (1, 1) = Southeast (normalized)
   - (1, 0) = East
   - (1, -1) = Northeast
   - (0, -1) = North
   - (-1, -1) = Northwest
   - (-1, 0) = West
   - (-1, 1) = Southwest

4. Feed velocity vector to blend position
```

---

# 🔥 TROUBLESHOOTING & TIPS

## Common Issues & Fixes

### "Character looks different between frames"

**Fix:** Use conversational editing instead of regenerating:
```
"Keep exactly the same character design, colors, and proportions as Frame 1, but change only the leg positions for Frame 2. Maintain the exact same 3/4 perspective angle."
```

### "Pixel art isn't crisp / looks blurry"

**Fix:** Generate at higher resolution, then downscale:
```
"Generate at 128x128 pixels resolution"
→ Downscale to 32x32 in Aseprite
= Cleaner pixel edges
```

### "Colors drift between generations"

**Fix:** Lock your palette in the prompt:
```
"Use ONLY these colors: [list hex codes]"
```
Or fix in post with Aseprite's palette enforcement.

### "Style keeps changing"

**Fix:** Create a style reference image and always include:
```
"Match the exact pixel art style shown in the attached reference image. Same line weight, same shading technique, same color saturation, same 3/4 perspective depth."
```

### "AI adds unwanted details"

**Fix:** Be explicit about what NOT to include:
```
"Do NOT include: speech bubbles, text, watermarks, gradients, anti-aliasing, or any elements outside the sprite boundary."
```

### "3/4 perspective is inconsistent"

**Fix:** Be very specific about viewing angle:
```
"Camera is positioned at approximately 30 degrees above horizontal, looking down at the character. The ground plane recedes into the distance. Characters show their top and one side, never purely from above or the side."
```

### "8 frames don't loop smoothly"

**Fix:** Explicitly describe the loop point:
```
"Frame 8 must be the transitional frame that flows directly into Frame 1. The pose in Frame 8 should be nearly identical to Frame 1 with only the movement that bridges them."
```

## Pro Tips

1. **One Variable at a Time**
   - Don't change pose AND expression AND direction in one prompt
   - Change one thing, verify, then change the next

2. **Save Your Working Prompts**
   - When something works, copy the EXACT prompt
   - Build a library of proven prompts
   - Template them for easy direction/animation swaps

3. **Generate in Batches**
   - Generate 4-8 versions of each sprite
   - Pick the best, don't settle for "close enough"

4. **Test In-Engine Early**
   - Import placeholder sprites into Godot immediately
   - Verify scale, animation timing, readability
   - Test 8-direction movement feels right
   - Better to catch issues before generating 100 sprites

5. **Maintain the Canon**
   - Your anchor images ARE the character
   - Every new generation should be compared to anchors
   - Reject outputs that drift too far

6. **Use the Nub Test**
   - If you can't tell if Momi is happy by looking at her back end, the sprite isn't expressive enough
   - The nub tells the truth — make sure it reads at game scale

7. **8-Frame Timing Guide**
   - 8 FPS = 1 second loop (slow, floaty)
   - 10 FPS = 0.8 second loop (natural walk)
   - 12 FPS = 0.67 second loop (brisk, energetic)
   - 16 FPS = 0.5 second loop (fast actions, attacks)

8. **Direction Priority**
   - Generate SE (down-right) first — it's the "hero" angle
   - S (down) second — common view
   - Then generate others based on SE/S as reference

---

# 📊 PRODUCTION CHECKLIST

## Characters
- [ ] Momi reference sheet (8-direction approved anchors)
- [ ] Momi expression sheet
- [ ] Momi full sprite set:
  - [ ] Idle (8-directional × 8 frames = 64 sprites)
  - [ ] Walk (8-directional × 8 frames = 64 sprites)
  - [ ] Run/Zoomies (8-directional × 8 frames = 64 sprites)
  - [ ] Bark attack (8-directional × 8 frames = 64 sprites)
  - [ ] Chomp attack (8-directional × 8 frames = 64 sprites)
  - [ ] Sniff (4-directional × 8 frames = 32 sprites)
  - [ ] Dig (4-directional × 8 frames = 32 sprites)
  - [ ] Hurt (8 frames)
  - [ ] Sleep (8 frames)
  - [ ] Happy wiggle (8 frames)
  - [ ] Roll over (8 frames)
  - [ ] Dodge (4-directional × 8 frames = 32 sprites)
  - [ ] Power up (8 frames)
- [ ] Cinnamon full sprite set (matching Momi's animations)
- [ ] Philo full sprite set
- [ ] Spuds Mackenzie sprites
- [ ] Family NPCs (Mama, Daddy, Auntie, Uncle)
- [ ] Key NPCs (Filipino Walking Lady, Mailman Greg, etc.)

## Enemies
- [ ] Standard enemies batch (30 sprites, idle + 8-frame animations)
- [ ] Boss sprites (larger scale, full animation sets)

## Environments
- [ ] Suburban exterior tileset (3/4 perspective)
- [ ] Momi's house interior tileset
- [ ] Garage gym tileset
- [ ] Strip mall tileset
- [ ] Dog park tileset
- [ ] Beach/boardwalk tileset

## UI
- [ ] Health bar (kibble)
- [ ] Stamina bar (paw prints)
- [ ] Special meter (bone)
- [ ] Character portraits
- [ ] Dialogue box
- [ ] Ring menu
- [ ] Ability icons

## Effects (all 8 frames)
- [ ] Bark VFX
- [ ] Chomp VFX
- [ ] Happy sparkles
- [ ] Zoomies trail
- [ ] Hit flash
- [ ] Damage numbers

---

# ⏱️ TIME ESTIMATES

| Phase | Estimated Time |
|-------|----------------|
| Reference sheets & 8-direction anchors | 3-4 hours |
| Momi complete sprite set (8-dir, 8-frame) | 6-8 hours |
| Cinnamon + Philo sprites | 6-8 hours |
| NPC sprites | 3-4 hours |
| Enemy sprites | 4-5 hours |
| Environment tilesets (3/4 perspective) | 6-8 hours |
| UI elements | 2-3 hours |
| Effects (8 frames each) | 2-3 hours |
| Aseprite cleanup | 8-12 hours |
| **TOTAL** | **40-55 hours** |

Spread over several weekends, totally achievable. The 8-direction, 8-frame standard adds time but results in buttery smooth gameplay.

---

# 📐 QUICK REFERENCE: 8-DIRECTION NAMING

```
      NW   N   NE
        \  |  /
    W ---[M]--- E
        /  |  \
      SW   S   SE
```

| Direction | Suffix | Vector (x, y) | Primary View |
|-----------|--------|---------------|--------------|
| South | `_s` | (0, 1) | Front, full face |
| Southeast | `_se` | (0.7, 0.7) | **Hero angle** — 3/4 front |
| East | `_e` | (1, 0) | Side profile |
| Northeast | `_ne` | (0.7, -0.7) | 3/4 back |
| North | `_n` | (0, -1) | Full back |
| Northwest | `_nw` | (-0.7, -0.7) | 3/4 back (mirrored) |
| West | `_w` | (-1, 0) | Side profile (mirrored) |
| Southwest | `_sw` | (-0.7, 0.7) | 3/4 front (mirrored) |

**Mirroring Strategy:** Generate E, SE, S, NE, N — then mirror horizontally for W, SW, NW to save time. Only works if character is symmetrical (Momi's white markings may require unique sprites for each direction).

---

**You've got this, Tony. One prompt at a time. One sprite at a time. Momi's world will exist.**

The nub will wiggle. The bark will echo. Good girl.
