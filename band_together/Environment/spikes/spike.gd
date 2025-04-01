extends Area2D

# Configuration variables - adjust these in the Inspector
# ------------------------------------------------------
@export var is_falling_spike: bool = true   # Set to true for falling behavior
@export var fall_speed: float = 300.0       # Initial falling speed
@export var fall_trigger_distance: float = 60.0  # Horizontal distance to detect player
@export var trigger_delay: float = 1.0      # Time to wait before warning phase
@export var warning_time: float = 0.5       # Duration of warning shake
@export var reset_time: float = 3.0         # Time before spike resets after hitting
@export var respawn_delay: float = 1.0      # Time to wait before respawning
@export var debug_mode: bool = false        # Enable debug prints and visuals

# State tracking variables
# -----------------------
var player = null                # Reference to the player
var original_position: Vector2   # Starting position for reset
var is_falling: bool = false     # Whether spike is currently falling
var has_hit: bool = false        # Whether spike has hit something
var is_warning: bool = false     # Whether in warning/shake phase
var is_delaying: bool = false    # Whether in initial delay phase
var is_resetting: bool = false   # Whether spike is currently resetting
var is_rising: bool = false      # Whether spike is rising back to original position
var warning_timer: float = 0.0   # Timer for warning phase
var delay_timer: float = 0.0     # Timer for delay phase
var fall_gravity: float = 980.0  # Acceleration while falling
var player_detected: bool = false # Whether player is currently detected
var spike_id: int = 0           # Unique ID for this spike instance

# Add a collision mask variable for consistent setup
@export_flags_2d_physics var player_collision_mask: int = 1  # Default player layer

func _ready():
	# Generate a unique ID for this spike
	spike_id = randi()
	
	# Store original position for resetting later
	original_position = global_position
	
	if debug_mode:
		print("FallingSpike %s initialized at: %s" % [spike_id, get_path()])
	
	# Ensure collision layers are set correctly for all spikes
	_setup_collision_layers()
	
	# Find the player in the scene
	find_player()
	
	# Setup the detection area
	if is_falling_spike:
		_setup_detection_area()

# Ensure consistent collision layer setup
func _setup_collision_layers():
	# Set spike's own collision layer (typically layer 3 or 4 for hazards)
	collision_layer = 4  # Adjust to match your project's layer setup
	# Make sure spike can detect players and ground
	collision_mask = player_collision_mask | 2  # Player and ground layers

func find_player():
	# Try various methods to find player and keep trying until successful
	
	# Method 1: Find by group
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		if debug_mode:
			print("Spike %s: Found player in 'player' group: %s" % [spike_id, player.name])
		return true
	
	# Method 2: Find by common paths - expanded to check more paths
	var potential_paths = [
		"/root/Level/Player",
		"/root/Main/Player",
		"../../Player",
		"../Player",
		"/root/Scene/Player"
	]
	
	for path in potential_paths:
		var potential_player = get_node_or_null(path)
		if potential_player:
			player = potential_player
			if debug_mode:
				print("Spike %s: Found player by path: %s" % [spike_id, path])
			return true
	
	# No player found - will try again later
	if debug_mode:
		print("Spike %s: No player found" % spike_id)
	return false

func _setup_detection_area():
	# Make sure we don't have duplicate detection areas
	if has_node("DetectionArea"):
		# If it exists but doesn't have the proper connections, reconnect them
		var area = get_node("DetectionArea")
		# Disconnect any existing connections to avoid duplicates
		if area.is_connected("body_entered", _on_detection_area_body_entered):
			area.body_entered.disconnect(_on_detection_area_body_entered)
		if area.is_connected("body_exited", _on_detection_area_body_exited):
			area.body_exited.disconnect(_on_detection_area_body_exited)
			
		# Reconnect signals
		area.body_entered.connect(_on_detection_area_body_entered)
		area.body_exited.connect(_on_detection_area_body_exited)
		
		if debug_mode:
			print("Spike %s: Reconnected existing DetectionArea signals" % spike_id)
		return
	
	# Create detection area node
	var area = Area2D.new()
	area.name = "DetectionArea"
	add_child(area)
	
	# Create collision shape for detection
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	
	# Set detection area size
	rect.size = Vector2(fall_trigger_distance * 2, 500)  # Width based on trigger distance
	
	shape.shape = rect
	shape.position = Vector2(0, 250)  # Position below the spike
	area.add_child(shape)
	
	# Make sure detection area has the right collision mask to detect players
	area.collision_layer = 0  # Doesn't need to be detected by anything
	area.collision_mask = player_collision_mask  # Only detect players
	
	# Connect signals for player detection
	area.body_entered.connect(_on_detection_area_body_entered)
	area.body_exited.connect(_on_detection_area_body_exited)
	
	if debug_mode:
		print("Spike %s: Created DetectionArea with size: %s" % [spike_id, rect.size])

# Called when a body enters the detection area
func _on_detection_area_body_entered(body):
	if body == player or body.name == "Player" or body.is_in_group("player"):
		if debug_mode:
			print("Spike %s: Player entered detection area" % spike_id)
		
		player_detected = true
		
		# Only start falling sequence if we're not already in it
		if not is_falling and not has_hit and not is_warning and not is_delaying and not is_resetting and not is_rising:
			_start_falling_sequence()

# Called when a body exits the detection area
func _on_detection_area_body_exited(body):
	if body == player or body.name == "Player" or body.is_in_group("player"):
		if debug_mode:
			print("Spike %s: Player exited detection area" % spike_id)
		
		player_detected = false

# Start the falling sequence
func _start_falling_sequence():
	if debug_mode:
		print("Spike %s: Starting falling sequence" % spike_id)
	
	is_delaying = true
	delay_timer = 0.0
	modulate = Color(0.9, 0.9, 1.1)  # Slight bluish tint

func _physics_process(delta):
	# Skip if not configured as a falling spike
	if not is_falling_spike:
		return
	
	# Try to find player periodically if not found yet
	if player == null and Engine.get_frames_drawn() % 30 == (spike_id % 30):
		# Stagger player checks across frames based on spike_id to avoid all spikes checking in the same frame
		find_player()
	
	# Make sure detection area exists and is set up correctly
	if not has_node("DetectionArea") and Engine.get_frames_drawn() % 60 == 0:
		_setup_detection_area()
	
	# Check for direct detection as a backup method
	if player and not is_falling and not has_hit and not is_warning and not is_delaying and not is_resetting and not is_rising:
		var x_distance = abs(player.global_position.x - global_position.x)
		var player_is_below = player.global_position.y > global_position.y
		
		if x_distance < fall_trigger_distance and player_is_below:
			player_detected = true
			_start_falling_sequence()
	
	# PHASE 1: Delay phase - subtle pulsing effect
	if is_delaying:
		delay_timer += delta
		
		# Create subtle pulsing effect during delay
		var pulse = (sin(delay_timer * 3) * 0.05) + 0.95
		scale = Vector2(pulse, pulse)
		
		# When delay time is up, transition to warning phase
		if delay_timer >= trigger_delay:
			if debug_mode:
				print("Spike %s: Delay complete, starting warning" % spike_id)
			is_delaying = false
			is_warning = true
			warning_timer = 0.0
			modulate = Color(1, 0.5, 0.5)  # Reddish warning color
			scale = Vector2(1, 1)  # Reset scale
	
	# PHASE 2: Warning phase - shaking effect
	if is_warning:
		warning_timer += delta
		
		# Create side-to-side shaking effect
		position.x = original_position.x + sin(warning_timer * 30) * 2
		
		# When warning time is up, transition to falling phase
		if warning_timer >= warning_time:
			if debug_mode:
				print("Spike %s: Warning complete, starting fall" % spike_id)
			is_warning = false
			is_falling = true
			modulate = Color(1, 1, 1)  # Reset color
			position.x = original_position.x  # Reset position
	
	# PHASE 3: Falling phase - accelerating downward
	if is_falling:
		# Apply vertical movement
		position.y += fall_speed * delta
		
		# Increase falling speed over time for acceleration
		fall_speed += fall_gravity * delta
		
		# Safety check - if fallen too far, force reset
		if position.y > original_position.y + 2000:
			if debug_mode:
				print("Spike %s: Fallen too far, forcing reset" % spike_id)
			_start_reset_process()
	
	# PHASE 4: Rising phase - moving back to original position
	if is_rising:
		# Move spike back to original position
		var rise_speed = 300.0
		var distance_to_original = original_position.y - position.y
		var direction = sign(distance_to_original)
		
		# Slow down when getting close to the original position
		if abs(distance_to_original) < 20:
			rise_speed = 100.0
		
		position.y += direction * rise_speed * delta
		
		# Check if we've reached the original position
		if abs(position.y - original_position.y) < 2:
			position = original_position  # Snap to exact position
			is_rising = false
			
			# If player is still detected, start falling again after delay
			if player_detected:
				var respawn_timer = get_tree().create_timer(respawn_delay)
				respawn_timer.timeout.connect(_on_respawn_timer_timeout)
				
				if debug_mode:
					print("Spike %s: Player still detected, will fall again in %s seconds" % [spike_id, respawn_delay])
			else:
				if debug_mode:
					print("Spike %s: Reset complete, waiting for player" % spike_id)

func _on_body_entered(body):
	# Skip if already hit something or resetting
	if has_hit or is_resetting:
		return
	
	# Player collision
	if body == player or body.name == "Player" or body.is_in_group("player"):
		if debug_mode:
			print("Spike %s: Player hit by spike" % spike_id)
		
		# Calculate knockback direction
		var knockback_dir = sign(body.position.x - position.x)
		
		# Damage player if it has that method
		if body.has_method("take_damage"):
			body.take_damage(knockback_dir)
		
		# Respawn player if it has that method
		if body.has_method("respawn"):
			body.respawn()
		
		# Mark as hit and start reset process
		if is_falling_spike:
			has_hit = true
			is_falling = false
			_start_reset_process()
	
	# Enemy collision
	elif body.is_in_group("enemy") and body.has_method("take_damage"):
		var hit_dir = sign(body.position.x - position.x)
		
		# Kill enemy instantly
		body.take_damage(10000, hit_dir)
		
		# Mark as hit and start reset process
		if is_falling_spike:
			has_hit = true
			is_falling = false
			_start_reset_process()
	
	# Ground/wall collision
	elif body is StaticBody2D or body.is_in_group("ground") or body.is_in_group("platform"):
		if is_falling_spike and is_falling:  # Only trigger if we're actually falling
			has_hit = true
			is_falling = false
			
			# Create dust effect on impact
			_create_impact_effect()
			
			# Start reset process
			_start_reset_process()

# Start the reset process
func _start_reset_process():
	if debug_mode:
		print("Spike %s: Starting reset process" % spike_id)
	
	# Reset fall speed right away for next fall
	fall_speed = 300.0
	
	# Start reset timer
	is_resetting = true
	var timer = get_tree().create_timer(reset_time)
	timer.timeout.connect(_on_reset_timer_timeout)

# Create a simple impact effect
func _create_impact_effect():
	# Flash effect
	modulate = Color(1.2, 1.2, 1.2)  # Briefly brighten
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.2)

# Called when reset timer completes
func _on_reset_timer_timeout():
	if debug_mode:
		print("Spike %s: Reset timer completed, starting rise" % spike_id)
	
	# Reset states for rising
	is_resetting = false
	has_hit = false
	is_falling = false
	is_warning = false
	is_delaying = false
	
	# Start rising back to original position
	is_rising = true
	
	# Fade effect when starting to rise
	modulate = Color(0.7, 0.7, 0.7)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.5)

# Called when respawn timer completes
func _on_respawn_timer_timeout():
	if debug_mode:
		print("Spike %s: Respawn timer completed" % spike_id)
	
	# Only start a new falling sequence if we're not already in one
	# and the player is still detected
	if not is_falling and not is_warning and not is_delaying and not is_rising and not is_resetting and not has_hit:
		if player_detected:
			_start_falling_sequence()
		else:
			# Double-check player position directly
			if player:
				var x_distance = abs(player.global_position.x - global_position.x)
				var player_is_below = player.global_position.y > global_position.y
				
				if x_distance < fall_trigger_distance and player_is_below:
					player_detected = true
					_start_falling_sequence()

# Draw debug visuals
func _draw():
	if debug_mode and is_falling_spike:
		# Draw detection zone
		draw_rect(Rect2(-fall_trigger_distance, 0, fall_trigger_distance * 2, 500), 
				 Color(1.0, 0.0, 0.0, 0.2))
		
		# Show player detection status
		if player_detected:
			draw_circle(Vector2(0, 0), 5, Color.GREEN)
		else:
			draw_circle(Vector2(0, 0), 5, Color.RED)
		
		# Show spike's state
		var state_text = "Unknown"
		if is_falling:
			state_text = "Falling"
		elif is_warning:
			state_text = "Warning"
		elif is_delaying:
			state_text = "Delaying"
		elif is_rising:
			state_text = "Rising"
		elif is_resetting:
			state_text = "Resetting"
		elif has_hit:
			state_text = "Hit"
		else:
			state_text = "Ready"
			
		# Debug text not shown in-game currently, just here for reference
