# Project: Momi's Adventure

A 3/4 perspective pixel art action RPG. Momi the French Bulldog leads the Bulldog Squad
— a neighborhood watch protecting their community from the Raccoon King and his minions.

| Detail | Value |
|--------|-------|
| **Engine** | Godot 4.5 / GDScript |
| **Resolution** | 384×216 (16:9 pixel art, 16x16/32x32 sprites) |
| **Perspective** | 3/4 top-down (Stardew Valley style) |
| **Rendering** | Nearest-neighbor filtering (pixel-perfect) |
| **Current Milestone** | v1.6 Visual Polish — replacing placeholder shapes with pixel art |
| **Planning Docs** | `.planning/PROJECT.md`, `.planning/STATE.md`, `.planning/ROADMAP.md` |

---

## Quick Reference

### Key Paths

```
prod/                          # Game source code root
├── autoloads/                 # Global singletons (Events, GameManager, etc.)
├── entities/player/           # Player scene, states, components
├── entities/enemies/          # Enemy scenes and AI
├── entities/companions/       # Cinnamon, Philo
├── systems/                   # Inventory, equipment, party, shop, save
├── ui/                        # HUD, ring menu, shop UI, menus
├── zones/                     # Neighborhood, Backyard, Sewers, Boss Arena
└── components/                # Reusable: HitboxComponent, HealthComponent, etc.
project.godot                  # Engine config, autoloads, input map, layers
.planning/config.json          # GSD workflow settings (source of truth)
.planning/STATE.md             # Project state, decisions, session continuity
.planning/ROADMAP.md           # Phase breakdown with milestones
.auto-claude/specs/            # Auto-Claude task specs and plans
```

### Commands

```bash
godot --path . --editor        # Open in Godot Editor
godot --path .                 # Run the game
```

### Autoloads (load order matters)

| Autoload | Path | Purpose |
|----------|------|---------|
| DebugLogger | `autoloads/debug_logger.gd` | Development logging |
| Events | `autoloads/events.gd` | Global signal bus (30+ signals) |
| ItemDatabase | `systems/inventory/item_database.gd` | Item definitions |
| EquipmentDatabase | `systems/equipment/equipment_database.gd` | Equipment stats |
| CompanionData | `systems/party/companion_data.gd` | Companion configs |
| GameManager | `autoloads/game_manager.gd` | Game state, pause, zones, currency |
| AudioManager | `autoloads/audio_manager.gd` | BGM + SFX |
| EffectsManager | `autoloads/effects_manager.gd` | Hit flash, screen shake, particles |
| AutoBot | `autoloads/auto_bot.gd` | AI player (F1 toggle) |
| SaveManager | `autoloads/save_manager.gd` | Atomic save/load with backup |
| AudioDebug | `ui/hud/audio_debug.tscn` | Audio debug overlay |
| UITester | `autoloads/ui_tester.gd` | Automated UI testing (F2) |
| RingMenu | `ui/ring_menu/ring_menu.tscn` | Secret of Mana-style radial menu |
| ShopCatalog | `systems/shop/shop_catalog.gd` | Shop pricing and stock |
| ShopUI | `ui/shop/shop_ui.tscn` | Shop interface |

---

## GSD Settings

GSD (Get Shit Done) workflow settings live in `.planning/config.json`. These settings are
the **source of truth** for how agents should behave when working on this project.

**Current values** (read `.planning/config.json` to verify):

| Setting | Value | Meaning |
|---------|-------|---------|
| `mode` | `"yolo"` | Run fully autonomously — skip permission prompts, don't ask for confirmation |
| `depth` | `"standard"` | Normal planning thoroughness (5-8 phases per milestone) |
| `model_profile` | `"quality"` | Use the most capable model (Opus) for all pipeline phases |
| `workflow.research` | `true` | Spawn research agents during spec/planning phases |
| `workflow.plan_check` | `true` | Validate plans before coding begins |
| `workflow.verifier` | `true` | Run QA verification after implementation |
| `git.auto_commit` | `false` | Agents must NOT auto-commit; commit only when instructed |
| `git.branching_strategy` | `"none"` | Commit directly to current branch (no feature branches) |
| `git.base_branch` | `"master"` | Worktree base branch |

### How to Apply These Settings

- **`mode: "yolo"`** → Proceed without asking. Make decisions, implement, verify. Only stop for genuine blockers.
- **`model_profile: "quality"`** → Favor thoroughness over speed. Think deeply about architecture.
- **`workflow.verifier: true`** → Always verify your work. Run checks. Don't mark done until verified.
- **`git.auto_commit: false`** → NEVER auto-commit. Wait for explicit commit instructions.

---

## GSD ↔ Auto-Claude Settings Mapping

When configuring Auto-Claude `task_metadata.json` for new tasks, derive values from
`.planning/config.json` using this mapping:

| GSD Setting | Auto-Claude Equivalent | Behavior |
|-------------|----------------------|----------|
| `mode: "yolo"` | `--dangerously-skip-permissions` flag | Agents skip all permission prompts |
| `mode: "interactive"` | Normal Claude permissions | Agents prompt for approval at each action |
| `model_profile: "quality"` | `phaseModels: { spec: "opus", planning: "opus", coding: "opus", qa: "opus" }` | All phases use most capable model |
| `model_profile: "balanced"` | `phaseModels: { spec: "opus", planning: "opus", coding: "sonnet", qa: "sonnet" }` | Opus for planning, Sonnet for execution |
| `model_profile: "budget"` | `phaseModels: { spec: "sonnet", planning: "sonnet", coding: "sonnet", qa: "haiku" }` | Sonnet for writing, Haiku for verification |
| `depth: "quick"` | Complexity tier "simple" (3 phases) | Fast iteration, 1-2 files |
| `depth: "standard"` | Complexity tier "standard" (6 phases) | Normal planning depth, 3-10 files |
| `depth: "comprehensive"` | Complexity tier "complex" (8 phases) | Thorough planning, 10+ files |
| `workflow.research: true` | Research subagent during spec creation | Domain research before planning |
| `workflow.plan_check: true` | Validation phase after planning | Plans reviewed before coding begins |
| `workflow.verifier: true` | QA phase enabled (qa_reviewer + qa_fixer) | Post-implementation verification loop |
| `git.branching_strategy: "none"` | `baseBranch: "master"`, commits directly | No feature branches created |

> **Note:** Auto-Claude does NOT programmatically read `.planning/config.json`. This
> mapping is enforced through CLAUDE.md instructions (loaded into every agent session)
> and by manually setting `task_metadata.json` values to match the GSD profile.

---

## Architecture

### Core Principles

1. **Component-based composition** — NO deep inheritance. Entities are composed from
   reusable components (HealthComponent, HitboxComponent, HurtboxComponent, GuardComponent).

2. **Events signal bus** — The `Events` autoload carries 30+ signals for cross-system
   communication. Systems emit and listen on Events, never reference each other directly.

3. **Call-down, signal-up** — Parents call methods on children (`child.do_thing()`).
   Children notify parents via signals (`signal thing_happened`). Never call up the tree.

4. **State machines** — All entities (player, enemies, companions) use state machine nodes.
   Each state is a child Node with `enter()`, `exit()`, `update()`, `physics_update()`.

5. **Path-based `extends`** — Use `extends "res://path/to/script.gd"`, NOT `class_name`.
   This avoids autoload scope issues in Godot 4.5.

6. **Programmatic UI** — UI elements are built in code (`_ready()`), not in the editor.
   Matches the ring menu pattern. Full control over layout.

### Scene Structure

```
Entity (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
├── AnimationPlayer
├── HealthComponent (Node)
├── HurtboxComponent (Area2D)
├── HitboxComponent (Area2D)         # if attacker
├── DetectionArea (Area2D)            # if enemy
└── StateMachine (Node)
    ├── Idle, Walk, Run               # movement states
    ├── Attack, Hurt, Dodge, Death    # combat states
    └── [entity-specific states]
```

### Collision Layers

| Layer | Name | Used By |
|-------|------|---------|
| 1 | World | Walls, obstacles |
| 2 | Player | Player CharacterBody2D |
| 3 | Enemy | Enemy CharacterBody2D |
| 4 | PlayerHurtbox | Player's hurtbox |
| 5 | EnemyHurtbox | Enemy hurtboxes |
| 6 | PlayerHitbox | Player attack hitboxes |
| 7 | EnemyHitbox | Enemy attack hitboxes |
| 8 | Trigger | Zone transitions, pickups |

### Damage Flow

1. Attack state activates hitbox → 2. Hitbox enters enemy hurtbox → 3. Hurtbox calls
`take_damage()` on HealthComponent → 4. HealthComponent emits `health_changed` →
5. State machine transitions to Hurt → 6. If HP ≤ 0: `died` signal → Death state →
7. `Events.enemy_defeated` emitted for scoring/UI.

---

## Conventions

### Naming

| Element | Convention | Example |
|---------|-----------|---------|
| Script files | `snake_case.gd` | `health_component.gd` |
| Scene files | `snake_case.tscn` | `ring_menu.tscn` |
| Classes | `PascalCase` | `HealthComponent` |
| Variables/functions | `snake_case` | `max_health`, `take_damage()` |
| Signals | `snake_case` | `health_changed`, `died` |
| Constants | `SCREAMING_SNAKE_CASE` | `MAX_COMBO_COUNT` |
| Enums | `PascalCase` name, `SCREAMING_SNAKE` values | `enum State { IDLE, ATTACKING }` |

### Resource Loading

- **`preload()`** for ALL scene references — eliminates runtime stutter
- **`load()`** cached at zone init for dynamic scene paths (can't `preload()` dynamic paths)
- NEVER use uncached `load()` during gameplay

### Logging

- Use `DebugLogger` autoload for development logging — NOT `print()` or `push_error()`
- DebugLogger handles categories, log levels, and conditional output

### Save System

- Save data version v3 — backward compatible with v1/v2 via `.get()` defaults
- Atomic write with backup file
- Auto-save on zone entry and boss defeat
- Data: level, EXP, coins, zone, boss flags, equipment, inventory, party state

### Key Architectural Decisions

| Decision | Rationale |
|----------|-----------|
| Component-based (not inheritance) | Composable, reusable systems |
| Events autoload signal bus | Decoupled cross-system communication |
| Path-based `extends` (not `class_name`) | Avoids autoload scope issues |
| Programmatic UI (code-built `_ready()`) | Matches ring menu pattern, full control |
| `preload()` for scene references | Eliminates runtime load stutter |
| Cache `load()` at zone init | Dynamic paths can't use `preload()` |
| Re-emit Events signals for HUD refresh | HUD already listens — zero script changes |
| Clear only `Inventory.active_buffs` on restart | Only autoload child state survives scene reload |
| First-in-first-revived for Revival Bone | Deterministic `knocked_out.keys()[0]` |

---

## Development Guidelines

### DO

- **Follow existing patterns** — study neighboring files before writing new code
- **Use component composition** — add HealthComponent, HitboxComponent, etc. as child nodes
- **Emit signals through Events bus** — for anything multiple systems care about
- **Use `preload()`** for scene/resource references
- **Use DebugLogger** for development output
- **Use state machines** for entity behavior
- **Build UI programmatically** in `_ready()` — match the ring menu pattern
- **Use `.get()` with defaults** when reading save data — backward compatibility
- **Verify your work** — run the game, check for errors, test the change
- **Read `.planning/config.json`** before starting — know the current GSD settings

### DON'T / NEVER

- **NEVER use `class_name`** — use path-based `extends` instead
- **NEVER use bare `print()`** — use DebugLogger
- **NEVER call parent methods from child nodes** — signal up, call down
- **NEVER reference autoloads directly from components** — use signals or dependency injection
- **NEVER use uncached `load()` during gameplay** — preload or cache at init
- **NEVER modify `.auto-claude/.env`** or existing `task_metadata.json` files directly
- **NEVER modify `.planning/ROADMAP.md`** or `.planning/STATE.md` without explicit instruction
- **NEVER auto-commit** — `git.auto_commit` is `false`; wait for instructions
- **NEVER create deep inheritance hierarchies** — use composition
- **NEVER add game logic to autoloads** — autoloads are for coordination, not behavior

### Anti-Patterns to Avoid

| Anti-Pattern | Why It's Bad | Do This Instead |
|-------------|-------------|-----------------|
| `class_name MyClass` | Autoload scope issues | `extends "res://path/to/base.gd"` |
| `print("debug")` | Uncontrolled output | `DebugLogger.log(category, msg)` |
| Deep inheritance trees | Rigid, hard to modify | Component composition |
| Direct cross-system calls | Tight coupling | Events signal bus |
| Editor-built complex UI | Inconsistent with codebase | Programmatic UI in `_ready()` |
| `load()` in `_process()` | Runtime stutter | `preload()` or cached `load()` at init |
