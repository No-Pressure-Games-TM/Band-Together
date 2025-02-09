extends CharacterBody2D

#region Physics
const SPEED: float = 100.0
const JUMP_VELOCITY: float = -300.0
var double_jump_count: int = 0

var DASH_MULT = 1
var GRAV_DIV = 1
#region

#region Dash bools
var is_charging = false
var is_dashing = false
#region

var direction = 0 

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
		#if the player is falling, and is either charging their dash or dashing, slow their descent
		if velocity.y > 0 and (is_charging or is_dashing):
			velocity.y /= GRAV_DIV
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
		
	# Handle Dash - Will eventually be associated with the saxophones movement ability
	# Starts the charge up for the dash
	if Input.is_action_just_pressed("Dash"): 
		if !is_charging and !is_dashing: # prevents repeated dashing
			#Start charging up a dash, reduces fall speed
			GRAV_DIV = 2
			is_charging = true
			$DashChargeTimer.start()
		
	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_axis("Left", "Right")
	#only walk when there is a direction input and the player is not clinging to a wall
	if direction and not attached_to_wall:
		if sprite.animation != "walk":
			sprite.play("walk")  # Play the running animation
		velocity.x = direction * SPEED * DASH_MULT
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
	
	


func _on_dash_charge_timer_timeout() -> void:
	#start the dash, increase the speed of the player
	DASH_MULT = 2
	is_charging = false
	is_dashing = true
	$DashExecuteTimer.start()
	
func _on_dash_execute_timer_timeout() -> void:
	#dash over, return to normal movement and fall speeds
	DASH_MULT = 1
	GRAV_DIV = 1
	is_dashing = false
