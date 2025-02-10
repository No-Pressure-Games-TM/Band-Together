extends CharacterBody2D

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

func _physics_process(delta):

	##When the player presses the drum button, it enables the drum's hitbox and sets a timer that keeps it active for 0.15 seconds	
	if Input.is_action_just_pressed("Drum"):
		$DrumArea/DrumAttack.disabled = false
		$DrumArea/DrumAttack/DrumTimer.start()
		
			
	##When the player presses the baton button, it enables the drum's hitbox and sets a timer that keeps it active for 0.15 seconds		
	if Input.is_action_just_pressed("Baton"):
		$BatonArea/BatonAtack.disabled = false
		$BatonArea/BatonAtack/BatonTimer.start()

	direction = Input.get_axis("Left", "Right")
	wall_attach(direction)
	gravity(delta)  # Wall slide, jump buffer, coyote time is also in here!
	## I commented this out for now. Will add it back in when I am done organizing - jon
	#if not is_on_floor() and not attached_to_wall:
		#velocity += get_gravity() * delta
		##if the player is falling, and is either charging their dash or dashing, slow their descent
		#if velocity.y > 0 and (is_charging or is_dashing):
			#velocity.y /= grav_div
	jump(delta)
	
		
	# Handle Dash - Will eventually be associated with the saxophones movement ability
	# Starts the charge up for the dash
	if Input.is_action_just_pressed("Dash"): 
		if !is_charging and !is_dashing: # prevents repeated dashing
			#Start charging up a dash, reduces fall speed
			grav_div = 2
			is_charging = true
			$DashChargeTimer.start()
			
	#only walk when there is a direction input and the player is not clinging to a wall
	if direction and not attached_to_wall:
		if sprite.animation != "walk":
			sprite.play("walk")  # Play the running animation
		velocity.x = move_toward(velocity.x, direction * speed * dash_mult, speed) 
		# Flip the sprite based on direction
		if direction > 0:
			sprite.flip_h = false  # Face right
		elif direction < 0:
			sprite.flip_h = true # Face left
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
		# play the idle animation if not already playing
		if sprite.animation != "idle" and is_on_floor():
			sprite.play("idle")
		
	move_and_slide()


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

func gravity(delta) -> void:
	if is_on_floor():
		double_jump_count = 0  # Reset double jump
		attached_to_wall = false
		coyote_time_counter = coyote_time
	elif attached_to_wall:
		velocity.y = wall_slide_speed * delta  # Slow gravity when sliding on wall
		coyote_time_wall_counter = coyote_time
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
	else:
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

func wall_attach(direction) -> void:
	if is_on_wall_only() and direction == -get_wall_normal().x:
		attached_to_wall = true
	elif direction == get_wall_normal().x or Input.is_action_just_pressed("Down") or !is_on_wall():
		attached_to_wall = false

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
