---
phase: 17-new-enemies
verified: 2026-01-29T03:50:00Z
status: passed
score: 7/7 must-haves verified
retroactive: true
must_haves:
  truths:
    - "Stray Cat enemy has stealth/pounce/retreat states"
    - "Sewer Rat enemy has swarm pack behavior and poison bite DoT"
    - "Shadow Creature has phase shift, ranged shadow bolt, and teleport evasion"
    - "Poison DoT system on HealthComponent is reusable by any entity"
    - "Projectile system (shadow bolt) is reusable for future ranged attacks"
    - "Unique drop tables configured per enemy type"
    - "All new enemies spawnable in appropriate zones"
  artifacts:
    - path: "characters/enemies/stray_cat.gd"
      provides: "StrayCat enemy with stealth ambush behavior"
    - path: "characters/enemies/stray_cat.tscn"
      provides: "StrayCat scene with 8 states"
    - path: "characters/enemies/states/cat_stealth.gd"
      provides: "Stealth state with alpha modulation (0.15)"
    - path: "characters/enemies/states/cat_pounce.gd"
      provides: "Pounce lunge attack (200px/s, 0.3s)"
    - path: "characters/enemies/states/cat_retreat.gd"
      provides: "Retreat state with alpha tween back to stealth"
    - path: "characters/enemies/sewer_rat.gd"
      provides: "SewerRat enemy with pack_id and poison bite"
    - path: "characters/enemies/sewer_rat.tscn"
      provides: "SewerRat scene with swarm states"
    - path: "characters/enemies/states/rat_swarm_chase.gd"
      provides: "Pack-aware chase with cohesion and jitter"
    - path: "characters/enemies/states/rat_poison_attack.gd"
      provides: "Poison bite attack applying DoT via HealthComponent"
    - path: "characters/enemies/shadow_creature.gd"
      provides: "ShadowCreature with phase cycling and teleport"
    - path: "characters/enemies/shadow_creature.tscn"
      provides: "Shadow scene with ShadowPhase initial state"
    - path: "characters/enemies/states/shadow_phase.gd"
      provides: "Phase state: drift, detect, transition"
    - path: "characters/enemies/states/shadow_ranged_attack.gd"
      provides: "Ranged attack: charge, fire shadow bolt"
    - path: "components/projectile/shadow_bolt.gd"
      provides: "Fire-and-forget projectile with trail and impact"
    - path: "components/projectile/shadow_bolt.tscn"
      provides: "Shadow bolt scene with hitbox"
    - path: "components/health/health_component.gd"
      provides: "Poison DoT methods (apply_poison, clear_poison)"
  key_links:
    - from: "cat_pounce.gd"
      to: "enemy_base.gd hitbox"
      via: "Hitbox active frames during pounce lunge"
    - from: "rat_poison_attack.gd"
      to: "health_component.gd"
      via: "apply_poison(3, 3.0) on hit via hit_targets"
    - from: "shadow_ranged_attack.gd"
      to: "shadow_bolt.tscn"
      via: "instantiate() and add_child to zone"
    - from: "shadow_creature.gd"
      to: "hurtbox monitoring"
      via: "Phase cycling toggles hurtbox.monitorable"
  gaps: []
---

# Phase 17: New Enemy Types — Verification Report

**Phase Goal:** Three new enemies with unique combat behaviors that force different tactics
**Verified:** 2026-01-29T03:50:00Z
**Status:** ✅ PASSED
**Re-verification:** Retroactive — verified from existing plan SUMMARYs during v1.3 milestone audit

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Stray Cat enemy has stealth/pounce/retreat states | ✓ VERIFIED | `stray_cat.gd` extends enemy_base with CatStealth initial state. `cat_stealth.gd` sets sprite alpha to 0.15, stalks at half speed. `cat_pounce.gd` lunges at 200px/s with 0.1-0.25s active hitbox frames. `cat_retreat.gd` flees and tweens alpha back to stealth. (17-01-SUMMARY) |
| 2 | Sewer Rat enemy has swarm pack behavior and poison bite DoT | ✓ VERIFIED | `sewer_rat.gd` has `pack_id` for grouping. `rat_swarm_chase.gd` applies 25% pack cohesion pull toward center with erratic jitter. `rat_poison_attack.gd` calls `health_component.apply_poison(3, 3.0)` after hit via `hitbox.hit_targets`. (17-02-SUMMARY) |
| 3 | Shadow Creature has phase shift, ranged shadow bolt, and teleport evasion | ✓ VERIFIED | `shadow_creature.gd` toggles phase every 2s (alpha 0.1 invulnerable / 0.85 vulnerable). `shadow_ranged_attack.gd` fires ShadowBolt projectile after 0.4s charge. `_on_hurt` teleports 50px random direction with purple poof. (17-03-SUMMARY) |
| 4 | Poison DoT system on HealthComponent is reusable | ✓ VERIFIED | `health_component.gd` has `apply_poison(damage_per_tick, duration)` and `clear_poison()`. Not rat-specific — any enemy/hazard can call apply_poison. Used by toxic puddles in Phase 19. Signals: `poison_started`, `poison_ended`. (17-02-SUMMARY) |
| 5 | Projectile system (shadow bolt) is reusable | ✓ VERIFIED | `components/projectile/shadow_bolt.gd` and `.tscn` — fire-and-forget projectile with speed, damage, lifetime params. Trail particles, impact burst. Hitbox-based collision. Reusable pattern for future ranged attacks. (17-03-SUMMARY) |
| 6 | Unique drop tables configured per enemy type | ✓ VERIFIED | StrayCat drops: custom coins + rare items (17-01-SUMMARY). SewerRat drops: 60% coin, 10% health pickup (17-02-SUMMARY). ShadowCreature drops: 80% 2-4 coins, 30% health pickup (17-03-SUMMARY). Each configured in respective .gd file. |
| 7 | All new enemies spawnable in appropriate zones | ✓ VERIFIED | StrayCat: 2 in neighborhood at (300,400) and (550,200) (17-01-SUMMARY). SewerRat: pack of 4 in backyard near shed (~280,85) (17-02-SUMMARY). ShadowCreature: 1 in neighborhood (180,300), 1 in backyard (350,130) (17-03-SUMMARY). Sewers zone adds more rats and shadows in Phase 19. |

**Score:** 7/7 truths verified

### Required Artifacts

| Artifact | Expected | Exists | Substantive | Status |
|----------|----------|--------|-------------|--------|
| `characters/enemies/stray_cat.gd` | StrayCat enemy | ✓ | ✓ Full enemy with stealth behavior | ✓ VERIFIED |
| `characters/enemies/stray_cat.tscn` | StrayCat scene | ✓ | ✓ 8-state StateMachine | ✓ VERIFIED |
| `characters/enemies/states/cat_stealth.gd` | Stealth state | ✓ | ✓ Alpha modulation + stalking | ✓ VERIFIED |
| `characters/enemies/states/cat_pounce.gd` | Pounce attack | ✓ | ✓ Lunge with active hitbox frames | ✓ VERIFIED |
| `characters/enemies/states/cat_retreat.gd` | Retreat state | ✓ | ✓ Flee + alpha tween | ✓ VERIFIED |
| `characters/enemies/sewer_rat.gd` | SewerRat enemy | ✓ | ✓ Pack AI + poison bite | ✓ VERIFIED |
| `characters/enemies/sewer_rat.tscn` | SewerRat scene | ✓ | ✓ Swarm-specific states | ✓ VERIFIED |
| `characters/enemies/states/rat_swarm_chase.gd` | Swarm chase | ✓ | ✓ Pack cohesion + jitter | ✓ VERIFIED |
| `characters/enemies/states/rat_poison_attack.gd` | Poison attack | ✓ | ✓ apply_poison via hit_targets | ✓ VERIFIED |
| `characters/enemies/shadow_creature.gd` | Shadow enemy | ✓ | ✓ Phase cycling + teleport | ✓ VERIFIED |
| `characters/enemies/shadow_creature.tscn` | Shadow scene | ✓ | ✓ ShadowPhase initial state | ✓ VERIFIED |
| `characters/enemies/states/shadow_phase.gd` | Phase state | ✓ | ✓ Drift + detect + transition | ✓ VERIFIED |
| `characters/enemies/states/shadow_ranged_attack.gd` | Ranged attack | ✓ | ✓ Charge + fire bolt | ✓ VERIFIED |
| `components/projectile/shadow_bolt.gd` | Projectile logic | ✓ | ✓ Travel + trail + damage + cleanup | ✓ VERIFIED |
| `components/projectile/shadow_bolt.tscn` | Bolt scene | ✓ | ✓ With hitbox | ✓ VERIFIED |
| `components/health/health_component.gd` | Poison DoT methods | ✓ | ✓ apply/clear/tick/signals | ✓ VERIFIED |

### Deliverable Coverage

| Deliverable | Status | Evidence |
|-------------|--------|----------|
| Stray Cat (stealthy ambusher with stealth/pounce/retreat) | ✓ SATISFIED | 3 custom states, 0.15 alpha stealth, 200px/s pounce, 20 damage, auto-retreat loop |
| Sewer Rat (swarm packs with poison bite DoT) | ✓ SATISFIED | pack_id grouping, cohesion chase, 5 damage + 3/tick poison for 3s, placed as pack of 4 |
| Shadow Creature (phase in/out, ranged bolt, teleport) | ✓ SATISFIED | 2s phase cycle (0.1/0.85 alpha), shadow bolt at 120px/s, 50px random teleport on hurt |
| Poison DoT system on HealthComponent | ✓ SATISFIED | Generic apply_poison/clear_poison, signal-based, tick interval configurable, green tint visual |
| Projectile system (shadow bolt, reusable) | ✓ SATISFIED | components/projectile/ — fire-and-forget, hitbox collision, trail particles, configurable speed/damage/lifetime |
| Unique drop tables per enemy type | ✓ SATISFIED | Each enemy .gd has unique drop configuration (coins, health, rare items) |
| All enemies spawnable in appropriate zones | ✓ SATISFIED | Cats in neighborhood, rats in backyard, shadows in both. Sewers adds more in Phase 19 |

### Retroactive Verification Note

This verification was performed retroactively during the v1.3 milestone audit (Phase 22). Phase 17 was executed and confirmed working during development — all three enemies were used and further validated during Phases 18-20 (shop sells their drops, sewers zone spawns them, mini-bosses interact with them). This document formalizes the verification to match the format established for Phases 13-20.

**Source documents:**
- `.planning/phases/17-new-enemies/17-01-SUMMARY.md` (Stray Cat)
- `.planning/phases/17-new-enemies/17-02-SUMMARY.md` (Sewer Rat)
- `.planning/phases/17-new-enemies/17-03-SUMMARY.md` (Shadow Creature)

---

_Verified: 2026-01-29T03:50:00Z_
_Verifier: Claude (gsd-executor, retroactive from v1.3 audit)_
