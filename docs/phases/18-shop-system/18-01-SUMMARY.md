# Phase 18 Plan 01: Shop Catalog & NPC Summary

**One-liner:** Nutkin the Squirrel NPC with polygon visuals and ShopCatalog autoload pricing 10 items + 15 equipment

## Metadata

- **Phase:** 18-shop-system
- **Plan:** 01
- **Subsystem:** shop
- **Tags:** shop, npc, catalog, pricing, autoload, interaction
- **Completed:** 2026-01-29
- **Duration:** ~5 minutes

### Dependency Graph

- **Requires:** Phase 16 (inventory, equipment systems), Events signal bus
- **Provides:** ShopCatalog autoload, ShopNPC scene, shop signals
- **Affects:** Phase 18-02 (shop UI), Phase 18-03 (buy/sell transactions)

### Tech Tracking

- **tech-stack.added:** none (pure GDScript)
- **tech-stack.patterns:** NPC interaction via Area2D body detection + input action, catalog autoload pattern

### File Tracking

- **key-files.created:**
  - `systems/shop/shop_catalog.gd` — Price catalog autoload with all item/equipment prices
  - `characters/npcs/shop_npc.gd` — Nutkin NPC with polygon visuals and interaction
  - `characters/npcs/shop_npc.tscn` — ShopNPC scene file
- **key-files.modified:**
  - `autoloads/events.gd` — Added shop_interact_requested and shop_closed signals
  - `project.godot` — Registered ShopCatalog autoload
  - `world/zones/neighborhood.tscn` — Added Nutkin NPC instance at (400, 350)
  - `world/zones/neighborhood.gd` — Added shop spawn point and debug signal listener

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Create shop catalog and shop NPC with interaction | 7f29a04 | shop_catalog.gd, shop_npc.gd, shop_npc.tscn, events.gd, project.godot |
| 2 | Place Nutkin in neighborhood zone | 15031cb | neighborhood.tscn, neighborhood.gd |

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| Polygon-based squirrel visual (code-generated) | Matches project pattern of programmatic Polygon2D sprites |
| Area2D for NPC interaction (collision_mask = 2) | Same pattern as ZoneExit — detects player on layer 2 |
| Idle bob animation (1px at 0.5Hz) | Subtle life-like feel without complex animation system |
| 50% sell multiplier | Standard RPG sell-back rate, balanced coin economy |
| Temporary debug print for shop interaction | Removed when Plan 02 adds actual shop UI listener |

## Deviations from Plan

None — plan executed exactly as written.

## Verification Results

- [x] ShopCatalog autoload registered in project.godot
- [x] ShopCatalog has prices for all 10 items and 15 equipment pieces
- [x] ShopNPC scene loads without errors
- [x] Nutkin visible in neighborhood zone at (400, 350)
- [x] Interaction prompt appears/disappears based on player proximity
- [x] E key press emits Events.shop_interact_requested
- [x] Events.gd has shop_interact_requested and shop_closed signals

## Next Phase Readiness

Plan 02 (Shop UI) can proceed — ShopCatalog data layer is ready, and Events.shop_interact_requested will trigger the shop panel opening.
