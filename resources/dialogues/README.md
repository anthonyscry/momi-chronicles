# Dialogue System - Data Format Documentation

This directory contains dialogue data files for the Momi's Adventure dialogue system. Dialogues are defined in JSON format and loaded at runtime by the `DialogueData` class.

## File Format

Dialogue files use JSON format with the following structure:

```json
{
  "dialogues": [
    {
      "id": "unique_dialogue_id",
      "character": "Character Name",
      "portrait": "res://path/to/portrait.png",
      "text": "The dialogue text to display",
      "choices": [],
      "next_id": "next_dialogue_id",
      "is_cutscene": false
    }
  ]
}
```

## Field Reference

### Required Fields

- **`id`** (String) - Unique identifier for this dialogue entry. Used to reference this dialogue from other dialogues or NPCs.
  - Example: `"welcome_start"`, `"shopkeeper_greeting"`, `"boss_intro_01"`

- **`text`** (String) - The dialogue text to display in the dialogue box. Supports multiple lines.
  - Example: `"Hello there! Welcome to the neighborhood!"`

### Optional Fields

- **`character`** (String) - The name of the character speaking. Displayed above the dialogue text.
  - Default: `""` (empty)
  - Example: `"Friendly Neighbor"`, `"Mysterious Shopkeeper"`

- **`portrait`** (String) - Path to the character's portrait image (relative to `res://`).
  - Default: `""` (no portrait)
  - Example: `"res://assets/portraits/neighbor.png"`

- **`choices`** (Array) - Array of choice objects for branching dialogue. See [Branching Dialogue](#branching-dialogue) below.
  - Default: `[]` (no choices, linear dialogue)

- **`next_id`** (String) - ID of the next dialogue to display after this one (for linear dialogue chains).
  - Default: `""` (dialogue ends after this entry)
  - Ignored if `choices` array is not empty
  - Example: `"welcome_question"`

- **`is_cutscene`** (Boolean) - Whether this dialogue should trigger cutscene mode (disables player movement/input).
  - Default: `false`
  - Set to `true` for story-critical moments or boss introductions

## Dialogue Patterns

### 1. Simple Dialogue (No Branching)

A single dialogue entry that ends immediately:

```json
{
  "id": "simple_greeting",
  "character": "Shopkeeper",
  "portrait": "res://assets/portraits/shopkeeper.png",
  "text": "Welcome to my shop!",
  "choices": [],
  "next_id": "",
  "is_cutscene": false
}
```

### 2. Linear Dialogue Chain

Multiple dialogue entries linked with `next_id`:

```json
{
  "dialogues": [
    {
      "id": "intro_01",
      "character": "Guide",
      "portrait": "res://assets/portraits/guide.png",
      "text": "Welcome, adventurer!",
      "choices": [],
      "next_id": "intro_02",
      "is_cutscene": false
    },
    {
      "id": "intro_02",
      "character": "Guide",
      "portrait": "res://assets/portraits/guide.png",
      "text": "Let me show you around.",
      "choices": [],
      "next_id": "",
      "is_cutscene": false
    }
  ]
}
```

### 3. Branching Dialogue

Dialogue with player choices that branch to different responses:

```json
{
  "id": "question",
  "character": "NPC",
  "portrait": "res://assets/portraits/npc.png",
  "text": "What brings you here?",
  "choices": [
    {
      "text": "I'm just exploring.",
      "next_id": "response_exploring"
    },
    {
      "text": "I'm looking for someone.",
      "next_id": "response_searching"
    },
    {
      "text": "None of your business!",
      "next_id": "response_rude"
    }
  ],
  "next_id": "",
  "is_cutscene": false
}
```

**Choice Format:**
- **`text`** (String) - The choice text displayed to the player
- **`next_id`** (String) - The dialogue ID to jump to if this choice is selected

**Notes:**
- Supports 2-4 choices per dialogue
- When `choices` array has entries, `next_id` field is ignored
- Each choice must have both `text` and `next_id` fields

### 4. Cutscene Dialogue

Dialogue that disables player control for story moments:

```json
{
  "id": "boss_intro",
  "character": "Boss Enemy",
  "portrait": "res://assets/portraits/boss.png",
  "text": "You dare challenge me?!",
  "choices": [],
  "next_id": "boss_taunt",
  "is_cutscene": true
}
```

**Note:** Set `is_cutscene: true` for:
- Boss encounter introductions
- Story-critical moments
- Zone entry cutscenes
- Quest event sequences

## Usage Guide

### Creating New Dialogue Files

1. Create a new JSON file in this directory (e.g., `npc_librarian.json`)
2. Follow the format structure shown above
3. Start with a root dialogue ID (e.g., `"librarian_greeting"`)
4. Build dialogue chains or branches as needed

### Linking Dialogues in NPCs

In your NPC scene/script, set the dialogue ID to trigger:

```gdscript
# In npc_base.gd
@export var dialogue_id: String = "librarian_greeting"

func _on_interact():
    DialogueManager.start_dialogue(dialogue_id)
```

### Loading Dialogue Files

Dialogue files are loaded by the `DialogueManager` autoload:

```gdscript
# Load a single dialogue file
DialogueManager.load_dialogue("res://data/dialogues/npc_librarian.json")

# Load multiple files
DialogueManager.load_dialogues([
    "res://data/dialogues/npc_librarian.json",
    "res://data/dialogues/npc_shopkeeper.json"
])
```

## Best Practices

### Naming Conventions

- **File names:** Use descriptive names like `npc_[name].json` or `zone_[location]_intro.json`
- **Dialogue IDs:** Use lowercase with underscores: `librarian_greeting`, `boss_intro_01`
- **Character names:** Use proper capitalization: `"Friendly Neighbor"`, `"Old Librarian"`

### Dialogue Writing Tips

1. **Keep it concise:** Dialogue text should fit comfortably in the dialogue box
2. **Show personality:** Each character should have a distinct voice
3. **Meaningful choices:** Branching options should feel impactful to the player
4. **Natural flow:** Read your dialogue aloud to ensure it sounds natural
5. **Earthbound inspiration:** Embrace quirky, charming, slightly absurd humor

### Portrait Images

- Store portraits in `res://assets/portraits/`
- Use consistent sizing (recommended: 128x128 or 256x256 pixels)
- PNG format with transparency recommended
- Name files clearly: `shopkeeper.png`, `boss_slime.png`

### Branching Complexity

- **Simple NPCs:** 1-2 dialogue entries, no branching
- **Interactive NPCs:** 3-5 entries with 1-2 choice points
- **Story NPCs:** 5-10 entries with multiple branches
- **Boss encounters:** Linear cutscene chains (3-5 entries)

### Testing Your Dialogues

1. Use the example dialogue file as a template
2. Test dialogue chains by verifying all `next_id` references exist
3. Ensure choice branches lead to valid dialogue IDs
4. Test in-game to verify typewriter effect and portrait display
5. Check for typos and formatting issues

## Example Files

- **`example_dialogue.json`** - Comprehensive examples of all dialogue patterns
- See this file for reference implementations of:
  - Simple greetings
  - Linear dialogue chains
  - Branching choices
  - Cutscene dialogues

## Error Handling

The `DialogueData` loader provides helpful error messages:

- **File not found:** Check file path is correct
- **JSON parse error:** Validate JSON syntax (use a JSON validator)
- **Missing 'id' field:** All dialogues must have a unique ID
- **Missing 'text' field:** All dialogues must have text content
- **Invalid choice format:** Choices need both `text` and `next_id`
- **Duplicate dialogue_id:** Each ID must be unique within a file

## Localization Preparation

The JSON format is designed to support future localization:

- All text content is in dedicated `text` fields
- Character names can be localized separately
- Portrait paths can point to locale-specific assets
- Consider adding a `locale` field in the root object for multi-language support

## Future Enhancements

Planned features for the dialogue system:

- Character emotion states (e.g., `"emotion": "happy"`)
- Sound effects and voice acting support
- Conditional dialogue based on game state/flags
- Auto-advancing dialogue for cutscenes
- Dialogue history/replay functionality

---

**For more information, see:**
- `systems/dialogue/dialogue_resource.gd` - DialogueResource class definition
- `systems/dialogue/dialogue_data.gd` - JSON loading implementation
- `autoloads/dialogue_manager.gd` - Dialogue manager singleton
