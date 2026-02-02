# Phase 18 Plan 02: Shop UI Summary

**One-liner:** Full shop UI panel with buy tab, keyboard navigation, item/equipment browsing, coin transactions, and purchase feedback animations

## Metadata

- **Phase:** 18-shop-system
- **Plan:** 02
- **Subsystem:** shop-ui
- **Tags:** shop, ui, buy, keyboard-nav, inventory, equipment, coins, autoload
- **Completed:** 2026-01-29
- **Duration:** ~3 minutes

### Dependency Graph

- **Requires:** Phase 18-01 (ShopCatalog autoload, shop signals, Nutkin NPC)
- **Provides:** ShopUI autoload with full buy functionality, keyboard navigation, purchase transactions
- **Affects:** Phase 18-03 (sell tab implementation fills the SELL placeholder)

### Tech Tracking

- **tech-stack.added:** none (pure GDScript)
- **tech-stack.patterns:** Programmatic UI construction (all nodes created in _ready), CanvasLayer autoload for modal overlay, tween-based feedback animations

### File Tracking

- **key-files.created:**
  - `ui/shop/shop_ui.gd` — Full shop UI with buy functionality, keyboard navigation, purchase transactions
  - `ui/shop/shop_ui.tscn` — Minimal scene file (CanvasLayer root with script attached)
- **key-files.modified:**
  - `project.godot` — Registered ShopUI autoload after ShopCatalog
  - `world/zones/neighborhood.gd` — Removed temporary debug print from Plan 01

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Create shop UI scene and script with buy functionality | d0a652c | shop_ui.gd, shop_ui.tscn, project.godot, neighborhood.gd |

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| Fully programmatic UI (no .tscn child nodes) | Matches ring_menu pattern — all nodes created in _ready() for full code control |
| CanvasLayer autoload at layer 100 | Above HUD, below fade overlay (128), consistent with project layering |
| process_mode ALWAYS | Must respond to input while game is paused (shop pauses game) |
| 7 visible rows with scroll offset | Fits 384x216 viewport, accommodates 10 items and 15 equipment |
| Q key for category toggle (cycle_companion action) | Reuses existing input mapping, natural for sub-tab cycling |
| Z/attack for buy action | Consistent with ring menu's accept pattern (Z/Space/attack) |
| Coin shake animation on insufficient funds | Draws attention to the problem — coins shake horizontally |
| Green/red flash overlay for feedback | Quick visual confirmation without disrupting browsing flow |
| SELL tab shows placeholder | Plan 03 implements sell functionality — clean separation |
| Stat names mapped by int index | EquipmentDatabase.StatType enum values: 0=MAX_HEALTH through 5=EXP_BONUS |

## Deviations from Plan

None — plan executed exactly as written.

## Verification Criteria

- [x] Shop UI opens when pressing E near Nutkin (via Events.shop_interact_requested)
- [x] Items tab shows all 10 items with prices from ShopCatalog
- [x] Equipment tab shows all 15 equipment pieces with prices
- [x] Up/Down navigates item list with scroll support
- [x] Left/Right switches Buy/Sell tabs
- [x] Q toggles Items/Equipment category
- [x] Z key purchases selected item (coins deducted, item/equipment added)
- [x] Can't buy if insufficient coins (red feedback, coin shake)
- [x] Can't buy equipment already owned (gray feedback)
- [x] Coin display shows current balance (updates on coins_changed signal)
- [x] ESC or E closes shop and resumes game
- [x] Sound effects play on navigation, purchase, and close
- [x] Sell tab shows "Coming soon" placeholder

## Next Phase Readiness

Plan 03 (Sell Tab) can proceed — ShopUI framework is ready with tab switching infrastructure. The SELL tab case in _refresh_list() and _update_detail() are prepared for sell item population.
