---
phase: 50-boss-reward-design
plan: 03
type: execute
wave: 3
depends_on: [50-boss-reward-design-01, 50-boss-reward-design-02]
files_modified: ["ui/boss/boss_reward_popup.tscn", "ui/ring_menu/ring_menu.tscn", "autoloads/events.gd"]
autonomous: false

must_haves:
  truths:
    - "Boss defeat shows reward popup with clear description"
    - "Reward popup includes visual icon and claim button"
    - "Boss progress tracker accessible from ring menu"
    - "Boss progress tracker shows defeated bosses and pending unlocks"
    - "Events.boss_reward_unlocked emitted when reward available"
    - "Events.boss_reward_claimed emitted when player claims reward"
  artifacts:
    - path: "ui/boss/boss_reward_popup.tscn"
      provides: "Boss reward notification UI"
      exports: ["show_reward"]
      contains: "AnimatedSprite2D, Label, Button (Claim)"
    - path: "ui/ring_menu/ring_menu.tscn"
      provides: "Boss progress tracker menu item"
      contains: "boss_tracker: Node path in ring menu structure"
    - path: "autoloads/events.gd"
      provides: "Boss reward signals"
      exports: ["boss_reward_unlocked", "boss_reward_claimed"]
  key_links:
    - from: "boss_reward_popup.tscn"
      to: "Events"
      via: "Events.boss_reward_claimed.emit()"
      pattern: "boss_reward_claimed\\.emit"
    - from: "ring_menu.tscn"
      to: "BossRewardManager"
      via: "BossRewardManager.get_all_defeated_bosses()"
      pattern: "get_all_defeated_bosses\\(\\)"
---

<objective>
Create boss reward notification popup and progress tracker UI.

Purpose: Provide clear visual feedback when bosses are defeated and rewards are unlocked. Boss progress tracker lets players see their accomplishments.

Output: Boss reward popup + ring menu boss tracker integration.
</objective>

<execution_context>
@~/.config/opencode/get-shit-done/workflows/execute-plan.md
@~/.config/opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@docs/PROJECT.md
@docs/ROADMAP.md
@.planning/phases/50-boss-reward-design/50-boss-reward-design-01-PLAN.md
@.planning/phases/50-boss-reward-design/50-boss-reward-design-02-PLAN.md

# Existing UI patterns:
@ui/ring_menu/ring_menu.tscn
@ui/hud/

# Existing Events autoload:
@autoloads/events.gd
</context>

<tasks>

<task type="auto">
  <name>Create boss reward popup UI</name>
  <files>ui/boss/boss_reward_popup.tscn</files>
  <action>
    Create boss_reward_popup.tscn scene with following structure:

    **Scene Hierarchy:**
    ```
    Control (root)
    ├── PanelContainer (Background with blur effect)
    │   ├── VBoxContainer
    │   │   ├── AnimatedSprite2D (Reward icon - boss sprite)
    │   │   ├── Label (Boss name - e.g., "CROW MATRIARCH DEFEATED!")
    │   │   ├── Label (Reward description - from BossRewardManager)
    │   │   ├── Label (Unlock info - "Backyard Deep Zone Unlocked!")
    │   │   └── Button (Claim Reward)
    ```

    **Script: boss_reward_popup.gd**
    ```gdscript
    extends Control

    const BossRewardManager = preload("res://autoloads/boss_reward_manager.gd")
    const Events = preload("res://autoloads/events.gd")
    const AudioManager = preload("res://autoloads/audio_manager.gd")

    var _current_boss_id: BossRewardManager.BossID = -1
    var _reward_data: Dictionary = {}

    func _ready() -> void:
        Events.boss_reward_unlocked.connect(_on_reward_unlocked)
        hide()

    func _on_reward_unlocked(boss_id: BossRewardManager.BossID) -> void:
        _current_boss_id = boss_id
        _reward_data = BossRewardManager.get_boss_reward(boss_id)

        # Update UI elements
        $RewardIcon.texture = _get_boss_icon(boss_id)
        $BossNameLabel.text = "%s DEFEATED!" % BossRewardManager.BOSS_NAMES[boss_id]
        $RewardDescriptionLabel.text = _reward_data.description
        $UnlockInfoLabel.text = _format_unlock_info(_reward_data)

        # Show popup with animation
        show()
        AudioManager.play_sfx("boss_defeat")
        Events.game_paused.emit() # Pause game during reward screen

        # Enable claim button
        $ClaimButton.disabled = false

    func _on_claim_button_pressed() -> void:
        if _current_boss_id < 0:
            return

        # Claim reward (mark as received in save)
        BossRewardManager.mark_reward_claimed(_current_boss_id)

        # Emit event for game systems (e.g., UI updates)
        Events.boss_reward_claimed.emit(_current_boss_id, _reward_data)

        # Hide popup and resume game
        hide()
        Events.game_resumed.emit()

    func _get_boss_icon(boss_id: BossRewardManager.BossID) -> Texture:
        # Return boss portrait or sprite texture
        # For now, use existing sprite
        return load("res://art/generated/enemies/crow_matriarch.png")

    func _format_unlock_info(reward_data: Dictionary) -> String:
        match reward_data.type:
            BossRewardManager.RewardType.ZONE_UNLOCK:
                return "Zone Unlocked: %s" % reward_data.value
            BossRewardManager.RewardType.EQUIPMENT_TIER:
                return "Equipment Tier %d Unlocked!" % reward_data.value
            BossRewardManager.RewardType.ABILITY_UNLOCK:
                return "Ability Unlocked: %s" % reward_data.value
            BossRewardManager.RewardType.COMPANION_SLOT:
                return "Companion Slot Unlocked!"
            _:
                return "Reward Unlocked!"
    ```

    **UI Styling:**
    - Panel with semi-transparent black background
    - Gold border for victory feel
    - Boss icon large and centered
    - Claim button prominent (green/tinted)
    - All text white with drop shadow

    Follow existing UI patterns (Control root, VBox layout, theme-based styling).
  </action>
  <verify>
    Check file exists and contains:
    - Control root with PanelContainer
    - RewardIcon (AnimatedSprite2D), BossNameLabel, RewardDescriptionLabel
    - UnlockInfoLabel, ClaimButton
    - boss_reward_popup.gd script
    - _on_reward_unlocked(), _on_claim_button_pressed() methods
  </verify>
  <done>
    Boss reward popup UI created. Shows reward details when boss is defeated. Integrates with BossRewardManager and Events.
  </done>
</task>

<task type="auto">
  <name>Add boss tracker to ring menu</name>
  <files>ui/ring_menu/ring_menu.tscn</files>
  <action>
    Add boss tracker menu item to ring menu. Shows list of defeated bosses and pending unlocks.

    **Ring Menu Structure:**
    - Existing ring menu has items: Items, Equipment, Companions, Save, Settings
    - Add "Bosses" menu item as new radial slot

    **Bosses Menu Hierarchy:**
    ```
    boss_tracker (Node)
    ├── PanelContainer (Background)
    │   ├── Label (Title - "Boss Progress")
    │   ├── ScrollContainer (List of bosses)
    │   │   └── VBoxContainer
    │   │       └── Boss entries (one per boss)
    │   │           ├── HBoxContainer
    │   │           │   ├── TextureRect (Boss icon - defeated/locked status)
    │   │           │   ├── Label (Boss name)
    │   │           │   └── Label (Reward/Unlock status)
    ```

    **Boss Entry Template:**
    - Defeated boss: Shows boss icon + "DEFEATED" + reward received indicator (✓)
    - Locked boss: Shows placeholder icon + "LOCKED" + boss name
    - Pending reward: Shows boss icon + "Reward Available!" claim button

    **Script Integration:**
    ```gdscript
    func _populate_boss_tracker() -> void:
        var boss_container = $BossesMenu/BossList/VBoxContainer
        for child in boss_container.get_children():
            child.queue_free()

        var all_bosses = [0, 1, 2, 3] # BossID enum values
        for boss_id in all_bosses:
            var entry = _create_boss_entry(boss_id)
            boss_container.add_child(entry)

    func _create_boss_entry(boss_id: int) -> Control:
        var is_defeated = BossRewardManager.is_boss_defeated(boss_id)
        var boss_name = BossRewardManager.BOSS_NAMES[boss_id]

        var entry = HBoxContainer.new()

        # Boss icon
        var icon = TextureRect.new()
        if is_defeated:
            icon.texture = _get_defeated_icon(boss_id)
        else:
            icon.texture = preload("res://ui/icons/locked.png") # Gray lock icon
        entry.add_child(icon)

        # Boss name
        var label = Label.new()
        label.text = boss_name if is_defeated else "%s [LOCKED]" % boss_name
        entry.add_child(label)

        # Status indicator
        var status = Label.new()
        if is_defeated:
            status.text = "Defeated" # Could show specific reward
            status.modulate = Color(0, 1, 0, 1) # Green
        else:
            status.text = "---"
            status.modulate = Color(0.7, 0.7, 0.7, 1) # Gray
        entry.add_child(status)

        return entry
    ```

    Follow existing ring menu patterns (radial slots, programmatic UI).
  </action>
  <verify>
    Check ring_menu.tscn contains:
    - "Bosses" menu slot in radial structure
    - boss_tracker Node with boss list
    - Boss entries showing name, icon, status
  </verify>
  <done>
    Boss tracker added to ring menu. Shows defeated bosses and pending rewards. Follows existing ring menu UI patterns.
  </done>
</task>

<task type="auto">
  <name>Add boss reward signals to Events autoload</name>
  <files>autoloads/events.gd</files>
  <action>
    Add boss reward signals to Events autoload for cross-system communication.

    **Signals to Add:**
    ```gdscript
    ## Boss reward signals
    signal boss_reward_unlocked(boss_id: int)          # Boss defeated, reward available
    signal boss_reward_claimed(boss_id: int, reward: Dictionary) # Player claimed reward
    ```

    **Signal Usage:**
    - boss_reward_unlocked: Emitted by BossRewardManager when boss defeated
      → Triggers boss_reward_popup.show_reward()
      → Updates boss tracker UI

    - boss_reward_claimed: Emitted when player claims reward from popup
      → Persists reward claimed state to save
      → Updates any dependent systems (e.g., UI badges)

    Follow existing Events patterns (signal naming, parameter types).
  </action>
  <verify>
    Check Events.gd contains:
    - boss_reward_unlocked signal
    - boss_reward_claimed signal
    - Proper signal parameter types
  </verify>
  <done>
    Boss reward signals added to Events autoload. Boss reward popup and tracker can listen for reward events.
  </done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>Complete boss reward UI system:
- Boss reward popup with reward details and claim button
- Boss tracker in ring menu showing defeated bosses
- Boss reward signals in Events autoload</what-built>
  <how-to-verify>
    1. Start game in editor or headless
    2. Defeat a boss (or simulate boss defeat via BossRewardManager.mark_boss_defeated())
    3. Verify boss reward popup appears:
       - Shows boss name and "DEFEATED!"
       - Shows reward description and unlock info
       - Claim button is enabled
    4. Click Claim button:
       - Popup closes
       - Boss tracker updates to show "Defeated" status
    5. Open ring menu (F3 or R1+LStick):
       - Navigate to "Bosses" menu
       - Verify boss list shows defeated boss with green status
       - Verify locked bosses show gray lock icon
    6. Check console for any errors related to boss rewards
  </how-to-verify>
  <resume-signal>Type "approved" or describe issues</resume-signal>
</task>

</tasks>

<verification>
After all tasks complete:
- [ ] boss_reward_popup.tscn scene exists with proper hierarchy
- [ ] Ring menu has "Bosses" slot with boss tracker
- [ ] Events autoload has boss_reward_unlocked and boss_reward_claimed signals
- [ ] No syntax errors in UI scripts
- [ ] Boss reward popup shows on boss defeat (manual test)
- [ ] Boss tracker populates with boss list
</verification>

<success_criteria>
1. Boss reward popup appears when boss is defeated with clear reward information
2. Boss tracker accessible from ring menu showing all bosses (defeated + locked)
3. Reward claim button properly persists claimed state
4. Boss rewards integrate with existing game systems (Save, UI, Shop)
5. No errors in boss reward UI or signal handling
</success_criteria>

<output>
After completion, create `.planning/phases/50-boss-reward-design/50-boss-reward-design-03-SUMMARY.md`
</output>
