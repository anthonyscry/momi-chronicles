---
phase: 50-boss-reward-design
plan: 01
type: execute
wave: 1
depends_on: []
files_modified: ["autoloads/boss_reward_manager.gd", "autoloads/save_manager.gd"]
autonomous: true

must_haves:
  truths:
    - "BossRewardManager tracks defeated bosses with unique IDs"
    - "SaveManager v4 includes boss defeat data with backward compatibility"
    - "BossRewardManager emits events when boss is defeated"
    - "BossRewardManager can be queried for boss defeat status"
    - "Boss rewards are defined per boss (zone/equipment/ability unlocks)"
  artifacts:
    - path: "autoloads/boss_reward_manager.gd"
      provides: "Boss defeat tracking and reward definition"
      exports: ["is_boss_defeated", "mark_boss_defeated", "get_boss_reward", "get_all_defeated_bosses"]
    - path: "autoloads/save_manager.gd"
      provides: "Save data with boss defeat tracking (v4)"
      contains: "boss_defeats: Dictionary[String, Dictionary]"
  key_links:
    - from: "characters/enemies/boss_raccoon_king.gd"
      to: "BossRewardManager"
      via: "Events.boss_defeated signal"
      pattern: "boss_defeated\\.emit"
    - from: "BossRewardManager"
      to: "SaveManager"
      via: "SaveManager.save_game() call on boss defeat"
      pattern: "save_game"
---

<objective>
Create BossRewardManager autoload to track boss defeats and define rewards.

Purpose: Establish data layer for boss progression system. Boss defeats need to persist across save/load and provide unlock conditions for zones, equipment tiers, and abilities.

Output: BossRewardManager autoload + SaveManager v4 with boss defeat data.
</objective>

<execution_context>
@~/.config/opencode/get-shit-done/workflows/execute-plan.md
@~/.config/opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@docs/PROJECT.md
@docs/ROADMAP.md
@docs/STATE.md

# Boss defeat flow in current codebase:
# Events autoload has boss_defeated signal (used in mini_boss_base.gd)
@characters/enemies/mini_boss_base.gd
@autoloads/save_manager.gd

# Existing save data structure (v3):
@autoloads/save_manager.gd
</context>

<tasks>

<task type="auto">
  <name>Create BossRewardManager autoload</name>
  <files>autoloads/boss_reward_manager.gd</files>
  <action>
    Create BossRewardManager autoload with the following design:

    **Boss Reward Definitions (enum + consts):**
    ```gdscript
    extends Node

    ## Boss IDs - unique identifiers for each boss
    enum BossID {
        ALPHA_RACCOON = 0,
        CROW_MATRIARCH = 1,
        RAT_KING = 2,
        PIGEON_KING = 3
    }

    ## Boss Names - display names for UI
    const BOSS_NAMES: Dictionary = {
        BossID.ALPHA_RACCOON: "Alpha Raccoon",
        BossID.CROW_MATRIARCH: "Crow Matriarch",
        BossID.RAT_KING: "Rat King",
        BossID.PIGEON_KING: "Pigeon King"
    }

    ## Boss Reward Types - what each boss unlocks
    enum RewardType {
        ZONE_UNLOCK,
        EQUIPMENT_TIER,
        ABILITY_UNLOCK,
        COMPANION_SLOT
    }

    ## Boss Rewards - data structure for each boss's reward
    ## Fields: type (RewardType), description (String), value (Variant)
    const BOSS_REWARDS: Dictionary = {
        BossID.ALPHA_RACCOON: {
            "type": RewardType.ZONE_UNLOCK,
            "description": "Unlocks Backyard Deep zone",
            "value": "backyard_deep"
        },
        BossID.CROW_MATRIARCH: {
            "type": RewardType.EQUIPMENT_TIER,
            "description": "Unlocks Tier 3 Crow Armor",
            "value": 3
        },
        BossID.RAT_KING: {
            "type": RewardType.ZONE_UNLOCK,
            "description": "Unlocks Rooftops access",
            "value": "rooftops"
        },
        BossID.RAT_KING: {  # Rat King gives TWO rewards
            "type": RewardType.ABILITY_UNLOCK,
            "description": "Grants Poison Resistance",
            "value": "poison_resist"
        },
        BossID.PIGEON_KING: {
            "type": RewardType.COMPANION_SLOT,
            "description": "Unlocks 4th Companion Slot",
            "value": 4
        }
    }

    ## Boss Defeat Tracking
    var _defeated_bosses: Dictionary = {}
    ```

    **Key Methods:**

    1. **mark_boss_defeated(boss_id: BossID) -> void**
       - Add boss_id to _defeated_bosses dictionary with timestamp
       - Emit Events.boss_reward_unlocked signal with reward data
       - Call SaveManager.save_game() to persist defeat

    2. **is_boss_defeated(boss_id: BossID) -> bool**
       - Return true if boss_id in _defeated_bosses, false otherwise

    3. **get_boss_reward(boss_id: BossID) -> Dictionary**
       - Return BOSS_REWARDS[boss_id] or null if invalid ID

    4. **get_all_defeated_bosses() -> Array[BossID]**
       - Return array of all defeated boss IDs

    5. **get_reward_description(boss_id: BossID) -> String**
       - Return human-readable reward description for UI

    **Events to Emit:**
    - boss_defeated(boss_id: BossID) - Boss was defeated
    - boss_reward_unlocked(boss_id: BossID, reward: Dictionary) - Reward available

    **Save Integration:**
    - Read boss_defeats from save data on _ready()
    - Write boss_defeats to save data when boss is defeated

    Follow existing autoload patterns (Events for cross-system communication, preload for resources).
  </action>
  <verify>
    Check file exists and contains:
    - BossID enum with 4 bosses
    - BOSS_REWARDS const Dictionary
    - mark_boss_defeated(), is_boss_defeated(), get_boss_reward() methods
  </verify>
  <done>
    BossRewardManager.gd exists with boss defeat tracking and reward definitions. Ready for autoload registration in project.godot.
  </done>
</task>

<task type="auto">
  <name>Add boss defeat data to SaveManager v4</name>
  <files>autoloads/save_manager.gd</files>
  <action>
    Update SaveManager to include boss defeat data. Maintain backward compatibility with v3 saves.

    **Changes to save data structure:**

    1. Add `boss_defeats` field to saved data:
       ```gdscript
       ## v4 save data - boss defeat tracking (backward compatible with v3)
       var _save_data: Dictionary = {
           # ... existing fields ...
           "boss_defeats": {}  # Dictionary[String, Dictionary] - boss_id -> {timestamp, reward_claimed}
       }
       ```

    2. Add SAVE_VERSION constant:
       ```gdscript
       const SAVE_VERSION: int = 4
       ```

    3. In load_game(), migrate v3 saves to v4:
       - If version < 4, initialize empty boss_defeats dictionary
       - No data loss - players keep existing saves

    4. In load_game(), populate BossRewardManager._defeated_bosses:
       - After loading save data, call BossRewardManager.load_defeats(saved_data.boss_defeats)

    5. In save_game(), serialize boss defeats:
       - Include BossRewardManager.get_all_defeated_bosses() in save data
       - Format: {"boss_defeats": {"0": {"timestamp": 1234567, "reward_claimed": true}}}

    **Backward Compatibility:**
    - Use `.get("boss_defeats", {})` default for v3 saves
    - Don't fail load if boss_defeats missing

    Follow existing save patterns (atomic write, backup file, version checking).
  </action>
  <verify>
    Check file contains:
    - SAVE_VERSION = 4 constant
    - boss_defeats field in save data dictionary
    - Migration logic for version < 4
    - BossRewardManager integration in load_game()
  </verify>
  <done>
    SaveManager v4 with boss defeat tracking. Backward compatible with existing v3 saves. Ready for BossRewardManager autoload.
  </done>
</task>

</tasks>

<verification>
After both tasks complete:
- [ ] BossRewardManager.gd exists in autoloads/
- [ ] SaveManager has SAVE_VERSION = 4 and boss_defeats field
- [ ] Save data migration handles v3 → v4 without breaking
- [ ] No syntax errors in both files (godot --check will validate)
</verification>

<success_criteria>
1. BossRewardManager autoload exists and is ready for registration in project.godot
2. SaveManager v4 includes boss defeat data with backward compatibility
3. Boss defeats can be tracked and queried programmatically
4. Boss rewards are defined for all 4 mini-bosses
5. Save system can persist and restore boss defeat state
</success_criteria>

<output>
After completion, create `.planning/phases/50-boss-reward-design/50-boss-reward-design-01-SUMMARY.md`
</output>
