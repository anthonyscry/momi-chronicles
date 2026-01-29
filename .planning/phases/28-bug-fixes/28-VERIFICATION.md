---
phase: 28-bug-fixes
verified: 2026-01-29T07:30:00Z
status: passed
score: 4/4 must-haves verified
---

# Phase 28: Critical Bug Fixes Verification Report

**Phase Goal:** Fix all player-facing bugs discovered in codebase audit — items work as expected
**Verified:** 2026-01-29
**Status:** PASSED
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Using Revival Bone from ring menu revives a knocked-out companion with 50% HP | ✓ VERIFIED | `inventory.gd` L174-184: accesses `party_manager.knocked_out`, calls `revive_companion(companion_id, value)`, returns false when nobody knocked out. `party_manager.gd` L108-118: substantive implementation — erases from knocked_out, calls `companions[id].revive(health_percent)`, emits signals. |
| 2 | Using Antidote from ring menu clears active poison (DoT stops, green tint removed) | ✓ VERIFIED | `inventory.gd` L156-157: calls `hp.clear_poison()` (not old `cure_poison`). `health_component.gd` L178-191: `clear_poison()` resets `is_poisoned`, `poison_damage`, `poison_remaining`, `poison_stack_count`, emits `poison_ended`, restores sprite modulate to `Color.WHITE`. Inventory also resets Sprite2D modulate (L159-160) as backup. |
| 3 | Boss summon state uses preload() — no frame stutter when Raccoon King summons | ✓ VERIFIED | `boss_attack_summon.gd` L8: `const RACCOON_SCENE: PackedScene = preload("res://characters/enemies/raccoon.tscn")`. L43: `var raccoon_scene = RACCOON_SCENE`. Zero `= load(` calls in file. L48: `raccoon_scene.instantiate()` creates enemy from preloaded const. |
| 4 | Enemy respawn uses cached PackedScene — no runtime load() stutter | ✓ VERIFIED | `base_zone.gd` L216: `"scene_resource": load(enemy.scene_file_path)` cached at zone init (`_capture_enemy_spawn_data()` called from `_ready()`). L310: `_respawn_enemy()` uses `spawn_entry.get("scene_resource")` with fallback config lookup (L312-316). Propagated through death cycle: L246 (`_on_enemy_died`), L344 (`_on_respawned_enemy_died`). Only `load()` in file is L216 (init-time, not hot path). |

**Score:** 4/4 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `systems/inventory/inventory.gd` | Working REVIVE and CURE_STATUS item effects | ✓ VERIFIED | 247 lines, substantive. REVIVE branch (L174-184) calls `party_manager.revive_companion()`. CURE_STATUS (L152-163) calls `clear_poison()`. No stubs, no TODOs. |
| `characters/enemies/states/boss_attack_summon.gd` | Preloaded raccoon scene for boss summon | ✓ VERIFIED | 79 lines, substantive. L8: `const RACCOON_SCENE = preload(...)`. No runtime `load()`. Wired: L43 assigns const, L48 instantiates. |
| `world/zones/base_zone.gd` | Cached PackedScene for enemy respawn | ✓ VERIFIED | 353 lines, substantive. `scene_resource` appears 5 times across capture/death/respawn paths. No runtime `load()` in hot paths. |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `inventory.gd` | `party_manager.gd` | `GameManager.party_manager.revive_companion()` | ✓ WIRED | L181: `GameManager.party_manager.revive_companion(companion_id, value)`. Target method exists at party_manager.gd L108 with matching signature `(companion_id: String, health_percent: float = 0.5)`. |
| `inventory.gd` | `health_component.gd` | `clear_poison()` method call | ✓ WIRED | L156: `hp.has_method("clear_poison")` guard. L157: `hp.clear_poison()`. Target method exists at health_component.gd L178 — substantive implementation (resets all poison state + visual). Method name matches exactly. |
| `boss_attack_summon.gd` | `res://characters/enemies/raccoon.tscn` | `const preload at top of file` | ✓ WIRED | L8: `const RACCOON_SCENE: PackedScene = preload("res://characters/enemies/raccoon.tscn")`. L43: `var raccoon_scene = RACCOON_SCENE`. L48: `raccoon_scene.instantiate()`. Full chain: preload → assign → instantiate. |
| `base_zone.gd` | `enemy_spawn_data/original_enemy_configs` | `scene_resource key in config dict` | ✓ WIRED | L216: cached at init. L246: propagated in `_on_enemy_died()`. L310: consumed in `_respawn_enemy()`. L315: fallback from `original_enemy_configs`. L344: re-propagated in `_on_respawned_enemy_died()`. Full cycle covered. |

### Requirements Coverage

| Requirement | Status | Blocking Issue |
|-------------|--------|----------------|
| BUG-01: Revival Bone from ring menu revives knocked-out companion | ✓ SATISFIED | — |
| BUG-02: Antidote cures poison (method name matches health_component) | ✓ SATISFIED | — |
| BUG-03: Boss summon uses preload() instead of runtime load() | ✓ SATISFIED | — |
| DEBT-01: All scene instantiation uses preload/cached — no runtime load() in hot paths | ✓ SATISFIED | — |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| — | — | — | — | No anti-patterns found. Zero TODOs, FIXMEs, placeholders, or stub patterns in any modified file. |

### Human Verification Required

### 1. Revival Bone In-Game Test
**Test:** Knock out a companion in combat, open ring menu, use Revival Bone item
**Expected:** Companion revives with 50% HP, gold glow effect appears, item is consumed
**Why human:** Runtime game flow — need to verify the companion actually reappears and can be controlled after revival

### 2. Revival Bone Empty Guard Test
**Test:** With all companions alive, attempt to use Revival Bone from ring menu
**Expected:** Item is NOT consumed (returns false), nothing happens
**Why human:** Need to verify UI feedback when item can't be used

### 3. Antidote In-Game Test
**Test:** Get poisoned by an enemy (green tint visible, DoT ticking), use Antidote from ring menu
**Expected:** Poison DoT stops immediately, green sprite tint removed (back to white), green glow effect plays
**Why human:** Visual verification of tint removal + confirming DoT actually stops in real-time

### 4. Boss Summon Frame Test
**Test:** Fight Raccoon King until summon phase, watch for frame stutters when minions appear
**Expected:** Smooth summoning with no visible frame hitch
**Why human:** Performance feel — frame stutter is perceptual

### 5. Enemy Respawn Frame Test
**Test:** Kill enemies in a zone, wait for respawn timer, observe respawn for stutters
**Expected:** Enemy respawns smoothly with no visible frame hitch
**Why human:** Performance feel — requires real gameplay observation over time

### Gaps Summary

No gaps found. All 4 must-have truths verified through code inspection:

1. **Revival Bone** — Full implementation chain verified: `inventory.gd` REVIVE branch → `party_manager.knocked_out` check → `revive_companion()` call → party_manager implementation (erase from knocked_out, call companion.revive, emit signals). Guard against wasted item when nobody knocked out.

2. **Antidote** — Method name mismatch fixed: `cure_poison` → `clear_poison` throughout. Wiring confirmed: `inventory.gd` → `health_component.gd` `clear_poison()` which resets all poison state and restores sprite modulate.

3. **Boss Summon** — `preload()` const at file top, used in `_do_summon()`. Zero runtime `load()` calls in file.

4. **Enemy Respawn** — Scene cached at zone init via `load()` in `_capture_enemy_spawn_data()` (runs once at `_ready()`). Propagated through full death/respawn cycle. Zero runtime `load()` in hot paths.

---

_Verified: 2026-01-29T07:30:00Z_
_Verifier: Claude (gsd-verifier)_
