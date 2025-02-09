extends CharacterBody2D

#region Physics
const SPEED: float = 100.0
const JUMP_VELOCITY: float = -300.0
var double_jump_count: int = 0
#region

#region Walljump info
var attached_to_wall = false
var current_wall = 1
var recent_wall = 0
#region

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

## Use double hashtags for a "title comment", it looks a lil different!
func _physics_process(delta):
	# Add the gravity, whenever the player is both not on the ground or clinging to a wall
	if not is_on_floor() and not attached_to_wall:
		velocity += get_gravity() * delta
	# Reset double and wall jumps when the player hits the ground
	elif is_on_floor():
		double_jump_count = 0
		


	#Handle down, so far only used if the player wants to detach from a wall
	if Input.is_action_just_pressed("Down") and attached_to_wall:
		attached_to_wall = false
		recent_wall = current_wall
		current_wall = null

	# Handle jump.
	if Input.is_action_just_pressed("Accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			recent_wall = null
		
		#if clinging to a wall
		elif attached_to_wall:
			velocity.y = JUMP_VELOCITY
			attached_to_wall = false
			recent_wall = current_wall
			current_wall = null
		
		#if going to cling to a wall
		elif is_on_wall():
			current_wall = int(position.x)
			if recent_wall != current_wall:
				velocity.y = 0
				attached_to_wall = true
				
		#if going to use a double jump
		elif double_jump_count == 0:
			velocity.y = JUMP_VELOCITY
			double_jump_count += 1
			
		#(all other cases, no jump is performed)
		
	if Input.is_action_just_released("Accept") and velocity.y < -60:
		velocity.y = - 60

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("Left", "Right")
	#only walk when there is a direction input and the player is not clinging to a wall
	if direction and not attached_to_wall:
		if sprite.animation != "walk":
			sprite.play("walk")  # Play the running animation
		velocity.x = direction * SPEED
		# Flip the sprite based on direction
		if direction > 0:
			sprite.flip_h = false  # Face right
		elif direction < 0:
			sprite.flip_h = true # Face left
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
		# play the idle animation if not already playing
		if sprite.animation != "idle" and is_on_floor():
			sprite.play("idle")
		
	move_and_slide()
