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
var knocked: bool = false
var no_doublejump_zone: bool = false           # set by the mushroom, so no double jump when trying to bounce
#endregion

#region Dash bools
var is_charging: bool = false
var is_dashing: bool = false
#endregion

var direction: int = 0 

#region combat
var damage: int = 15
var weapon_cooling_down: bool = false
@onready var crit_label = $CritText
@onready var current_instrument: String = GameManager.get_current_instrument()
#endregion

#region Wall Jump states
var attached_to_wall: bool = false
@export var wall_jump_force: int = 400        # Force of bouncing off wall
@export var wall_slide_speed: float = 800.0    # Speed of sliding down wall
#endregion

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var smear: AnimatedSprite2D = $AnimatedSprite2D/SwordSmear
@onready var drum_wave: Sprite2D = $AnimatedSprite2D/DrumWave
@onready var camera: Camera2D = $Camera2D
var attack_animation: bool = false

var default_i_frame_timer: float = 1.3  # number of seconds to be invincible after being hit
@onready var i_frame_timer: float = default_i_frame_timer

func _ready():
	# Set the camera limits to those in the editor
	camera.set_limits(bottom_limit, top_limit, right_limit, left_limit)
	sprite.play("idle")  # This fixes the "Frozen sprite at start" bug
	crit_label.visible = false
	$BeachMarimba.play()
	$BeachDrum.play()
	$BeachSax.play()
	$BeachString.play()
	$BeachMarimba.volume_db = 0
	if GameManager.drum_unlocked:
		$BeachDrum.volume_db = 0
		


func _physics_process(delta):
	if GameManager.drum_unlocked:
		$BeachDrum.volume_db = 0
		
	if GameManager.violin_unlocked:
		$BeachString.volume_db = 0
		
	if GameManager.sax_unlocked:
		$BeachSax.volume_db = 0
		
	
	check_input()  # Attacks, direction input, wall attaching
	gravity(delta)  # Slow fall, wall slide, jump buffer, coyote time is also in here!
	jump(delta)  # All types of jumps (wall jump, double jump, etc!)
	move_and_animate()  # Sets velocity based on input, changes sprites
	
	if is_on_floor():
		GameManager.save_ground_position(global_position)  # Store last ground position

	if global_position.y > 1000:  # TODO: Refractor to calculate WorldBoundary. If the player falls out of the world boundary, respawn
		respawn()

func _process(delta):
	if i_frame_timer > 0:
		# Decrease i-frame timer every frame, preventing underflow
		i_frame_timer -= delta
	
	if UI.lives <= 0:
		pause_movement(3)  # This makes it so the player cannot walk around if they die (before game over screen)

func respawn() -> void:
	global_position = GameManager.get_last_ground_position()  # Retrieve last safe position
	
func adjust_volumes() -> void:
	if GameManager.get_current_instrument() == "drum":
		$BeachDrum.volume_db = 5
		$BeachMarimba.volume_db = 0
	
	if GameManager.get_current_instrument() == "baton":
		if GameManager.drum_unlocked:
			$BeachDrum.volume_db = 0
		$BeachMarimba.volume_db = 5
func check_input() -> void:
	if Input.is_action_just_pressed("CycleL"):
		GameManager.set_current_instrument(-1)
		print_debug("Set instrument to " + GameManager.get_current_instrument())
		adjust_volumes()
	
	if Input.is_action_just_pressed("CycleR"):
		GameManager.set_current_instrument(1)
		print_debug("Set instrument to " + GameManager.get_current_instrument())
		adjust_volumes()
			
	## When the player presses the action button, it enables the current weapon's hitbox and sets a timer that keeps it active for 0.15 seconds		
	if Input.is_action_just_pressed("Decline") and !weapon_cooling_down:
		use_attack(GameManager.get_current_instrument())
	
	# Handle Dash - Will eventually be associated with the saxophones movement ability
	# Starts the charge up for the dash
	if Input.is_action_just_pressed("Dash"): 
		if !is_charging and !is_dashing: # prevents repeated dashing
			#Start charging up a dash, reduces fall speed
			grav_div = 2
			is_charging = true
			$DashChargeTimer.start()
			$SaxCharge.play()
	
	if moving_allowed:
		direction = sign(round(Input.get_vector("Left", "Right", "Up", "Down")).normalized().x)
	else:
		direction = 0
	
	# Wall attaching
	if is_on_wall_only() and direction == -get_wall_normal().x:
		attached_to_wall = true
	elif direction == get_wall_normal().x or Input.is_action_just_pressed("Down") or !is_on_wall():
		attached_to_wall = false

func gravity(delta) -> void:
	if knocked:
		velocity.y = 0
		return  # NO GRAVITY WHEN KNOCKED
	if is_on_floor():
		double_jump_count = 0  # Reset double jump
		attached_to_wall = false
		coyote_time_counter = coyote_time
		coyote_time_wall_counter = 0  # Fix triple jump bug
	elif attached_to_wall and GameManager.violin_unlocked:
		double_jump_count = 0  # Allow wall double jumps
		velocity.y = wall_slide_speed * delta  # Slow gravity when sliding on wall
		coyote_time_wall_counter = coyote_time
	elif not is_on_floor() and not attached_to_wall:
		if coyote_time_counter > 0 or coyote_time_wall_counter > 0:
			# Prevent underflow
			coyote_time_counter -= delta
			coyote_time_wall_counter -= delta   # Fix triple jump bug
		velocity += get_gravity() * delta
		#if the player is falling, and is either charging their dash or dashing, slow their descent
		if velocity.y > 0 and (is_charging or is_dashing):
			velocity.y /= grav_div
	elif velocity.y > 0:
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
	elif (attached_to_wall or coyote_time_wall_counter > 0) and jump_buffer_counter > 0 and GameManager.violin_unlocked:
		attached_to_wall = false
		velocity.x = wall_jump_force * get_wall_normal().x
		velocity.y = jump_velocity
		pause_movement(0.1)
		jump_buffer_counter = 0
		coyote_time_wall_counter = 0
		$ViolinJump.play()
			
	## Double Jump - Added check for if drum unlocked
	elif jump_buffer_counter > 0 and double_jump_count == 0 and GameManager.drum_unlocked and !no_doublejump_zone:
		jump_buffer_counter = 0
		velocity.y = jump_velocity
		double_jump_count += 1
		$DrumJump.play()
	
	# Otherwise, no jump is performed
		
	## Jump Cutting
	if Input.is_action_just_released("Accept") and velocity.y < -30:
		velocity.y = - 30

func move_and_animate() -> void:
	# only walk when there is a direction input and the player is not clinging to a wall
	smear.visible = !$BatonArea/BatonAtack.disabled
	drum_wave.visible = !$DrumArea/DrumAttack.disabled
	if knocked:
		velocity.x = 0
		return  # NO MOVING WHEN KNOCKED
	if direction and not attached_to_wall:
		#select animation depending on what state of motion player is in
		# ie dash, charge dash, regular walk
		if (!is_charging and !is_dashing and !attack_animation):
			play_animation("walk")
		elif is_charging:
			play_animation("charge_up")
		elif is_dashing:
			play_animation("sprint")
			
		velocity.x = move_toward(velocity.x, direction * speed * dash_mult, speed) 
		# Flip the sprite based on direction
		if direction > 0:
			sprite.flip_h = false  # Face right
			$BatonArea.scale.x = 1
			smear.scale.x = 0.2
			smear.position.x = 29
		elif direction < 0:
			sprite.flip_h = true # Face left
			$BatonArea.scale.x = -1
			smear.scale.x = -0.2
			smear.position.x = -29
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		# play the idle animation if on floor and not charging up a dash
		if is_on_floor() and !is_charging and !attack_animation:
			play_animation("idle")
		# play a slowed down walk animation to simulate charging up 
		elif is_on_floor() and is_charging:
			play_animation("charge_up")
		elif is_on_wall_only():
			# put wall slide here
			play_animation("idle")
		else:
			# place falling animation here
			# etc etc
			pass
			
	move_and_slide()

func play_animation(animation_name) -> void:
	if sprite.animation != animation_name:
		sprite.play(animation_name)

func take_damage(knockback_dir=null) -> void:
	# Direction should == -1 or 1 (direction to launch player when taking damage)
	if i_frame_timer <= 0:
		i_frame_timer = default_i_frame_timer
		$AnimatedSprite2D/HitFlash.play("flash")
		UI.decrease_health()
		camera.apply_shake(30)
		
		# Hit freeze effect https://www.youtube.com/watch?v=44YpRF5FZDc
		Engine.time_scale = 0.1
		knocked = true
		sprite.pause()
		await get_tree().create_timer(0.05, false).timeout
		knocked = false
		sprite.play()
		Engine.time_scale = 1
		
		# ChatGPT helped me make a knockback!
		if knockback_dir != null:
			velocity.x = knockback_dir * 500
			velocity.y = -100
			pause_movement(0.2)

func pause_movement(howlong) -> void:
	# Briefly disable movement control (thanks chatgpt <3)
	moving_allowed = false
	await get_tree().create_timer(howlong, false).timeout
	moving_allowed = true

func use_attack(instrument: String) -> void:
	$AttackCooldown.start(0.4)
	weapon_cooling_down = true
	match instrument:
		"baton":
			$BatonArea/BatonAtack.disabled = false
			$BatonArea/BatonAtack/BatonTimer.start()
			play_animation("attack")
			smear.play("smear")
			attack_animation = true
		"drum":
			$DrumArea/DrumAttack.disabled = false
			$DrumArea/DrumAttack/DrumTimer.start()
			$DrumKnockback/CollisionShape2D.disabled = false
			play_animation("attack")
			attack_animation = true
		"sax":
			# place sax functionality here
			pass
		"violin":
			# place violin functionality here
			pass
		_:
			print_debug("player.use_attack called with unknown instrument! How did you get here?")
	

func _on_dash_charge_timer_timeout() -> void:
	#start the dash, increase the speed of the player
	dash_mult = 2
	is_charging = false
	is_dashing = true
	$DashExecuteTimer.start()
	$SaxDash.play()
	
func _on_dash_execute_timer_timeout() -> void:
	#dash over, return to normal movement and fall speeds
	dash_mult = 1
	grav_div = 1
	is_dashing = false

#Re-disables the attack hitbox after the agreed upon duration
func _on_drum_timer_timeout() -> void:
	$DrumArea/DrumAttack.disabled = true
	$DrumKnockback/CollisionShape2D.disabled = true
	attack_animation = false

#Re-disables the attack hitbox after the agreed upon duration
func _on_baton_timer_timeout() -> void:
	$BatonArea/BatonAtack.disabled = true
	attack_animation = false
	smear.stop()

## Consequence for enemies hitting the DRUM attack hitbox
func _on_drum_area_body_entered(body: Node2D) -> void:
	# Note that drum does 1/2 the damage of baton
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		var hit_dir = sign(body.position.x - position.x)
		if randf() < 0.1:
			# Critical strike! maybe play diff noise?
			crit_label.visible = true
			body.take_damage(damage, hit_dir)
		else:
			# Regular damage :(
			body.take_damage(damage/2, hit_dir)
		
		pause_movement(0.1)
		camera.apply_shake(5)
		velocity.x = -hit_dir * 200  # knock the player back a tiny bit too

## Consequence for enemies hitting the BATON hitbox
func _on_baton_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		var hit_dir = sign(body.position.x - position.x)
		if randf() < 0.1:
			# Critical strike! maybe play diff noise?
			crit_label.visible = true
			body.take_damage(2*damage, hit_dir)
		else:
			# Regular damage :(
			body.take_damage(damage, hit_dir)
		
		pause_movement(0.1)
		camera.apply_shake(5)
		velocity.x = -hit_dir * 200  # knock the player back a tiny bit too


func _on_attack_cooldown_timeout():
	weapon_cooling_down = false
	crit_label.visible = false


func _on_drum_knockback_body_entered(body):
	if body.get_collision_layer() == 32 and body.has_method("knockback"):
		# Projectile is on collision layer 6 which has a value of 32
		body.knockback(Vector2(body.position.x - position.x, body.position.y - position.y).normalized())


func _on_door_body_entered(body):
	if get_tree().current_scene.name == "Level0":
		GameManager.furthest_level = "res://scenes/levels/level1_1.tscn"
		SceneTransition.change_scene("res://scenes/levels/level1_1.tscn")
	elif get_tree().current_scene.name == "Level11":
		GameManager.furthest_level = "res://scenes/levels/level1_2.tscn"
		SceneTransition.change_scene("res://scenes/levels/level1_2.tscn")
		GameManager.sax_unlocked = true
	elif get_tree().current_scene.name == "Level12":
		GameManager.furthest_level = "res://scenes/levels/level1_3.tscn"
		SceneTransition.change_scene("res://scenes/levels/level1_3.tscn")
		GameManager.violin_unlocked = true
	elif get_tree().current_scene.name == "Level13":
		GameManager.furthest_level = "res://scenes/levels/level_0.tscn"
		SceneTransition.change_scene("res://scenes/interfaces/win/win.tscn")
