extends CharacterBody2D

# Constant for gravity - defines how quickly the bear falls
const GRAVITY_ACCELERATION = 980.0

# Bear movement and behavior configuration
# --------------------------------------
# Initial movement direction (-1 = left, 1 = right)
@export var direction: int = -1
# Normal walking speed when patrolling
@export var speed: float = 40.0
# Increased speed when actively chasing the player
@export var chase_speed: float = 55.0
# Maximum distance at which bear can detect and chase player
@export var chase_distance: float = 150.0
# Close distance at which bear switches to attack mode
@export var attack_distance: float = 50.0
# Bear's health points - how much damage it can take before dying
@export var hp: float = 60.0
# Whether the bear should stop at platform edges
@export var avoid_falls: bool = true

# Node references for easy access
# --------------------------------------
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast: RayCast2D = $RayCast2D  # Used for edge detection
@onready var hitbox: Area2D = $Hitbox         # Used for attacking the player

# State tracking variables
# --------------------------------------
var player = null                 # Reference to the player character
var stopped: bool = false         # Whether bear is in idle state during patrol
var knocked_back: bool = false    # Whether bear is currently in knockback state
var spinning: bool = false        # Used during death animation
var is_chasing: bool = false      # Whether bear is actively chasing player
var is_attacking: bool = false    # Whether bear is in attack mode
var debug_tick: int = 0           # Counter used for periodic debug operations

func _ready():
	# Setup required timers for bear behavior
	# --------------------------------------
	
	# Timer for random stopping during patrol
	if not has_node("StopMoving"):
		var timer = Timer.new()
		timer.name = "StopMoving"
		timer.wait_time = randf_range(2.5, 4)  # Random initial patrol time
		add_child(timer)
		timer.timeout.connect(_on_stop_moving_timeout)
		timer.start()
	
	# Timer for knockback recovery
	if not has_node("KnockbackTimer"):
		var timer = Timer.new()
		timer.name = "KnockbackTimer"
		timer.one_shot = true     # Only fires once when started
		add_child(timer)
		timer.timeout.connect(_on_knockback_timer_timeout)
	
	# Timer for death sequence duration
	if not has_node("DeathTimer"):
		var timer = Timer.new()
		timer.name = "DeathTimer"
		timer.wait_time = 2.0     # Time before removing bear after death
		timer.one_shot = true
		add_child(timer)
		timer.timeout.connect(_on_death_timer_timeout)
	
	# Create edge detection raycast if it doesn't exist
	# --------------------------------------
	if not raycast:
		raycast = RayCast2D.new()
		raycast.name = "RayCast2D"
		raycast.position = Vector2(15, 0)       # Position in front of bear
		raycast.target_position = Vector2(0, 20) # Points downward to detect floor edges
		raycast.enabled = true
		add_child(raycast)
	
	# Initialize animation
	sprite.play("walk")
	
	# Set up initial direction and orientation
	if direction > 0:  # If starting direction is right
		sprite.flip_h = !sprite.flip_h  # Flip sprite horizontally
		raycast.position.x *= -1        # Mirror raycast position
	
	# Find the player object in the scene
	_find_player()
	
	# Register this bear as an enemy for group-based targeting
	add_to_group("enemy")

# Attempts to locate the player character in the scene
# Called periodically to ensure bear can find player
# --------------------------------------
func _find_player():
	# First check if player is in the "player" group
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		print("Found player in group: ", player)
		return
	
	# If not found by group, try a direct path
	player = get_node_or_null("/root/Level/Player")
	if player:
		print("Found player by path: ", player)
		return
	
	print("Failed to find player!")

# Main physics update - handles movement and state changes
# --------------------------------------
func _physics_process(delta):
	# Periodically check if we need to find the player
	debug_tick += 1
	if debug_tick >= 60:  # Every ~1 second at 60fps
		debug_tick = 0
		if not player:
			_find_player()
	
	# Apply gravity when not on floor
	if not is_on_floor():
		velocity.y += GRAVITY_ACCELERATION * delta
	
	# If being knocked back, don't apply normal movement logic
	if knocked_back:
		move_and_slide()
		return
	
	# Player detection and state determination
	# --------------------------------------
	var should_chase = false
	var should_attack = false
	
	if player:
		var distance = global_position.distance_to(player.global_position)
		
		# Player is very close - enter attack mode
		if distance < attack_distance:
			should_attack = true
			should_chase = false
			direction = sign(player.global_position.x - global_position.x)
			sprite.flip_h = (direction > 0)
		
		# Player is within chase range but not attack range
		elif distance < chase_distance:
			should_chase = true
			should_attack = false
			direction = sign(player.global_position.x - global_position.x)
			sprite.flip_h = (direction > 0)
			
			# Update raycast direction to match movement direction
			if raycast:
				if (direction > 0 and raycast.position.x < 0) or (direction < 0 and raycast.position.x > 0):
					raycast.position.x *= -1
	
	# Edge detection to prevent falling off platforms
	# --------------------------------------
	var will_fall = false
	if avoid_falls and raycast and is_on_floor():
		will_fall = not raycast.is_colliding()
		
		# Stop at platform edge when chasing or attacking
		if will_fall and (should_chase or should_attack):
			velocity.x = 0
			sprite.play("idle")  # Look like it's thinking about what to do
			move_and_slide()
			return
	
	# State-based movement behavior
	# --------------------------------------
	
	# Attack state - very close to player
	if should_attack:
		is_attacking = true
		is_chasing = false
		
		# Don't walk off edges
		if will_fall:
			velocity.x = 0
		else:
			# Use idle animation when preparing to attack
			sprite.play("idle")
			# Slow approach toward player
			velocity.x = direction * speed * 0.3
	
	# Chase state - player is in sight but not close enough to attack
	elif should_chase:
		is_chasing = true
		is_attacking = false
		
		# Don't walk off edges
		if will_fall:
			velocity.x = 0
			sprite.play("idle")
		else:
			# Use walk animation during chase
			sprite.play("walk")
			velocity.x = direction * chase_speed
	
	# Stopped state - random pauses during patrol
	elif stopped:
		is_chasing = false
		is_attacking = false
		sprite.play("idle")
		velocity.x = 0
	
	# Normal patrol state - default behavior
	else:
		is_chasing = false
		is_attacking = false
		
		# Check for obstacles or edges during patrol
		if raycast and ((not raycast.is_colliding() and is_on_floor()) or is_on_wall()):
			flip()  # Turn around when hitting wall or reaching edge
		
		sprite.play("walk")
		velocity.x = direction * speed
	
	# Apply the calculated movement
	move_and_slide()
	
	# Check if we directly collided with player during movement
	# --------------------------------------
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider and (collider.name == "Player" or collider.is_in_group("player")):
			if collider.has_method("take_damage"):
				# Direction for knockback is based on relative positions
				collider.take_damage(sign(collider.global_position.x - global_position.x))

# Changes the bear's direction and flips visuals accordingly
# --------------------------------------
func flip():
	direction = -direction  # Reverse direction
	sprite.flip_h = !sprite.flip_h  # Flip sprite horizontally
	if raycast:
		raycast.position.x *= -1  # Mirror raycast position

# Called when player attacks the bear
# --------------------------------------
func take_damage(amount, knockback_dir):
	# Play hit flash animation if available
	if has_node("AnimatedSprite2D/HitFlash"):
		$AnimatedSprite2D/HitFlash.play("flash")
	
	hp -= amount  # Reduce health
	
	if hp <= 0:
		# Bear has died
		die(knockback_dir)
	else:
		# Apply knockback effect
		knocked_back = true
		velocity.x = knockback_dir * 150  # Horizontal knockback
		velocity.y = -120  # Small upward bounce
		$KnockbackTimer.start(0.2)  # Short knockback duration

# Handles bear death sequence
# --------------------------------------
func die(knockback_dir):
	# Disable collisions with world and player
	set_collision_layer_value(4, false)
	set_collision_mask_value(3, false)
	
	# Disable hitbox if it exists
	if hitbox:
		hitbox.set_collision_layer_value(5, false)
		hitbox.set_collision_mask_value(2, false)
	
	# Apply death knockback
	knocked_back = true
	velocity = Vector2(knockback_dir * 300, -200)  # Stronger knockback on death
	
	# Start spinning animation
	spinning = true
	$DeathTimer.start()

# Called when hitbox overlaps with player's body
# --------------------------------------
func _on_hitbox_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		if body.has_method("take_damage"):
			# Attack the player
			body.take_damage(sign(body.position.x - position.x))
		
		# If we hit player during normal patrol, turn around
		if not is_chasing and not is_attacking:
			flip()

# Timer callback for the patrol stop/start cycle
# --------------------------------------
func _on_stop_moving_timeout():
	# Only change state if not already chasing or attacking
	if not is_chasing and not is_attacking:
		stopped = !stopped  # Toggle between stopped and moving
		
		# Set appropriate wait time for next state change
		$StopMoving.wait_time = randf_range(0.5, 1.5) if stopped else randf_range(2.5, 4)
		$StopMoving.start()

# Timer callback for ending knockback state
# --------------------------------------
func _on_knockback_timer_timeout():
	knocked_back = false  # Return to normal movement

# Timer callback for removing bear after death
# --------------------------------------
func _on_death_timer_timeout():
	queue_free()  # Remove bear from scene

# Called every frame for animations and visual effects
# --------------------------------------
func _process(delta):
	# Handle spinning death animation
	if spinning:
		rotation_degrees += 360 * delta * 2  # Spin at 2 full rotations per second
