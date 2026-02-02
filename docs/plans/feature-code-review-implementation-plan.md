# Feature Code Review and Optimization Plan

## Goal
Deliver a comprehensive code review and targeted improvements focused on efficiency, performance, modularization, E2E coverage (edge cases included), workflow optimization, and UI optimization.

## Scope
In scope:
- Performance profiling and hotspot mitigation
- Modularization of repeated combat and UI logic
- E2E test expansion using the existing UITester framework
- Workflow improvements for running tests and validations
- UI optimization for HUD and menu responsiveness

Out of scope:
- Major gameplay redesign
- New engine upgrades or platform exports
- Large art pipeline changes

## Acceptance Criteria
- [ ] Review findings documented with prioritized action list
- [ ] Merge artifacts removed from core autoloads (SaveManager, GameManager, Events)
- [ ] Group lookups in hot paths are cached or throttled
- [ ] UI update loops minimize per-frame allocations
- [ ] UITester has expanded scenarios covering core UI flows and edge cases
- [ ] Headless E2E runner exists and is documented
- [ ] Tests and workflow scripts are updated and runnable
- [ ] No new errors in editor output for core scenes

## Architecture Diagram (ASCII)

SceneTree
  |
  v
EntityRegistry (autoload)
  |-> Player(s)
  |-> Enemies
  |-> Companions
  |
  v
Systems (AudioManager, EffectsManager, AutoBot, AI)

UI
  |-> HUD (Health, Guard, Coin, Combo)
  |-> Menus (Title, Pause, Settings)
  v
UITester (autoload)
  |-> E2E runner scene
  v
Tests (headless + manual checklists)

Save/Load
  GameManager <-> SaveManager <-> JSON save file

## Implementation Steps (file by file)

1) Review and findings docs
- Create `docs/review/code-review-findings.md`
- Create `docs/review/perf-baseline.md`
- Create `docs/review/ui-audit.md`
- Create `docs/review/testing-gap-analysis.md`

2) Resolve merge artifacts and duplicate logic
- Clean up `autoloads/save_manager.gd` (single authoritative implementation)
- Clean up `autoloads/game_manager.gd` (remove duplicated blocks and separators)
- Clean up `autoloads/events.gd` (remove duplicate signal blocks)

3) Performance caching for group lookups
- Add `autoloads/entity_registry.gd` to track enemies/players/companions
- Update `project.godot` to autoload EntityRegistry
- Replace hot `get_nodes_in_group` usage in:
  - `characters/player/player.gd`
  - `autoloads/audio_manager.gd`
  - `autoloads/effects_manager.gd`
  - `autoloads/auto_bot.gd`
  - `systems/party/companion_ai.gd`
  - `characters/enemies/enemy_base.gd`
  - `components/health/health_pickup.gd`
  - `components/pickup/coin_pickup.gd`
  - `characters/enemies/projectiles/gnome_bomb.gd`

4) Modularize combat damage helpers
- Add `components/combat/damage_context.gd` (damage data container)
- Add `components/combat/damage_utils.gd` (apply helpers for player/enemy)
- Update projectile/attack code to use helper:
  - `characters/enemies/states/pigeon_swoop_attack.gd`
  - `characters/enemies/projectiles/gnome_bomb.gd`

5) E2E testing expansion
- Extend scenarios in `autoloads/ui_tester.gd` for edge cases
- Add `tests/e2e_full_suite.gd` and `tests/e2e_full_suite.tscn`
- Update `tests/E2E_VERIFICATION_GUIDE.md` with new coverage
- Update `tests/run_tests.sh` and `tests/run_tests.bat` to include E2E

6) Workflow and UI optimization
- Add `scripts/run_e2e.sh` and `scripts/run_e2e.bat`
- Update `tests/README.md` with new commands
- Add UI theme resource `ui/themes/hud_theme.tres`
- Update `ui/hud/game_hud.tscn` to apply theme
- Reduce per-frame work in `ui/hud/coin_counter.gd` and `ui/hud/combo_counter.gd`

## Task List and Dependencies
1. Review and findings docs (CR-1)
2. Merge artifact cleanup (CR-2) depends on CR-1
3. EntityRegistry + caching (CR-3) depends on CR-1
4. Damage helpers modularization (CR-4) depends on CR-1
5. E2E expansion (CR-5) depends on CR-2 and CR-3
6. Workflow + UI optimization (CR-6) depends on CR-3

## Test Matrix (cases x layers)

| Case | Unit | Integration | E2E | Manual |
|------|------|-------------|-----|--------|
| Save/load JSON schema validation | Yes | Yes | - | Yes |
| EntityRegistry updates on spawn/free | Yes | Yes | - | Yes |
| Player HUD updates (health, coins, guard) | - | Yes | Yes | Yes |
| Pause -> resume -> HUD state | - | Yes | Yes | Yes |
| Ring menu open/close | - | Yes | Yes | Yes |
| Combat hit flow (hitbox -> hurtbox) | Yes | Yes | - | Yes |
| Enemy AI with cached group lookups | - | Yes | - | Yes |
| UI perf (combo sparks, coin counter) | - | Yes | - | Yes |

## Rollout Plan
1) Land merge artifact cleanup and docs first
2) Add EntityRegistry and update call sites
3) Add damage helpers and update projectile logic
4) Expand UITester and add E2E runner
5) Apply UI theme and reduce per-frame allocations

## Rollback Plan
- Revert EntityRegistry autoload and restore direct group lookups
- Revert damage helper usage and fall back to direct calls
- Disable E2E runner in test scripts
- Revert UI theme changes if layout regressions occur

## Open Questions
- Which SaveManager version is authoritative (JSON vs ConfigFile)
- Are there existing performance targets to benchmark against
- Which UI screens are most critical for optimization (HUD, pause, ring menu)
