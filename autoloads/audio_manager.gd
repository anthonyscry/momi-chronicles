extends Node
class_name AudioManager
## Manages all game audio - background music and sound effects.
## Handles crossfading between tracks, volume control, dynamic music, and audio bus routing.
## 
## Dynamic Music System:
## - Health-based: Switches to low_health track when player HP is critical
## - Combat-based: Different tracks for first encounter, surrounded, winning, boss fights
## - Time-based: Morning/evening/night variants for neighborhood zone
## - Zone-based: Different music for different areas (neighborhood, backyard, shed)

# =============================================================================
# CONFIGURATION
# =============================================================================

## Music crossfade duration in seconds
const CROSSFADE_DURATION: float = 1.0

## Default volumes (0.0 to 1.0)
const DEFAULT_MASTER_VOLUME: float = 0.8
const DEFAULT_MUSIC_VOLUME: float = 0.7
const DEFAULT_SFX_VOLUME: float = 0.8

## Dynamic music thresholds
const LOW_HEALTH_THRESHOLD: float = 0.25  # Switch to danger music below 25% HP
const SURROUNDED_ENEMY_COUNT: int = 3     # Switch to surrounded music with 3+ enemies nearby
const WINNING_ENEMY_COUNT: int = 2        # Switch to winning music with 2 or fewer enemies left

# =============================================================================
# AUDIO PATHS
# =============================================================================

## Music tracks - all available tracks with A/B versions
var music_tracks: Dictionary = {
	# Essential tracks
	"title": "res://assets/audio/music/title.wav",
	"neighborhood": "res://assets/audio/music/neighborhood.wav",
	"backyard": "res://assets/audio/music/backyard.wav",
	"combat": "res://assets/audio/music/combat.wav",
	"game_over": "res://assets/audio/music/game_over.wav",
	"victory": "res://assets/audio/music/victory.wav",
	"pause": "res://assets/audio/music/pause.wav",
	
	# Zone - Sewers
	"sewers": "res://assets/audio/music/sewers.wav",
	
	# Zone variations - Neighborhood
	"neighborhood_morning": "res://assets/audio/music/neighborhood_morning.wav",
	"neighborhood_evening": "res://assets/audio/music/neighborhood_evening.wav",
	"neighborhood_night": "res://assets/audio/music/neighborhood_night.wav",
	
	# Zone variations - Backyard
	"backyard_deep": "res://assets/audio/music/backyard_deep.wav",
	"backyard_shed": "res://assets/audio/music/backyard_shed.wav",
	
	# Character themes
	"crow_theme": "res://assets/audio/music/crow_theme.wav",
	
	# Combat variations
	"first_encounter": "res://assets/audio/music/first_encounter.wav",
	"surrounded": "res://assets/audio/music/surrounded.wav",
	"winning": "res://assets/audio/music/winning.wav",
	"low_health": "res://assets/audio/music/low_health.wav",
	"boss_fight": "res://assets/audio/music/boss_fight.wav",
}

## Sound effects
var sfx_tracks: Dictionary = {
	"attack": "res://assets/audio/sfx/attack.wav",
	"hit": "res://assets/audio/sfx/hit.wav",
	"player_hurt": "res://assets/audio/sfx/player_hurt.wav",
	"enemy_hurt": "res://assets/audio/sfx/enemy_hurt.wav",
	"enemy_death": "res://assets/audio/sfx/enemy_death.wav",
	"player_death": "res://assets/audio/sfx/player_death.wav",
	"dodge": "res://assets/audio/sfx/dodge.wav",
	"menu_select": "res://assets/audio/sfx/menu_select.wav",
	"menu_navigate": "res://assets/audio/sfx/menu_navigate.wav",
	"menu_open": "res://assets/audio/sfx/menu_open.wav",
	"menu_close": "res://assets/audio/sfx/menu_close.wav",
	"inventory_open": "res://assets/audio/sfx/inventory_open.wav",
	"inventory_close": "res://assets/audio/sfx/inventory_close.wav",
	"ring_menu_open": "res://assets/audio/sfx/ring_menu_open.wav",
	"ring_menu_close": "res://assets/audio/sfx/ring_menu_close.wav",
	"zone_transition": "res://assets/audio/sfx/zone_transition.wav",
	"health_pickup": "res://assets/audio/sfx/health_pickup.wav",
	"coin": "res://assets/audio/sfx/coin.wav",
	"level_up": "res://assets/audio/sfx/level_up.wav",
	# Phase P4: Audio polish
	"footstep_walk": "res://assets/audio/sfx/footstep_walk.wav",
	"footstep_run": "res://assets/audio/sfx/footstep_run.wav",
	"block": "res://assets/audio/sfx/block.wav",
	"parry": "res://assets/audio/sfx/parry.wav",
	"heartbeat": "res://assets/audio/sfx/heartbeat.wav",
	"ground_pound": "res://assets/audio/sfx/ground_pound.wav",
	"charge_start": "res://assets/audio/sfx/charge_start.wav",
	"charge_release": "res://assets/audio/sfx/charge_release.wav",
}

# =============================================================================
# A/B TESTING
# =============================================================================

## Current version being played ("a" or "b")
var current_version: String = "a"

## Signal emitted when version changes (for UI)
signal version_changed(track_name: String, version: String)

## Tracks that have A/B versions available
var ab_tracks: Array[String] = [
	# Essential
	"title", "neighborhood", "backyard", "combat", "game_over", "victory", "pause",
	# Zone variations
	"neighborhood_morning", "neighborhood_evening", "neighborhood_night",
	"backyard_deep", "backyard_shed",
	# Character themes
	"crow_theme",
	# Combat variations
	"first_encounter", "surrounded", "winning", "low_health", "boss_fight"
]

# =============================================================================
# DYNAMIC MUSIC STATE
# =============================================================================

## Current zone for context
var current_zone: String = ""

## Base track for the current zone (before combat/health overrides)
var zone_base_track: String = ""

## Whether we're in combat
var in_combat: bool = false

## Combat start time (for first encounter detection)
var combat_start_time: float = 0.0

## Is this the first combat of the session?
var is_first_combat: bool = true

## Current player health percent (0.0 to 1.0)
var player_health_percent: float = 1.0

## Number of nearby enemies
var nearby_enemy_count: int = 0

## Total enemies in the zone
var total_enemy_count: int = 0

## Simulated game time (0.0 to 24.0 hours)
var game_time: float = 10.0  # Start at 10 AM

## Game time speed (hours per real second) - 1 hour = 60 real seconds
const TIME_SPEED: float = 1.0 / 60.0

## Track what dynamic state we're in
enum MusicState { EXPLORATION, COMBAT, LOW_HEALTH, BOSS }
var music_state: MusicState = MusicState.EXPLORATION

# =============================================================================
# STATE
# =============================================================================

## Currently playing music track name
var current_music: String = ""

## Previous music (for resuming after pause)
var previous_music: String = ""

## Whether audio is enabled
var audio_enabled: bool = true

## Cached audio streams
var _music_cache: Dictionary = {}
var _sfx_cache: Dictionary = {}

## Tracks that failed to load (don't spam warnings)
var _failed_tracks: Dictionary = {}

# =============================================================================
# NODE REFERENCES
# =============================================================================

var music_player_a: AudioStreamPlayer
var music_player_b: AudioStreamPlayer
var active_music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []

const MAX_SFX_PLAYERS: int = 8

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	_setup_audio_players()
	_connect_signals()
	_load_settings()
	print("AudioManager ready - Dynamic music enabled!")
	print("  F2 = Toggle A/B versions")


func _process(delta: float) -> void:
	# Advance game time
	game_time += TIME_SPEED * delta
	if game_time >= 24.0:
		game_time -= 24.0
	
	# Update dynamic music state
	_update_dynamic_music()
	
	# Footstep system
	_update_footsteps(delta)
	
	# Heartbeat system
	_update_heartbeat(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F2:
			toggle_ab_version()


## Toggle between A and B versions of current track
func toggle_ab_version() -> void:
	if current_music.is_empty():
		return
	
	# Toggle version
	current_version = "b" if current_version == "a" else "a"
	print("[AudioManager] Switched to version %s" % current_version.to_upper())
	
	# Replay current track with new version
	var track = current_music
	current_music = ""  # Reset so play_music doesn't skip
	play_music(track, true)
	
	# Emit signal for UI
	version_changed.emit(track, current_version)


## Get the actual file path for a track (with A/B suffix if available)
func _get_track_path(track_name: String) -> String:
	var base_path = music_tracks.get(track_name, "")
	if base_path.is_empty():
		return ""
	
	# Check if this track has A/B versions
	if track_name in ab_tracks:
		var ab_path = base_path.replace(".wav", "_%s.wav" % current_version)
		if ResourceLoader.exists(ab_path):
			return ab_path
	
	return base_path


## Get current track info for UI display
func get_current_track_info() -> Dictionary:
	return {
		"track": current_music,
		"version": current_version.to_upper() if current_music in ab_tracks else "",
		"has_ab": current_music in ab_tracks,
		"state": MusicState.keys()[music_state],
		"time": "%02d:%02d" % [int(game_time), int((game_time - int(game_time)) * 60)]
	}


func _setup_audio_players() -> void:
	# Create two music players for crossfading
	music_player_a = AudioStreamPlayer.new()
	music_player_a.bus = "Music"
	music_player_a.name = "MusicPlayerA"
	add_child(music_player_a)
	
	music_player_b = AudioStreamPlayer.new()
	music_player_b.bus = "Music"
	music_player_b.name = "MusicPlayerB"
	add_child(music_player_b)
	
	active_music_player = music_player_a
	
	# Create pool of SFX players
	for i in range(MAX_SFX_PLAYERS):
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.bus = "SFX"
		sfx_player.name = "SFXPlayer%d" % i
		add_child(sfx_player)
		sfx_players.append(sfx_player)


## Heartbeat system for low HP
var _heartbeat_active: bool = false
var _heartbeat_timer: float = 0.0
const HEARTBEAT_INTERVAL: float = 0.7  # Time between heartbeats

## Footstep system
var _footstep_timer: float = 0.0
var _player_moving: bool = false
var _player_running: bool = false
const WALK_STEP_INTERVAL: float = 0.35
const RUN_STEP_INTERVAL: float = 0.22

func _connect_signals() -> void:
	# Connect to game events for automatic audio
	Events.player_attacked.connect(_on_player_attacked)
	Events.player_damaged.connect(_on_player_damaged)
	Events.player_died.connect(_on_player_died)
	Events.player_dodged.connect(_on_player_dodged)
	Events.enemy_damaged.connect(_on_enemy_damaged)
	Events.enemy_defeated.connect(_on_enemy_defeated)
	Events.zone_entered.connect(_on_zone_entered)
	Events.game_paused.connect(_on_game_paused)
	Events.game_resumed.connect(_on_game_resumed)
	Events.game_over.connect(_on_game_over)
	Events.player_health_changed.connect(_on_player_health_changed)
	# Phase P4: Block/parry sounds
	Events.player_block_started.connect(_on_player_block_started)
	Events.player_parried.connect(_on_player_parried)
	# Phase P4: Combat abilities
	Events.player_ground_pound_impact.connect(_on_ground_pound_audio)
	Events.player_charge_started.connect(_on_charge_started_audio)
	Events.player_charge_released.connect(_on_charge_released_audio)

# =============================================================================
# DYNAMIC MUSIC SYSTEM
# =============================================================================

func _update_dynamic_music() -> void:
	# Don't update during menus or game over
	if current_zone.is_empty():
		return
	
	# Get player reference for health
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("HealthComponent"):
		var health = player.get_node("HealthComponent")
		player_health_percent = health.get_health_percent()
	
	# Count enemies
	var enemies = get_tree().get_nodes_in_group("enemies")
	total_enemy_count = 0
	nearby_enemy_count = 0
	
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.has_method("is_alive") and enemy.is_alive():
			total_enemy_count += 1
			if player and player.global_position.distance_to(enemy.global_position) < 100.0:
				nearby_enemy_count += 1
	
	# Determine what music should play
	var target_track = _get_dynamic_track()
	
	# Switch if different from current
	if target_track != current_music and not target_track.is_empty():
		play_music(target_track, true)


func _get_dynamic_track() -> String:
	# Priority 1: Low health (critical danger!)
	if player_health_percent <= LOW_HEALTH_THRESHOLD and total_enemy_count > 0:
		music_state = MusicState.LOW_HEALTH
		return "low_health"
	
	# Priority 2: Combat states
	if in_combat and total_enemy_count > 0:
		music_state = MusicState.COMBAT
		
		# First combat of the session - tutorial feel
		if is_first_combat and Time.get_ticks_msec() - combat_start_time < 10000:
			return "first_encounter"
		
		# Surrounded by many enemies
		if nearby_enemy_count >= SURROUNDED_ENEMY_COUNT:
			return "surrounded"
		
		# Winning - few enemies left
		if total_enemy_count <= WINNING_ENEMY_COUNT:
			return "winning"
		
		# Default combat
		return "combat"
	
	# Priority 3: Exploration - zone-based with time variants
	music_state = MusicState.EXPLORATION
	in_combat = false  # Reset combat flag when no enemies nearby
	
	return _get_zone_track()


func _get_zone_track() -> String:
	match current_zone:
		"neighborhood", "test_zone":
			# Use base neighborhood track (time variants disabled for now)
			return "neighborhood"
		
		"backyard":
			return "backyard"
		
		"backyard_deep", "deep_woods":
			return "backyard"  # Fallback to backyard
		
		"shed", "backyard_shed":
			return "backyard"  # Fallback to backyard
		
		"boss_arena":
			return "combat"  # Boss arena uses combat music
		
		"sewers":
			return "sewers"
		
		_:
			return zone_base_track if not zone_base_track.is_empty() else "neighborhood"


## Start combat music
func start_combat() -> void:
	if not in_combat:
		in_combat = true
		combat_start_time = Time.get_ticks_msec()
		# Don't immediately switch - let _update_dynamic_music handle it
		# This allows smooth transitions


## End combat (call when all enemies defeated)
func end_combat() -> void:
	in_combat = false
	is_first_combat = false  # No longer first combat after any combat ends


## Set game time manually (for testing or story events)
func set_game_time(hour: float) -> void:
	game_time = clamp(hour, 0.0, 24.0)
	print("[AudioManager] Game time set to %02d:%02d" % [int(game_time), int((game_time - int(game_time)) * 60)])

# =============================================================================
# MUSIC CONTROL
# =============================================================================

## Play a music track by name (with optional crossfade)
func play_music(track_name: String, crossfade: bool = true) -> void:
	if not audio_enabled:
		return
	
	if track_name == current_music:
		return  # Already playing
	
	# Skip tracks that already failed (prevents log spam)
	if _failed_tracks.has(track_name):
		return
	
	if not music_tracks.has(track_name):
		push_warning("AudioManager: Unknown music track '%s'" % track_name)
		_failed_tracks[track_name] = true
		return
	
	var stream = _get_music_stream(track_name)
	if stream == null:
		push_warning("AudioManager: Could not load music '%s'" % track_name)
		_failed_tracks[track_name] = true
		return
	
	previous_music = current_music
	current_music = track_name
	
	if crossfade and active_music_player.playing:
		_crossfade_to(stream)
	else:
		_play_immediate(stream)


## Stop music (with optional fade out)
func stop_music(fade_out: bool = true) -> void:
	if fade_out:
		var tween = create_tween()
		tween.tween_property(active_music_player, "volume_db", -80.0, CROSSFADE_DURATION)
		tween.tween_callback(active_music_player.stop)
	else:
		active_music_player.stop()
	
	current_music = ""


## Pause music
func pause_music() -> void:
	active_music_player.stream_paused = true


## Resume music
func resume_music() -> void:
	active_music_player.stream_paused = false


func _play_immediate(stream: AudioStream) -> void:
	active_music_player.stream = stream
	active_music_player.volume_db = 0.0
	active_music_player.play()


func _crossfade_to(stream: AudioStream) -> void:
	# Determine which player to fade to
	var fade_out_player = active_music_player
	var fade_in_player = music_player_b if active_music_player == music_player_a else music_player_a
	
	# Set up new player
	fade_in_player.stream = stream
	fade_in_player.volume_db = -80.0
	fade_in_player.play()
	
	# Crossfade
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(fade_out_player, "volume_db", -80.0, CROSSFADE_DURATION)
	tween.tween_property(fade_in_player, "volume_db", 0.0, CROSSFADE_DURATION)
	tween.set_parallel(false)
	tween.tween_callback(fade_out_player.stop)
	
	active_music_player = fade_in_player


func _get_music_stream(track_name: String) -> AudioStream:
	# Use versioned cache key for A/B testing
	var cache_key = track_name + "_" + current_version
	if _music_cache.has(cache_key):
		return _music_cache[cache_key]
	
	# Get path (with A/B suffix if available)
	var path = _get_track_path(track_name)
	if path.is_empty() or not ResourceLoader.exists(path):
		# Fallback to base path
		path = music_tracks.get(track_name, "")
		if path.is_empty() or not ResourceLoader.exists(path):
			return null
	
	var stream = load(path) as AudioStream
	if stream:
		_music_cache[cache_key] = stream
	print("[AudioManager] Playing: %s (version %s)" % [track_name, current_version.to_upper()])
	return stream

# =============================================================================
# SFX CONTROL
# =============================================================================

## Play a sound effect by name
func play_sfx(sfx_name: String, volume_db: float = 0.0, pitch_variance: float = 0.0) -> void:
	if not audio_enabled:
		return
	
	if not sfx_tracks.has(sfx_name):
		push_warning("AudioManager: Unknown SFX '%s'" % sfx_name)
		return
	
	var stream = _get_sfx_stream(sfx_name)
	if stream == null:
		# Silently fail if SFX not found (placeholder system)
		return
	
	var player = _get_available_sfx_player()
	if player == null:
		return  # All players busy
	
	player.stream = stream
	player.volume_db = volume_db
	
	# Add pitch variance for variety
	if pitch_variance > 0.0:
		player.pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance)
	else:
		player.pitch_scale = 1.0
	
	player.play()


func _get_sfx_stream(sfx_name: String) -> AudioStream:
	if _sfx_cache.has(sfx_name):
		return _sfx_cache[sfx_name]
	
	var path = sfx_tracks[sfx_name]
	if not ResourceLoader.exists(path):
		return null
	
	var stream = load(path) as AudioStream
	if stream:
		_sfx_cache[sfx_name] = stream
	return stream


func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	# All busy, return first one (will interrupt)
	return sfx_players[0]

# =============================================================================
# VOLUME CONTROL
# =============================================================================

## Set master volume (0.0 to 1.0)
func set_master_volume(volume: float) -> void:
	volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume))


## Set music volume (0.0 to 1.0)
func set_music_volume(volume: float) -> void:
	volume = clamp(volume, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))


## Set SFX volume (0.0 to 1.0)
func set_sfx_volume(volume: float) -> void:
	volume = clamp(volume, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))


## Get current master volume (0.0 to 1.0)
func get_master_volume() -> float:
	return db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))


## Get current music volume (0.0 to 1.0)
func get_music_volume() -> float:
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx >= 0:
		return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
	return DEFAULT_MUSIC_VOLUME


## Get current SFX volume (0.0 to 1.0)
func get_sfx_volume() -> float:
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx >= 0:
		return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
	return DEFAULT_SFX_VOLUME


## Toggle all audio on/off
func toggle_audio() -> void:
	audio_enabled = not audio_enabled
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not audio_enabled)

# =============================================================================
# EVENT HANDLERS - Automatic audio triggers
# =============================================================================

func _on_player_attacked() -> void:
	play_sfx("attack", 0.0, 0.1)
	start_combat()  # Player attacking means combat started


func _on_player_damaged(_amount: int) -> void:
	play_sfx("player_hurt", 0.0, 0.1)
	start_combat()  # Taking damage means combat


func _on_player_died() -> void:
	play_sfx("player_death")
	end_combat()
	_heartbeat_active = false  # Stop heartbeat on death


func _on_player_dodged() -> void:
	play_sfx("dodge", 0.0, 0.1)


func _on_enemy_damaged(_enemy: Node, _amount: int) -> void:
	play_sfx("enemy_hurt", -3.0, 0.15)
	start_combat()


func _on_enemy_defeated(_enemy: Node) -> void:
	play_sfx("enemy_death", 0.0, 0.1)
	
	# Check if all enemies defeated
	await get_tree().process_frame  # Wait a frame for enemy to be removed
	var enemies = get_tree().get_nodes_in_group("enemies")
	var living = 0
	for e in enemies:
		if is_instance_valid(e) and e.has_method("is_alive") and e.is_alive():
			living += 1
	
	if living == 0:
		end_combat()


func _on_zone_entered(zone_name: String) -> void:
	play_sfx("zone_transition")
	current_zone = zone_name
	
	# Set zone base track
	match zone_name:
		"neighborhood", "test_zone":
			zone_base_track = "neighborhood"
		"backyard":
			zone_base_track = "backyard"
		"backyard_deep", "deep_woods":
			zone_base_track = "backyard_deep"
		"shed", "backyard_shed":
			zone_base_track = "backyard_shed"
		"sewers":
			zone_base_track = "sewers"
		_:
			zone_base_track = "neighborhood"
	
	# Let dynamic music system pick the right track
	_update_dynamic_music()


func _on_player_health_changed(current: int, max_health: int) -> void:
	player_health_percent = float(current) / float(max_health) if max_health > 0 else 1.0
	
	# Heartbeat: activate when low HP, deactivate when recovered
	var should_heartbeat = player_health_percent <= LOW_HEALTH_THRESHOLD and player_health_percent > 0.0
	if should_heartbeat and not _heartbeat_active:
		_heartbeat_active = true
		_heartbeat_timer = 0.0  # Play immediately
	elif not should_heartbeat and _heartbeat_active:
		_heartbeat_active = false


func _on_game_paused() -> void:
	# Lower music volume
	var tween = create_tween()
	tween.tween_property(active_music_player, "volume_db", -10.0, 0.3)


func _on_game_resumed() -> void:
	# Restore music volume
	var tween = create_tween()
	tween.tween_property(active_music_player, "volume_db", 0.0, 0.3)


func _on_game_over() -> void:
	current_zone = ""  # Disable dynamic music
	play_music("game_over", true)

# =============================================================================
# SETTINGS PERSISTENCE
# =============================================================================

func _load_settings() -> void:
	# Load from config file if exists
	var config = ConfigFile.new()
	var err = config.load("user://audio_settings.cfg")
	
	if err == OK:
		set_master_volume(config.get_value("audio", "master_volume", DEFAULT_MASTER_VOLUME))
		set_music_volume(config.get_value("audio", "music_volume", DEFAULT_MUSIC_VOLUME))
		set_sfx_volume(config.get_value("audio", "sfx_volume", DEFAULT_SFX_VOLUME))
		audio_enabled = config.get_value("audio", "enabled", true)
	else:
		# Use defaults
		set_master_volume(DEFAULT_MASTER_VOLUME)
		set_music_volume(DEFAULT_MUSIC_VOLUME)
		set_sfx_volume(DEFAULT_SFX_VOLUME)


func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "master_volume", get_master_volume())
	config.set_value("audio", "music_volume", get_music_volume())
	config.set_value("audio", "sfx_volume", get_sfx_volume())
	config.set_value("audio", "enabled", audio_enabled)
	config.save("user://audio_settings.cfg")

# =============================================================================
# FOOTSTEP SYSTEM
# =============================================================================

func _update_footsteps(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player or not is_instance_valid(player):
		_player_moving = false
		return
	
	# Check if player is moving (velocity > threshold)
	var is_moving = player.velocity.length() > 10.0
	var is_running = player.is_running() if player.has_method("is_running") else false
	
	_player_moving = is_moving
	_player_running = is_running
	
	if not _player_moving:
		_footstep_timer = 0.0
		return
	
	_footstep_timer += delta
	var interval = RUN_STEP_INTERVAL if _player_running else WALK_STEP_INTERVAL
	
	if _footstep_timer >= interval:
		_footstep_timer -= interval
		var sfx_name = "footstep_run" if _player_running else "footstep_walk"
		play_sfx(sfx_name, -8.0, 0.15)  # Quiet with pitch variance

# =============================================================================
# HEARTBEAT SYSTEM
# =============================================================================

func _update_heartbeat(delta: float) -> void:
	if not _heartbeat_active:
		return
	
	_heartbeat_timer += delta
	if _heartbeat_timer >= HEARTBEAT_INTERVAL:
		_heartbeat_timer -= HEARTBEAT_INTERVAL
		play_sfx("heartbeat", -4.0, 0.05)

# =============================================================================
# PHASE P4 EVENT HANDLERS
# =============================================================================

func _on_player_block_started() -> void:
	play_sfx("block", -2.0, 0.1)

func _on_player_parried(_attacker: Node, _reflected_damage: int) -> void:
	play_sfx("parry", 0.0, 0.05)

func _on_ground_pound_audio(_damage: int, _radius: float) -> void:
	play_sfx("ground_pound", 0.0, 0.1)

func _on_charge_started_audio() -> void:
	play_sfx("charge_start", -3.0, 0.0)

func _on_charge_released_audio(_damage: int, _charge_percent: float) -> void:
	play_sfx("charge_release", 0.0, 0.1)
