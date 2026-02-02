---
phase: 18-shop-system
verified: 2026-01-28T17:30:00Z
status: passed
score: 12/12 must-haves verified
must_haves:
  truths:
    - "Nutkin the Squirrel NPC is visible in the neighborhood zone"
    - "Player can walk up to Nutkin and see an interaction prompt"
    - "Pressing E near Nutkin emits a signal to open the shop"
    - "A shop catalog defines prices for all items and equipment"
    - "Pressing E near Nutkin opens the shop UI panel"
    - "Player can see items and equipment listed with names, descriptions, and prices"
    - "Player can browse items using keyboard navigation"
    - "Player can buy an item when they have enough coins"
    - "Player cannot buy an item when they lack coins (visual feedback)"
    - "Player can close the shop with ESC or E"
    - "Current coin balance is displayed in the shop UI"
    - "Player can sell items from inventory for 50% of buy price"
  artifacts:
    - path: "systems/shop/shop_catalog.gd"
      provides: "Price catalog, stock tracking, restock mechanic"
    - path: "characters/npcs/shop_npc.gd"
      provides: "Nutkin NPC with interaction prompt and E-key signal"
    - path: "characters/npcs/shop_npc.tscn"
      provides: "Scene file for ShopNPC"
    - path: "ui/shop/shop_ui.gd"
      provides: "Full shop UI panel with buy/sell/browse/keyboard nav"
    - path: "ui/shop/shop_ui.tscn"
      provides: "Scene file for ShopUI"
    - path: "world/zones/neighborhood.tscn"
      provides: "Nutkin placed in neighborhood zone"
  key_links:
    - from: "shop_npc.gd"
      to: "Events.shop_interact_requested"
      via: "emit on E press"
    - from: "shop_ui.gd"
      to: "Events.shop_interact_requested"
      via: "connect in _ready"
    - from: "shop_ui.gd"
      to: "GameManager.spend_coins"
      via: "_buy_selected"
    - from: "shop_ui.gd"
      to: "GameManager.add_coins"
      via: "_sell_selected"
    - from: "shop_ui.gd"
      to: "GameManager.inventory.add_item"
      via: "_buy_selected"
    - from: "shop_ui.gd"
      to: "GameManager.inventory.remove_item"
      via: "_sell_selected"
    - from: "shop_ui.gd"
      to: "GameManager.equipment_manager.add_equipment"
      via: "_buy_selected"
    - from: "shop_ui.gd"
      to: "GameManager.equipment_manager.remove_equipment"
      via: "_sell_selected"
    - from: "shop_ui.gd"
      to: "ShopCatalog.get_all_shop_items"
      via: "_refresh_list"
    - from: "shop_catalog.gd"
      to: "Events.zone_entered"
      via: "connect in _ready -> restock on neighborhood"
gaps: []
---

# Phase 18: Shop System — Verification Report

**Phase Goal:** Spend coins on items and equipment from a friendly shopkeeper
**Verified:** 2026-01-28T17:30:00Z
**Status:** ✅ PASSED
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Nutkin the Squirrel NPC is visible in the neighborhood zone | ✓ VERIFIED | `neighborhood.tscn` line 1385: `[node name="Nutkin" parent="." instance=ExtResource("12_shop_npc")]` at position (400, 350). `shop_npc.gd` builds a full squirrel visual with body, tail, eyes, nose, ears (Polygon2D shapes, 223 lines) |
| 2 | Player can walk up to Nutkin and see an interaction prompt | ✓ VERIFIED | `shop_npc.gd` line 195: creates `[E] Shop` prompt label, hidden by default. Line 211-216: `_on_body_entered` detects Player, sets `player_in_range = true` and shows prompt. Area2D collision_mask = 2 (player layer) |
| 3 | Pressing E near Nutkin emits a signal to open the shop | ✓ VERIFIED | `shop_npc.gd` line 68-71: `_unhandled_input` checks `player_in_range and event.is_action_pressed("interact")` then calls `Events.shop_interact_requested.emit()` |
| 4 | A shop catalog defines prices for all items and equipment | ✓ VERIFIED | `shop_catalog.gd` lines 11-21: `SHOP_ITEMS` dict with 10 items (acorn=5 through revival_bone=100). Lines 25-41: `SHOP_EQUIPMENT` dict with 15 equipment pieces (basic_collar=30 through guard_helmet=140) |
| 5 | Pressing E near Nutkin opens the shop UI panel | ✓ VERIFIED | `shop_ui.gd` line 76: `Events.shop_interact_requested.connect(open_shop)`. Line 329-361: `open_shop()` sets `is_open=true`, `visible=true`, pauses game, resets state, refreshes list, animates open with scale tween |
| 6 | Player can see items and equipment listed with names, descriptions, and prices | ✓ VERIFIED | `shop_ui.gd` lines 489-494: `_refresh_list` calls `ShopCatalog.get_all_shop_items()` or `get_all_shop_equipment()`. Lines 510-568: `_update_rows` populates row controls with name, price (with "g" suffix), stock/quantity. Lines 571-657: `_update_detail` shows name, description, price, and stats |
| 7 | Player can browse items using keyboard navigation | ✓ VERIFIED | `shop_ui.gd` lines 390-439: `_unhandled_input` handles W/S (ui_up/ui_down) for selection, A/D (ui_left/ui_right) for tab switching (BUY/SELL), Q (cycle_companion) for category toggle (Items/Equipment). Scrolling logic at lines 446-460 |
| 8 | Player can buy an item when they have enough coins | ✓ VERIFIED | `shop_ui.gd` lines 674-717: `_buy_selected()` calls `GameManager.spend_coins(price)` (line 692), on success adds via `GameManager.inventory.add_item(item_id)` (line 705) or `GameManager.equipment_manager.add_equipment(item_id)` (line 702), reduces stock via `ShopCatalog.reduce_stock(item_id)` (line 708), flashes green, plays sfx, refreshes list |
| 9 | Player cannot buy an item when they lack coins (visual feedback) | ✓ VERIFIED | `shop_ui.gd` lines 692-697: if `GameManager.spend_coins(price)` returns false → `_flash_feedback(COLOR_FAIL_FLASH)` (red flash), `_shake_coin_label()` (shake animation lines 874-883). Detail pane shows "Not enough coins" in red (line 652-653) |
| 10 | Player can close the shop with ESC or E | ✓ VERIFIED | `shop_ui.gd` line 398: `event.is_action_pressed("pause") or event.is_action_pressed("interact")` → calls `close_shop()`. Lines 364-383: `close_shop()` animates out, resumes game, emits `Events.shop_closed` |
| 11 | Current coin balance is displayed in the shop UI | ✓ VERIFIED | `shop_ui.gd` lines 248-255: `coin_label` created in gold color. Line 825-827: `_update_coin_display()` sets `"Coins: %d" % GameManager.coins`. Line 77: connects `Events.coins_changed` for live updates |
| 12 | Player can sell items from inventory for 50% of buy price | ✓ VERIFIED | `shop_catalog.gd` line 44: `SELL_MULTIPLIER = 0.5`. Lines 146-150: `get_sell_price` returns `floor(buy_price * 0.5)`. `shop_ui.gd` lines 724-762: `_sell_selected()` removes item/equipment, calls `GameManager.add_coins(sell_price)`, spawns "+coins" float text. Lines 766-795: `_get_sell_items()` and `_get_sell_equipment()` build sell lists with sell_price attached |

**Score:** 12/12 truths verified

### Required Artifacts

| Artifact | Expected | Exists | Lines | Substantive | Wired | Status |
|----------|----------|--------|-------|-------------|-------|--------|
| `systems/shop/shop_catalog.gd` | Price catalog, stock, restock | ✓ | 203 | ✓ No stubs, real logic | ✓ Autoload in project.godot, used by shop_ui.gd | ✓ VERIFIED |
| `characters/npcs/shop_npc.gd` | Shop NPC with E-key interaction | ✓ | 223 | ✓ Full visual + interaction | ✓ Used by shop_npc.tscn, placed in neighborhood.tscn | ✓ VERIFIED |
| `characters/npcs/shop_npc.tscn` | Scene for shop NPC | ✓ | 10 | ✓ Area2D with script | ✓ Instanced in neighborhood.tscn line 1385 | ✓ VERIFIED |
| `ui/shop/shop_ui.gd` | Full shop UI panel | ✓ | 884 | ✓ Complete buy/sell/browse/nav/animation | ✓ Autoload in project.godot, connects Events signals | ✓ VERIFIED |
| `ui/shop/shop_ui.tscn` | Scene for shop UI | ✓ | 9 | ✓ CanvasLayer with script | ✓ Registered as autoload ShopUI in project.godot | ✓ VERIFIED |
| `world/zones/neighborhood.tscn` | Nutkin placed in zone | ✓ | 1399 | ✓ Full zone scene | ✓ Nutkin node at line 1385, position (400, 350) | ✓ VERIFIED |
| `autoloads/events.gd` | Shop signals defined | ✓ | 228 | ✓ signals declared | ✓ Connected by shop_npc.gd and shop_ui.gd | ✓ VERIFIED |

### Key Link Verification

| From | To | Via | Status | Evidence |
|------|----|-----|--------|----------|
| `shop_npc.gd` | `Events.shop_interact_requested` | `.emit()` | ✓ WIRED | Line 70: `Events.shop_interact_requested.emit()` inside `_unhandled_input` with `player_in_range` guard |
| `shop_npc.gd` | `is_action_pressed("interact")` | Input check | ✓ WIRED | Line 69: `event.is_action_pressed("interact")` |
| `shop_ui.gd` | `Events.shop_interact_requested` | `.connect()` | ✓ WIRED | Line 76: `Events.shop_interact_requested.connect(open_shop)` |
| `shop_ui.gd` | `GameManager.spend_coins` | Buy flow | ✓ WIRED | Line 692: `GameManager.spend_coins(price)` — returns bool, used for flow control |
| `shop_ui.gd` | `GameManager.add_coins` | Sell flow | ✓ WIRED | Line 743: `GameManager.add_coins(sell_price)` |
| `shop_ui.gd` | `GameManager.inventory.add_item` | Buy item | ✓ WIRED | Line 705: `GameManager.inventory.add_item(item_id)` |
| `shop_ui.gd` | `GameManager.inventory.remove_item` | Sell item | ✓ WIRED | Line 740: `GameManager.inventory.remove_item(item_id, 1)` |
| `shop_ui.gd` | `GameManager.equipment_manager.add_equipment` | Buy equip | ✓ WIRED | Line 702: `GameManager.equipment_manager.add_equipment(item_id)` |
| `shop_ui.gd` | `GameManager.equipment_manager.remove_equipment` | Sell equip | ✓ WIRED | Line 737: `GameManager.equipment_manager.remove_equipment(item_id)` |
| `shop_ui.gd` | `ShopCatalog.get_all_shop_items/equipment` | List data | ✓ WIRED | Lines 492-494: `ShopCatalog.get_all_shop_items()` / `get_all_shop_equipment()` |
| `shop_catalog.gd` | `Events.zone_entered` | Restock hook | ✓ WIRED | Line 92: `Events.zone_entered.connect(_on_zone_entered)` → restocks when `zone_name == "neighborhood"` (line 96-97) |
| Autoload registration | `project.godot` | Autoload entries | ✓ WIRED | `ShopCatalog="*res://systems/shop/shop_catalog.gd"` and `ShopUI="*res://ui/shop/shop_ui.tscn"` |

### Deliverable Coverage

| Deliverable | Status | Evidence |
|-------------|--------|----------|
| Shop NPC (Nutkin the Squirrel, placed in Neighborhood zone) | ✓ SATISFIED | `shop_npc.gd` (223 lines) — full squirrel visual with body, belly, tail, eyes, nose, ears. Name "Nutkin" label. Placed in `neighborhood.tscn` at (400, 350) |
| Shop UI panel (browse, buy, sell interface with keyboard navigation) | ✓ SATISFIED | `shop_ui.gd` (884 lines) — BUY/SELL tabs, Items/Equipment categories, W/S navigation, Z to buy/sell, ESC/E to close, detail pane with description+stats+price |
| Price catalog for all existing items and equipment | ✓ SATISFIED | `shop_catalog.gd` — 10 items priced (acorn:5 to full_heal:200), 15 equipment priced (basic_collar:30 to guard_helmet:140) |
| Sell-back system (50% of buy price) | ✓ SATISFIED | `SELL_MULTIPLIER = 0.5`, `get_sell_price()` returns `floor(buy_price * 0.5)`. Sell UI tab with `_sell_selected()` implementation |
| Restock mechanic (shop refreshes on zone re-entry) | ✓ SATISFIED | `Events.zone_entered.connect(_on_zone_entered)` → `if zone_name == "neighborhood": restock()`. `restock()` restores all stock levels from defaults |
| Stock tracking (limited quantities per restock cycle) | ✓ SATISFIED | `DEFAULT_ITEM_STOCK` (e.g. acorn:10, full_heal:1), `DEFAULT_EQUIPMENT_STOCK` (all 1 each). `shop_stock` dict tracks runtime. `reduce_stock()` decrements on purchase. Items with 0 stock hidden from list |
| Integration with existing coin/inventory systems | ✓ SATISFIED | Uses `GameManager.spend_coins`, `add_coins`, `inventory.add_item`, `inventory.remove_item`, `equipment_manager.add_equipment`, `equipment_manager.remove_equipment`. All functions verified to exist in their respective files |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| — | — | — | — | No anti-patterns found |

Zero TODO/FIXME/placeholder/stub patterns across all 5 phase source files. No empty returns, no console.log-only handlers. All implementations are substantive.

### Human Verification Required

### 1. Visual appearance of Nutkin
**Test:** Walk to position (400, 350) in the neighborhood zone and observe the NPC
**Expected:** A recognizable orange-brown squirrel figure with a gold "Nutkin" name label and "[E] Shop" prompt appearing when nearby
**Why human:** Visual appearance verification — polygon shapes may look odd at runtime

### 2. Full buy transaction flow
**Test:** Open shop near Nutkin, select an item, press Z to buy
**Expected:** Item added to inventory, coins deducted, green flash feedback, health_pickup sfx, stock count decremented, item disappears when stock hits 0
**Why human:** Full flow depends on runtime state and animation timing

### 3. Full sell transaction flow
**Test:** Switch to SELL tab (A/D), select an item from inventory, press Z to sell
**Expected:** Item removed from inventory, coins added at 50% buy price, gold flash, floating "+N" text animates up, sell list refreshes
**Why human:** Floating text animation and inventory update require runtime verification

### 4. Keyboard navigation feel
**Test:** Use W/S to scroll through items, A/D to switch BUY/SELL, Q to toggle Items/Equipment
**Expected:** Smooth navigation with audio feedback, detail pane updates on each selection, scroll works when list exceeds 7 visible rows
**Why human:** Interaction feel and scroll behavior need runtime testing

### 5. Restock on zone re-entry
**Test:** Buy several items, leave neighborhood zone, re-enter
**Expected:** Shop stock fully replenished (equipment already owned remains at 0 stock)
**Why human:** Zone transition + signal flow requires runtime verification

---

_Verified: 2026-01-28T17:30:00Z_
_Verifier: Claude (gsd-verifier)_
