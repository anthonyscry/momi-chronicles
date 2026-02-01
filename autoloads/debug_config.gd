extends Node
class_name DebugConfig
## Centralized debug configuration and runtime toggle system.
## Provides a single source of truth for debug mode detection and feature flags.

# =============================================================================
# DEBUG MODE DETECTION
# =============================================================================

## Whether the game is running in debug build (editor or debug export)
func is_debug_mode() -> bool:
	return OS.is_debug_build()

# =============================================================================
# DEBUG FEATURE FLAGS
# =============================================================================

## Whether to show debug UI overlays (HUD panel, AudioDebug, etc.)
## Default: true in debug builds, false in release builds
var show_debug_ui: bool = OS.is_debug_build()

## Whether to enable debug logging to console and files
## Default: true in debug builds, false in release builds
var enable_debug_logging: bool = OS.is_debug_build()

# =============================================================================
# SIGNALS
# =============================================================================

## Emitted when debug UI visibility is toggled (F12 key in debug builds)
signal debug_ui_toggled(visible: bool)

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# In release builds, force debug features off regardless of initial values
	if not is_debug_mode():
		show_debug_ui = false
		enable_debug_logging = false
