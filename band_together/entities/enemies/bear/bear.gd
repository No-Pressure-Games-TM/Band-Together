extends CharacterBody2D

# Constant for gravity - defines how quickly the bear falls
const GRAVITY_ACCELERATION = 980.0

# Bear movement and behavior configuration
# --------------------------------------
@export var direction: int = -1									# Initial movement direction (-1 = left, 1 = right)
@export var speed: float = 40.0									# Normal walking speed when patrolling
@export var chase_speed: float = 75.0							# Increased speed when actively chasing the player
@export var chase_distance: float = 150.0						# Maximum distance at which bear can detect and chase player
@export var attack_distance: float = 60.0						# Close distance at which bear switches to attack mode
@export var hp: float = 60.0										# Bear's health points - how much damage it can take before dying
@export var avoid_falls: bool = true								# Whether the bear should stop at platform edges
@export var idle_telegraph_duration: float = 1.2					# How long to play the idle animation telegraph (seconds)

# Node references for easy access
# --------------------------------------
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast: RayCast2D = $RayCast2D						# Used for edge detection
@onready var hitbox: Area2D = $Hitbox         					# Used for attacking the player

# State tracking variables
# --------------------------------------
var player = null                 								# Reference to the player character
var stopped: bool = false         								# Whether bear is in idle state during patrol
var knocked_back: bool = false    								# Whether bear is currently in knockback state
var spinning: bool = false        								# Used during death animation
var is_chasing: bool = false      								# Whether bear is actively chasing player
var is_attacking: bool = false    								# Whether bear is in attack mode
var has_telegraphed: bool = false 								# Whether bear has ever played the telegraph
var is_telegraphing: bool = false 								# Whether bear is currently telegraphing
var telegraph_timer: float = 0.0  								# Timer for current telegraph animation

func _ready():
	# Setup required timers for bear behavior
	# --------------------------------------
	# Timer for random stopping during patrol
	if not has_node("StopMoving"):
		var timer = Timer.new()
		timer.name = "StopMoving"
		timer.wait_time = randf_range(2.5, 4)
		add_child(timer)
		timer.timeout.connect(_on_stop_moving_timeout)
		timer.start()
	
	# Timer for knockback recovery
	if not has_node("KnockbackTimer"):
		var timer = Timer.new()
		timer.name = "KnockbackTimer"
		timer.one_shot = true
		timer.wait_time = 0.7
		add_child(timer)
		timer.timeout.connect(_on_knockback_timer_timeout)
	
	# Timer for death sequence
	if not has_node("DeathTimer"):
		var timer = Timer.new()
		timer.name = "DeathTimer"
		timer.wait_time = 2.0
		timer.one_shot = true
		add_child(timer)
		timer.timeout.connect(_on_death_timer_timeout)
	
	# Create edge detection raycast if needed
	if not raycast:
		raycast = RayCast2D.new()
		raycast.name = "RayCast2D"
		raycast.position = Vector2(15, 0)
		raycast.target_position = Vector2(0, 20)
		raycast.enabled = true
		add_child(raycast)
	
	# Initialize animation
	sprite.play("walk")
	
	# Set up initial direction
	if direction > 0:
		sprite.flip_h = !sprite.flip_h
		raycast.position.x *= -1
	
	# Find the player
	_find_player()
	
	# Register as enemy
	add_to_group("enemy")

# Find the player in the scene
func _find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		return
	
	# Try common paths as fallback
	var paths = ["/root/Level/Player", "/root/Main/Player", "../../Player"]
	for path in paths:
		player = get_node_or_null(path)
		if player:
			return

# Main physics update
func _physics_process(delta):
	# Try to find player if not found yet
	if not player and Engine.get_frames_drawn() % 60 == 0:
		_find_player()
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY_ACCELERATION * delta
	
	# Skip normal logic if knocked back
	if knocked_back:
		move_and_slide()
		return
	
	# Handle player detection
	var should_chase = false
	var should_attack = false
	
	if player:
		var distance = global_position.distance_to(player.global_position)
		
		# Update direction to face player
		if distance < chase_distance:
			direction = sign(player.global_position.x - global_position.x)
			sprite.flip_h = (direction > 0)
			
			# Update raycast direction
			if raycast and ((direction > 0 and raycast.position.x < 0) or 
						   (direction < 0 and raycast.position.x > 0)):
				raycast.position.x *= -1
			
			# Determine state based on distance
			if distance < attack_distance:
				should_attack = true
			else:
				should_chase = true
	
	# Check for edges
	var will_fall = false
	if avoid_falls and raycast and is_on_floor():
		will_fall = not raycast.is_colliding()
		
		# Stop at edges when chasing or attacking
		if will_fall and (should_chase or should_attack):
			velocity.x = 0
			sprite.play("idle")
			move_and_slide()
			return
	
	# Handle movement based on state
	if should_attack:
		is_attacking = true
		is_chasing = false
		
		if will_fall:
			velocity.x = 0
		else:
			# If bear hasn't telegraphed yet
			if not has_telegraphed and not is_telegraphing:
				# Start telegraph
				is_telegraphing = true
				telegraph_timer = 0.0
				sprite.play("idle")
				sprite.speed_scale = 0.4  # Slow motion
				velocity.x = direction * speed * 0.1  # Very slow movement
			
			# During telegraph animation
			elif is_telegraphing:
				telegraph_timer += delta
				velocity.x = direction * speed * 0.1  # Very slow
				
				# Check if telegraph is complete
				if telegraph_timer >= idle_telegraph_duration:
					is_telegraphing = false
					has_telegraphed = true  # Never telegraph again
			
			# Normal attack - already telegraphed once
			else:
				sprite.play("walk")
				sprite.speed_scale = 1.0
				velocity.x = direction * speed * 1.2  # Faster charge
	
	# Chase state
	elif should_chase:
		is_attacking = false
		is_chasing = true
		is_telegraphing = false
		
		if will_fall:
			velocity.x = 0
			sprite.play("idle")
		else:
			sprite.play("walk")
			sprite.speed_scale = 1.0
			velocity.x = direction * chase_speed
	
	# Idle/stopped state
	elif stopped:
		is_attacking = false
		is_chasing = false
		sprite.play("idle")
		sprite.speed_scale = 1.0
		velocity.x = 0
	
	# Normal patrol state
	else:
		is_attacking = false
		is_chasing = false
		is_telegraphing = false
		
		# Check for edges or walls during patrol
		if raycast and ((not raycast.is_colliding() and is_on_floor()) or is_on_wall()):
			flip()
		
		sprite.play("walk")
		sprite.speed_scale = 1.0
		velocity.x = direction * speed
	
	# Apply movement
	move_and_slide()
	
	# Check for collisions with player
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider and (collider.name == "Player" or collider.is_in_group("player")):
			if collider.has_method("take_damage"):
				collider.take_damage(sign(collider.global_position.x - position.x))

# Flip direction
func flip():
	direction = -direction
	sprite.flip_h = !sprite.flip_h
	if raycast:
		raycast.position.x *= -1

# Handle damage
func take_damage(amount, knockback_dir):
	if has_node("AnimatedSprite2D/HitFlash"):
		$AnimatedSprite2D/HitFlash.play("flash")
	
	# Reset telegraph state if in progress
	is_telegraphing = false
	
	hp -= amount
	
	if hp <= 0:
		die(knockback_dir)
	else:
		knocked_back = true
		velocity.x = knockback_dir * 150
		velocity.y = -120
		$KnockbackTimer.start()

# Handle death
func die(knockback_dir):
	# Disable collisions
	set_collision_layer_value(4, false)
	set_collision_mask_value(3, false)
	
	if hitbox:
		hitbox.set_collision_layer_value(5, false)
		hitbox.set_collision_mask_value(2, false)
	
	knocked_back = true
	velocity = Vector2(knockback_dir * 300, -200)
	spinning = true
	$DeathTimer.start()

# Handle hitbox collision
func _on_hitbox_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(sign(body.position.x - position.x))
		
		if not is_chasing and not is_attacking:
			flip()

# Timer callbacks
func _on_stop_moving_timeout():
	if not is_chasing and not is_attacking:
		stopped = !stopped
		$StopMoving.wait_time = randf_range(0.5, 1.5) if stopped else randf_range(2.5, 4)
		$StopMoving.start()

func _on_knockback_timer_timeout():
	knocked_back = false

func _on_death_timer_timeout():
	queue_free()

func _process(delta):
	# Death spinning animation
	if spinning:
		rotation_degrees += 360 * delta * 2
