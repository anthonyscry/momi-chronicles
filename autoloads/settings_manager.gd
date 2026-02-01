extends Node
class_name SettingsManager
## Manages game settings and persists them to disk.
## Handles audio volumes, video settings, and screen shake intensity.

## Emitted when any setting changes
signal settings_changed()

## Emitted when audio settings change (master, music, or sfx volume)
signal audio_settings_changed()

## Emitted when video settings change (fullscreen or screen shake)
signal video_settings_changed()

## Settings file path
const SETTINGS_FILE: String = "user://settings.cfg"

## Default settings values
const DEFAULT_MASTER_VOLUME: float = 0.8
const DEFAULT_MUSIC_VOLUME: float = 0.7
const DEFAULT_SFX_VOLUME: float = 0.8
const DEFAULT_FULLSCREEN: bool = false
const DEFAULT_SCREEN_SHAKE: float = 1.0  # 0.0 = off, 1.0 = full intensity

## Current settings
var master_volume: float = DEFAULT_MASTER_VOLUME
var music_volume: float = DEFAULT_MUSIC_VOLUME
var sfx_volume: float = DEFAULT_SFX_VOLUME
var fullscreen: bool = DEFAULT_FULLSCREEN
var screen_shake_intensity: float = DEFAULT_SCREEN_SHAKE

## ConfigFile instance for saving/loading
var _config: ConfigFile = ConfigFile.new()


func _ready() -> void:
	load_settings()
	apply_all_settings()


## Load settings from disk
func load_settings() -> void:
	var err = _config.load(SETTINGS_FILE)

	if err == OK:
		# Load audio settings
		master_volume = _config.get_value("audio", "master_volume", DEFAULT_MASTER_VOLUME)
		music_volume = _config.get_value("audio", "music_volume", DEFAULT_MUSIC_VOLUME)
		sfx_volume = _config.get_value("audio", "sfx_volume", DEFAULT_SFX_VOLUME)

		# Load video settings
		fullscreen = _config.get_value("video", "fullscreen", DEFAULT_FULLSCREEN)
		screen_shake_intensity = _config.get_value("video", "screen_shake_intensity", DEFAULT_SCREEN_SHAKE)
	else:
		# File doesn't exist or error reading, use defaults
		push_warning("SettingsManager: Could not load settings file, using defaults")


## Save settings to disk
func save_settings() -> void:
	# Audio settings
	_config.set_value("audio", "master_volume", master_volume)
	_config.set_value("audio", "music_volume", music_volume)
	_config.set_value("audio", "sfx_volume", sfx_volume)

	# Video settings
	_config.set_value("video", "fullscreen", fullscreen)
	_config.set_value("video", "screen_shake_intensity", screen_shake_intensity)

	var err = _config.save(SETTINGS_FILE)
	if err != OK:
		push_error("SettingsManager: Failed to save settings file")


## Apply all settings to the game systems
func apply_all_settings() -> void:
	apply_audio_settings()
	apply_video_settings()


## Apply audio settings to AudioServer
func apply_audio_settings() -> void:
	# Convert 0.0-1.0 volume to decibels for AudioServer
	# 0.0 = -80db (silent), 1.0 = 0db (full volume)
	var master_db: float = linear_to_db(master_volume) if master_volume > 0 else -80
	var music_db: float = linear_to_db(music_volume) if music_volume > 0 else -80
	var sfx_db: float = linear_to_db(sfx_volume) if sfx_volume > 0 else -80

	# Apply to AudioServer buses
	var master_idx: int = AudioServer.get_bus_index("Master")
	var music_idx: int = AudioServer.get_bus_index("Music")
	var sfx_idx: int = AudioServer.get_bus_index("SFX")

	if master_idx >= 0:
		AudioServer.set_bus_volume_db(master_idx, master_db)

	if music_idx >= 0:
		AudioServer.set_bus_volume_db(music_idx, music_db)

	if sfx_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_idx, sfx_db)

	audio_settings_changed.emit()


## Apply video settings
func apply_video_settings() -> void:
	# Apply fullscreen mode
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	# Screen shake intensity is read by EffectsManager when needed
	# No direct application required here

	video_settings_changed.emit()


## Set master volume (0.0 to 1.0)
func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	apply_audio_settings()
	save_settings()
	settings_changed.emit()


## Set music volume (0.0 to 1.0)
func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	apply_audio_settings()
	save_settings()
	settings_changed.emit()


## Set SFX volume (0.0 to 1.0)
func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	apply_audio_settings()
	save_settings()
	settings_changed.emit()


## Set fullscreen mode
func set_fullscreen(value: bool) -> void:
	fullscreen = value
	apply_video_settings()
	save_settings()
	settings_changed.emit()


## Set screen shake intensity (0.0 = off, 1.0 = full)
func set_screen_shake_intensity(value: float) -> void:
	screen_shake_intensity = clampf(value, 0.0, 1.0)
	apply_video_settings()
	save_settings()
	settings_changed.emit()


## Get master volume
func get_master_volume() -> float:
	return master_volume


## Get music volume
func get_music_volume() -> float:
	return music_volume


## Get SFX volume
func get_sfx_volume() -> float:
	return sfx_volume


## Get fullscreen state
func get_fullscreen() -> bool:
	return fullscreen


## Get screen shake intensity
func get_screen_shake_intensity() -> float:
	return screen_shake_intensity
