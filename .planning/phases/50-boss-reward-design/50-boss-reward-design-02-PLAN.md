---
phase: 50-boss-reward-design
plan: 02
type: execute
wave: 2
depends_on: [50-boss-reward-design-01]
files_modified: ["autoloads/game_manager.gd", "systems/shop/shop_catalog.gd"]
autonomous: true

must_haves:
  truths:
    - "GameManager tracks unlocked zones (zone_id -> bool)"
    - "GameManager checks boss defeats before allowing zone access"
    - "ShopCatalog checks boss defeats for equipment tier availability"
    - "Zone unlock prevents entering locked areas with clear message"
    - "Equipment tier shows lock icon until boss is defeated"
  artifacts:
    - path: "autoloads/game_manager.gd"
      provides: "Zone unlock tracking and enforcement"
      exports: ["unlock_zone", "is_zone_unlocked", "can_enter_zone"]
      contains: "unlocked_zones: Dictionary[String, bool]"
    - path: "systems/shop/shop_catalog.gd"
      provides: "Equipment tier gating based on boss defeats"
      contains: "check_equipment_tier_unlock() method"
  key_links:
    - from: "GameManager.can_enter_zone()"
      to: "BossRewardManager.is_boss_defeated()"
      via: "BossRewardManager autoload reference"
      pattern: "is_boss_defeated\\(BossID\\."
    - from: "ShopCatalog.get_equipment_tier()"
      to: "BossRewardManager.is_boss_defeated()"
      via: "BossRewardManager autoload reference"
      pattern: "is_boss_defeated\\(BossID\\."
---

<objective>
Implement zone unlock and equipment tier gating based on boss defeats.

Purpose: Connect boss progression to content access. Zones unlock after boss defeat; equipment tiers unlock to provide meaningful progression incentives.

Output: Zone enforcement in GameManager + equipment tier checks in ShopCatalog.
</objective>

<execution_context>
@~/.config/opencode/get-shit-done/workflows/execute-plan.md
@~/.config/opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@docs/PROJECT.md
@docs/ROADMAP.md
@.planning/phases/50-boss-reward-design/50-boss-reward-design-01-PLAN.md

# Existing zone system:
@autoloads/game_manager.gd

# Existing shop system:
@systems/shop/shop_catalog.gd
@.planning/phases/50-boss-reward-design/50-boss-reward-design-01-PLAN.md
</context>

<tasks>

<task type="auto">
  <name>Add zone unlock system to GameManager</name>
  <files>autoloads/game_manager.gd</files>
  <action>
    Add zone unlock tracking and enforcement to GameManager.

    **Zone Unlock Data:**

    1. Add unlocked_zones dictionary:
       ```gdscript
       ## Zone unlock tracking - zones unlocked via boss rewards
       var unlocked_zones: Dictionary = {
           "backyard_deep": false,
           "rooftops": false
       }
       ```

    2. Define zone constants:
       ```gdscript
       const ZONE_BACKYARD_DEEP: String = "backyard_deep"
       const ZONE_ROOFTOPS: String = "rooftops"
       ```

    **Zone Unlock Methods:**

    1. **unlock_zone(zone_id: String) -> void**
       - Set unlocked_zones[zone_id] = true
       - Save game to persist unlock
       - Emit zone_unlocked event (for UI notifications)

    2. **is_zone_unlocked(zone_id: String) -> bool**
       - Return unlocked_zones.get(zone_id, false)

    3. **can_enter_zone(zone_id: String) -> bool**
       - Check is_zone_unlocked(zone_id)
       - Return false if locked
       - If locked, show UI message: "This area is locked. Defeat [Boss Name] to access."
       - Return true if unlocked

    **Boss Integration:**

    In existing zone transition code (or wherever zone access happens):
    - Call can_enter_zone(target_zone) before transitioning
    - If false, prevent transition and show lock message
    - Use BossRewardManager.is_boss_defeated() to check unlock condition

    Example zone unlock conditions:
    - ZONE_BACKYARD_DEEP: requires BossID.ALPHA_RACCOON defeated
    - ZONE_ROOFTOPS: requires BossID.RAT_KING defeated

    Follow existing GameManager patterns (event emission for UI, save persistence).
  </action>
  <verify>
    Check file contains:
    - unlocked_zones dictionary with backyard_deep, rooftops
    - unlock_zone(), is_zone_unlocked(), can_enter_zone() methods
    - Zone constants defined
    - Integration with BossRewardManager (is_boss_defeated check)
  </verify>
  <done>
    Zone unlock system in GameManager with boss defeat integration. Zones enforce unlock requirements with player-facing messages.
  </done>
</task>

<task type="auto">
  <name>Add equipment tier unlocks to ShopCatalog</name>
  <files>systems/shop/shop_catalog.gd</files>
  <action>
    Add equipment tier gating based on boss defeats. Higher tiers are locked until specific bosses are defeated.

    **Equipment Tier System:**

    1. Define equipment tiers:
       ```gdscript
       ## Equipment Tiers - gated by boss defeats
       enum EquipmentTier {
           TIER_1 = 1,  # Starter gear (always available)
           TIER_2 = 2,  # Requires Alpha Raccoon defeat
           TIER_3 = 3,  # Requires Crow Matriarch defeat
           TIER_4 = 4   # Requires Rat King defeat
       }
       ```

    2. Define boss requirements per tier:
       ```gdscript
       const TIER_REQUIREMENTS: Dictionary = {
           EquipmentTier.TIER_2: [BossRewardManager.BossID.ALPHA_RACCOON],
           EquipmentTier.TIER_3: [BossRewardManager.BossID.CROW_MATRIARCH],
           EquipmentTier.TIER_4: [BossRewardManager.BossID.RAT_KING]
       }
       ```

    3. Add check method:
       ```gdscript
       func is_tier_unlocked(tier: EquipmentTier) -> bool:
           var requirements = TIER_REQUIREMENTS.get(tier, [])
           if requirements.is_empty():
               return true  # No requirements = always available
           for boss_id in requirements:
               if not BossRewardManager.is_boss_defeated(boss_id):
                   return false
           return true
       ```

    4. Update get_equipment_tier():
       - Filter equipment by tier using is_tier_unlocked()
       - Return only available tiers
       - Add "locked" flag to tier info for UI

    **UI Integration:**

    In shop display code:
    - Show lock icon (🔒) on locked tiers
    - Show boss requirement text: "Defeat Crow Matriarch to unlock"
    - Show tier name: "Tier 2 - Crow Armor" vs "Tier 2 (Locked)"

    Follow existing ShopCatalog patterns (data-driven pricing, equipment definitions).
  </action>
  <verify>
    Check file contains:
    - EquipmentTier enum (TIER_1 through TIER_4)
    - TIER_REQUIREMENTS const dictionary
    - is_tier_unlocked() method
    - get_equipment_tier() updated with tier filtering
  </verify>
  <done>
    Equipment tier gating in ShopCatalog. Higher tiers locked until boss defeats. Shop UI shows lock status and requirements.
  </done>
</task>

</tasks>

<verification>
After both tasks complete:
- [ ] GameManager has zone unlock system with boss integration
- [ ] ShopCatalog has equipment tier gating
- [ ] can_enter_zone() checks BossRewardManager
- [ ] is_tier_unlocked() checks BossRewardManager
- [ ] No syntax errors in both files
</verification>

<success_criteria>
1. Zone unlock system prevents access to locked zones with clear message
2. Zone unlocks persist across save/load
3. Equipment tiers are locked until required boss is defeated
4. Shop UI shows lock status and boss requirements
5. Boss defeats properly gate access to new content
</success_criteria>

<output>
After completion, create `.planning/phases/50-boss-reward-design/50-boss-reward-design-02-SUMMARY.md`
</output>
