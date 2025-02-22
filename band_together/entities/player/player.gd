extends CharacterBody2D

#region Camera
@export var left_limit: int = -10000000        # Camera left limit (px)
@export var right_limit: int = 10000000        # Camera right limit (px)
@export var top_limit: int = -10000000         # Camera top limit (px)
@export var bottom_limit: int = 10000000        # Camera bottom limit (px)
#endregion

#region Physics
@export var speed: float = 100.0               # Player's movespeed
@export var jump_velocity: float = -300.0      # Player's jump velocity
@export var jump_buffer: float = 0.1            # Jump buffer
@export var coyote_time: float = 0.1             # Coyote time
var coyote_time_counter: float = 0               # Counts coyote time
var coyote_time_wall_counter: float = 0          # Counter specifically for walls
var jump_buffer_counter: float = 0               # Counts jump buffer
var double_jump_count: int = 0
var dash_mult: int = 1                         # Dash movespeed multiply
var grav_div: int                              # Divide gravity while charging dash
var moving_allowed: bool = true
#endregion

#region Dash bools
var is_charging: bool = false
var is_dashing: bool = false
#endregion

var direction: int = 0 

#region Wall Jump states
var attached_to_wall: bool = false
@export var wall_jump_force: int = 400        # Force of bouncing off wall
@export var wall_slide_speed: float = 800.0    # Speed of sliding down wall
#endregion

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D

var default_i_frame_timer: float = 1.3  # number of seconds to be invincible after being hit
@onready var i_frame_timer: float = default_i_frame_timer

func _ready():
	# Set the camera limits to those in the editor
	camera.set_limits(bottom_limit, top_limit, right_limit, left_limit)

func _physics_process(delta):
	check_input()  # Attacks, direction input, wall attaching
	gravity(delta)  # Slow fall, wall slide, jump buffer, coyote time is also in here!
	jump(delta)  # All types of jumps (wall jump, double jump, etc!)
	move_and_animate()  # Sets velocity based on input, changes sprites

func _process(delta):
	if i_frame_timer > 0:
		# Decrease i-frame timer every frame, preventing underflow
		i_frame_timer -= delta
	
	if UI.lives <= 0:
		pause_movement(3)  # This makes it so the player cannot walk around if they die (before game over screen)

func check_input() -> void:
	## When the player presses the drum button, it enables the drum's hitbox and sets a timer that keeps it active for 0.15 seconds	
	if Input.is_action_just_pressed("Drum"):
		$DrumArea/DrumAttack.disabled = false
		$DrumArea/DrumAttack/DrumTimer.start()
			
	## When the player presses the baton button, it enables the drum's hitbox and sets a timer that keeps it active for 0.15 seconds		
	if Input.is_action_just_pressed("Baton"):
		$BatonArea/BatonAtack.disabled = false
		$BatonArea/BatonAtack/BatonTimer.start()
	
	# Handle Dash - Will eventually be associated with the saxophones movement ability
	# Starts the charge up for the dash
	if Input.is_action_just_pressed("Dash"): 
		if !is_charging and !is_dashing: # prevents repeated dashing
			#Start charging up a dash, reduces fall speed
			grav_div = 2
			is_charging = true
			$DashChargeTimer.start()
	
	if moving_allowed:
		direction = Input.get_axis("Left", "Right")
	else:
		direction = 0
	
	# Wall attaching
	if is_on_wall_only() and direction == -get_wall_normal().x:
		attached_to_wall = true
	elif direction == get_wall_normal().x or Input.is_action_just_pressed("Down") or !is_on_wall():
		attached_to_wall = false

func gravity(delta) -> void:
	if is_on_floor():
		double_jump_count = 0  # Reset double jump
		attached_to_wall = false
		coyote_time_counter = coyote_time
	elif attached_to_wall:
		velocity.y = wall_slide_speed * delta  # Slow gravity when sliding on wall
		coyote_time_wall_counter = coyote_time
	elif not is_on_floor() and not attached_to_wall:
		velocity += get_gravity() * delta
		#if the player is falling, and is either charging their dash or dashing, slow their descent
		if velocity.y > 0 and (is_charging or is_dashing):
			velocity.y /= grav_div
	elif velocity.y > 0:
		coyote_time_counter -= delta
		coyote_time_wall_counter -= delta
		velocity += get_gravity() * delta * 1.5  # Faster falling (feels good)
	else:
		coyote_time_counter -= delta
		coyote_time_wall_counter -= delta
		velocity += get_gravity() * delta  # We are in the air, regular gravity

func jump(delta) -> void:
	if Input.is_action_just_pressed("Accept"):
		jump_buffer_counter = jump_buffer
	elif jump_buffer_counter > 0:
		# prevent underflow
		jump_buffer_counter -= delta
	## Regular Jump
	if (is_on_floor() or coyote_time_counter > 0) and jump_buffer_counter > 0:
		velocity.y = jump_velocity
		jump_buffer_counter = 0
		coyote_time_counter = 0
	
	## Wall Jump
	elif (attached_to_wall or coyote_time_wall_counter > 0) and jump_buffer_counter > 0:
		attached_to_wall = false
		velocity.x = wall_jump_force * get_wall_normal().x
		velocity.y = jump_velocity
		pause_movement(0.1)
		jump_buffer_counter = 0
		coyote_time_wall_counter = 0
			
	## Double Jump
	elif jump_buffer_counter > 0 and double_jump_count == 0:
		jump_buffer_counter = 0
		velocity.y = jump_velocity
		double_jump_count += 1
	
	# Otherwise, no jump is performed
		
	## Jump Cutting
	if Input.is_action_just_released("Accept") and velocity.y < -30:
		velocity.y = - 30

func move_and_animate() -> void:
	# only walk when there is a direction input and the player is not clinging to a wall
	if direction and not attached_to_wall:
		play_animation("walk")
		velocity.x = move_toward(velocity.x, direction * speed * dash_mult, speed) 
		# Flip the sprite based on direction
		if direction > 0:
			sprite.flip_h = false  # Face right
		elif direction < 0:
			sprite.flip_h = true # Face left
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		# play the idle animation if on floor
		if is_on_floor():
			play_animation("idle")
		else:
			# place wall slide animation here
			# place falling animation here
			# etc etc
			pass
			
	move_and_slide()

func play_animation(animation_name) -> void:
	if sprite.animation != animation_name:
		sprite.play(animation_name)

func take_damage(direction=null) -> void:
	# Direction should == -1 or 1 (direction to launch player when taking damage)
	if i_frame_timer <= 0:
		i_frame_timer = default_i_frame_timer
		UI.decrease_health()
		camera.apply_shake()
		
		# Hit freeze effect https://www.youtube.com/watch?v=44YpRF5FZDc
		Engine.time_scale = 0.1  
		await get_tree().create_timer(0.05, false).timeout
		Engine.time_scale = 1
		
		# ChatGPT helped me make a knockback!
		if direction != null:
			velocity.x = direction * 500
			velocity.y = -100
			pause_movement(0.2)

func pause_movement(howlong) -> void:
	# Briefly disable movement control (thanks chatgpt <3)
	moving_allowed = false
	await get_tree().create_timer(howlong, false).timeout
	moving_allowed = true

func _on_dash_charge_timer_timeout() -> void:
	#start the dash, increase the speed of the player
	dash_mult = 2
	is_charging = false
	is_dashing = true
	$DashExecuteTimer.start()
	
func _on_dash_execute_timer_timeout() -> void:
	#dash over, return to normal movement and fall speeds
	dash_mult = 1
	grav_div = 1
	is_dashing = false

func _on_win_area_body_entered(_body: Node2D) -> void:
	print("You Win!\n")
	SceneTransition.change_scene("res://scenes/states/win/win.tscn")

#Re-disables the attack hitbox after the agreed upon duration
func _on_drum_timer_timeout() -> void:
	$DrumArea/DrumAttack.disabled = true

#Re-disables the attack hitbox after the agreed upon duration
func _on_baton_timer_timeout() -> void:
	$BatonArea/BatonAtack.disabled = true 

##Consequence for enemies hitting the attack hitbox
#Currently, as there is no health system for enemies, this rotates them :D
func _on_drum_area_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		body.rotate(1)

##Consequence for enemies hitting the attack hitbox
#Currently, as there is no health system for enemies, this rotates them :D
func _on_baton_area_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		body.rotate(1)
