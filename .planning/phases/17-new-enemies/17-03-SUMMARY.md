# Phase 17 Plan 03: Shadow Creature Enemy Summary

## One-Liner
Shadow Creature with phase-cycling invisibility, ranged shadow bolt projectile, and teleport-on-hurt evasion

## Metadata
- **Phase:** 17 (New Enemy Types)
- **Plan:** 03 of 03
- **Subsystem:** enemies, combat, projectiles
- **Tags:** shadow, ranged, projectile, phasing, teleport, enemy
- **Completed:** 2026-01-29
- **Duration:** ~3 minutes

### Dependencies
- **Requires:** Phase 3 (Enemy Foundation), Phase 17-01 (Stray Cat), Phase 17-02 (Sewer Rat)
- **Provides:** ShadowCreature enemy, ShadowBolt projectile, ShadowPhase state, ShadowRangedAttack state
- **Affects:** Phase 19 (Sewers zone may use shadow creatures), Phase 20 (Mini-Boss could use ranged patterns)

### Tech Stack
- **Added:** components/projectile system (reusable for future ranged attacks)
- **Patterns:** Projectile fire-and-forget, phase cycling via modulate alpha + hurtbox invincibility, teleport evasion on hurt

### Key Files
**Created:**
- `characters/enemies/shadow_creature.gd` — Shadow enemy with phase cycling, teleport-on-hurt
- `characters/enemies/shadow_creature.tscn` — Shadow scene with ShadowPhase initial state
- `characters/enemies/states/shadow_phase.gd` — Phase state: drift, detect, transition to attack
- `characters/enemies/states/shadow_ranged_attack.gd` — Ranged attack: charge telegraph, fire bolt
- `components/projectile/shadow_bolt.gd` — Projectile: travels, trails, damages on hit
- `components/projectile/shadow_bolt.tscn` — Bolt scene with hitbox

**Modified:**
- `world/zones/neighborhood.tscn` — Added 1 ShadowCreature at (180, 300)
- `world/zones/backyard.tscn` — Added 1 ShadowCreature at (350, 130)

## Tasks Completed

| Task | Name | Commit | Key Changes |
|------|------|--------|-------------|
| 1 | Create Shadow Creature + projectile system | cfe0be8 | shadow_bolt.gd/.tscn, shadow_creature.gd, shadow_phase.gd, shadow_ranged_attack.gd |
| 2 | Create shadow scene and place in both zones | 18ed945 | shadow_creature.tscn, neighborhood.tscn, backyard.tscn |

## Implementation Details

### Shadow Creature (ShadowCreature)
- **HP:** 35, **Speed:** patrol 25 / chase 35, **Damage:** 12, **EXP:** 40
- **Detection:** 100px, **Attack Range:** 80px, **Cooldown:** 2.0s
- **Appearance:** Very dark purple amorphous blob with translucent glow aura
- **Phase Cycling:** Every 2s toggles between phased out (alpha 0.1, invulnerable) and phased in (alpha 0.85, vulnerable)
- **Teleport Evasion:** On hurt, teleports 50px in random direction with purple poof particles
- **Drops:** 80% chance 2-4 coins, 30% chance health pickup

### Shadow Phase State (ShadowPhase)
- Initial state: starts phased out (nearly invisible)
- Slow random drift while phased out
- When target detected and phased in: transitions to ShadowRangedAttack
- When target detected but phased out: drifts toward player

### Shadow Ranged Attack State (ShadowRangedAttack)
- 0.4s charge-up with purple "!" telegraph and sprite pulse
- Fires ShadowBolt toward player position
- 0.9s total duration, then returns to ShadowPhase

### Shadow Bolt Projectile (ShadowBolt)
- Speed: 120 px/s, Damage: 12, Lifetime: 3.0s
- Diamond shape visual (dark purple) with glow
- Trail particles while traveling
- Impact burst particles on hit
- Destroys self on hit or after lifetime
- Reusable projectile pattern for future ranged enemies

### Zone Placement
- **Neighborhood:** 1 shadow creature near road area — adds mysterious element
- **Backyard:** 1 shadow creature near trees — lurking in darkness

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| Phase cycling via modulate alpha + hurtbox invincibility | Simple, visual, matches stray cat stealth pattern |
| Teleport uses random direction (not away from player) | More unpredictable/mysterious, fits lore |
| Bolt uses hitbox.gd hit_landed signal for self-destruct | Consistent with existing hitbox system |
| Projectile added to zone parent (not global) | Persists correctly within zone lifecycle |
| ShadowPhase as initial state | Shadows start invisible — player discovers them |
| 1 shadow per zone (sparse) | Mysterious threat should be rare, not overwhelming |

## Deviations from Plan

None — plan executed exactly as written.

## Success Criteria Verification

- [x] Shadow Creature phases in/out of visibility periodically (4s cycle)
- [x] Shadow Creature fires ranged shadow bolt projectiles at the player
- [x] Shadow Creature teleports a short distance when hit (50px random)
- [x] Shadow Creatures appear in both neighborhood and backyard zones
- [x] Shadow bolts travel in a direction and deal damage on contact
- [x] Projectile system is reusable (components/projectile/)

## Next Phase Readiness

Phase 17 (New Enemy Types) is now complete:
- Plan 01: Stray Cat (stealth ambush)
- Plan 02: Sewer Rat (swarm + poison)
- Plan 03: Shadow Creature (ranged + phasing)

Ready for Phase 18 (Shop System). The projectile system created here can be reused for future ranged enemies or hazards.
