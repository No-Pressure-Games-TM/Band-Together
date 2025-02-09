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


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

## Use double hashtags for a "title comment", it looks a lil different!
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		#if the player is falling, and is either charging their dash or dashing, slow their descent
		if velocity.y > 0 and (is_charging or is_dashing):
			velocity.y /= GRAV_DIV
	else:
		double_jump_count = 0

	# Handle jump.
	if Input.is_action_just_pressed("Accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif double_jump_count == 0:
			velocity.y = JUMP_VELOCITY
			double_jump_count += 1
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
	if direction:
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
	print("dashing")
	


func _on_dash_execute_timer_timeout() -> void:
	#dash over, return to normal movement and fall speeds
	DASH_MULT = 1
	GRAV_DIV = 1
	is_dashing = false
	print("dash over")
	
	
	
	
	
