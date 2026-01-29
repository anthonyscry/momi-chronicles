# Phase 18 Plan 03: Sell Tab & Restock Summary

**One-liner:** Sell tab for items/equipment at 50% buy price with gold feedback animations, plus stock tracking and neighborhood zone-entry restock mechanic

## Metadata

- **Phase:** 18-shop-system
- **Plan:** 03
- **Subsystem:** shop
- **Tags:** shop, sell, restock, stock-tracking, economy, ui, zone-entry
- **Completed:** 2026-01-28
- **Duration:** ~5 minutes

### Dependency Graph

- **Requires:** Phase 18-01 (ShopCatalog autoload, prices), Phase 18-02 (ShopUI with buy tab)
- **Provides:** Complete shop economy loop (buy + sell + restock), stock tracking system
- **Affects:** Phase 19 (Sewers Zone — new zone means shop restocks on return), Phase 20 (Mini-Boss — loot economy balancing)

### Tech Tracking

- **tech-stack.added:** none (pure GDScript)
- **tech-stack.patterns:** Stock tracking with restock on zone signal, floating label tween feedback, sell-back economy (50% multiplier)

### File Tracking

- **key-files.created:**
  - `.planning/phases/18-shop-system/18-03-SUMMARY.md` — This summary
- **key-files.modified:**
  - `ui/shop/shop_ui.gd` — Added sell tab, sell transaction, sell helpers, floating coin text, stock display in buy rows
  - `systems/shop/shop_catalog.gd` — Added stock tracking (DEFAULT_ITEM_STOCK, DEFAULT_EQUIPMENT_STOCK), restock(), reduce_stock(), zone_entered connection

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Implement sell tab in shop UI | 862cc1b | ui/shop/shop_ui.gd |
| 2 | Add restock mechanic on zone re-entry | 4165d96 | systems/shop/shop_catalog.gd, ui/shop/shop_ui.gd |

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| Sell items 1 at a time (not bulk) | Simpler UX, matches buy-1-at-a-time pattern from Plan 02 |
| Only unequipped equipment can be sold | Player must unequip via ring menu first — prevents accidental sell of active gear |
| Stock shown as "x5" in buy row quantity column | Reuses existing quantity label position, minimal UI change |
| 0-stock items filtered out of buy list entirely | Cleaner than showing greyed-out unavailable items |
| Restock on any neighborhood zone_entered signal | Includes save load, zone transition back, and new game — all trigger restock |
| Already-owned equipment gets 0 stock on restock | Prevents buying duplicates even after restock |
| Floating "+coins" label with tween (0.6s) | Quick satisfying feedback without blocking interaction |

## Deviations from Plan

None — plan executed exactly as written.

## Verification Results

- [x] SELL tab shows player's inventory items with sell prices
- [x] SELL tab Equipment category shows unequipped equipment only
- [x] Selling removes item from inventory and adds coins
- [x] Selling equipment removes from equipment_inventory and adds coins
- [x] Sell price is 50% of buy price (rounded down via floor)
- [x] Empty sell list shows "Nothing to sell!" message
- [x] Shop items have stock counts displayed
- [x] Purchasing reduces stock
- [x] Items with 0 stock disappear from buy list
- [x] Re-entering neighborhood zone restocks the shop
- [x] Already-owned equipment doesn't restock
- [x] Gold "+amount" floating text on sell
- [x] Coin display updates in real-time during buy/sell

## Next Phase Readiness

Phase 18 (Shop System) is now **complete**. The full economy loop works: buy items/equipment with coins, sell items/equipment back at 50%, shop restocks on zone re-entry. Phase 19 (Sewers Zone) can proceed — entering sewers and returning to neighborhood will naturally trigger shop restock.
