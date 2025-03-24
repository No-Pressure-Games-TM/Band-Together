extends CharacterBody2D

#region Camera
@export var left_limit: int = -10000000        # Camera left limit (px)
@export var right_limit: int = 10000000        # Camera right limit (px)
@export var top_limit: int = -10000000         # Camera top limit (px)
@export var bottom_limit: int = 10000000        # Camera bottom limit (px)
#endregion

#region Physics
@export var speed: float = 100.0               # Player's movespeed
@export var acceleration: float = 400.0        # The rate at which speeds up from 0
@export var deceleration: float = 600.0
@export var jump_velocity: float = -325.0      # Player's jump velocity
@export var jump_buffer: float = 0.2            # Jump buffer
@export var coyote_time: float = 0.2             # Coyote time
var coyote_time_counter: float = 0               # Counts coyote time
var coyote_time_wall_counter: float = 0          # Counter specifically for walls
var jump_buffer_counter: float = 0               # Counts jump buffer
var double_jump_count: int = 0
var dash_mult: int = 1                         # Dash movespeed multiply
var grav_div: float                              # Divide gravity while charging dash
var moving_allowed: bool = true
var knocked: bool = false
var no_doublejump_zone: bool = false           # set by the mushroom, so no double jump when trying to bounce
var cutting_enabled = true                     # true if jump cutting is enabled. This is for mushrooms
#endregion

#region Dash bools
var is_charging: bool = false
var is_dashing: bool = false
#endregion

#region Projectile bools
var was_held: bool = false
var is_held: bool = false
var angle: float = 0;
const inc: float  = 0.025
var dir: int = 1
#endregion


var direction: int = 0 
var last_direction: int = 0

# DEBUG
var path: PackedVector2Array = []
var pathing: bool = false

#region combat
var damage: int = 15
var weapon_cooling_down: bool = false
@onready var crit_label = $CritText
#endregion

#region Wall Jump states
var attached_to_wall: bool = false
@export var wall_jump_force: int = 200        # Force of bouncing off wall
@export var wall_slide_speed: float = 1500.0    # Speed of sliding down wall
#endregion

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var smear: AnimatedSprite2D = $AnimatedSprite2D/SwordSmear
@onready var drum_wave: Sprite2D = $AnimatedSprite2D/DrumWave
@onready var camera: Camera2D = $Camera2D
var attack_animation: bool = false

var default_i_frame_timer: float = 1.3  # number of seconds to be invincible after being hit
@onready var i_frame_timer: float = default_i_frame_timer

#Signal for sax attack (creation of reed projectiles)
#https://www.youtube.com/watch?v=7ijfcTN4g0Y
signal shoot(pos: Vector2, direction: int, angle: float)

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

func _draw():
	# delete this before shipping
	if path.size() >= 2:
		for i in range(path.size() -1):
			draw_line(to_local(path[i]), to_local(path[i+1]), Color.RED, 30)

func _physics_process(delta):
	# delete this pathing part before shipping
	if pathing:
		path.append(global_position)
		queue_redraw()
	if GameManager.drum_unlocked:
		$BeachDrum.volume_db = 0
		
	if GameManager.violin_unlocked:
		$BeachString.volume_db = 0
		
	if GameManager.sax_unlocked:
		$BeachSax.volume_db = 0
			
	if GameManager.in_dialogue == false:
		# Added this if statement to remove control when in dialogue
		check_input()  # Attacks, direction input, wall attaching
		gravity(delta)  # Slow fall, wall slide, jump buffer, coyote time is also in here!
		jump(delta)  # All types of jumps (wall jump, double jump, etc!)
		move_and_animate(delta)  # Sets velocity based on input, changes sprites
		
	if !was_held and is_held: #start the sax charge
		angle = 0
		was_held = true
		attack_animation = true
		play_animation("aim")
	if was_held and is_held: # increment the sax charge
		$Line2D.clear_points()
		angle += dir*inc
		if angle> 1.57:
			dir = -1
		if angle < 0:
			dir = 1
		$Line2D.add_point(Vector2(0,0))
		if sprite.flip_h:
			$Line2D.add_point(Vector2(-cos(angle),sin(angle)))
		else:
			$Line2D.add_point(Vector2(cos(angle),sin(angle)))
			
	#if was_held and !is_held: # release the sax charge
		
		
	
	check_input()  # Attacks, direction input, wall attaching
	gravity(delta)  # Slow fall, wall slide, jump buffer, coyote time is also in here!
	jump(delta)  # All types of jumps (wall jump, double jump, etc!)
	move_and_animate(delta)  # Sets velocity based on input, changes sprites
	
	if is_on_floor():
		GameManager.save_ground_position(global_position)  # Store last ground position

		if global_position.y > 1000:  # TODO: Refractor to calculate WorldBoundary. If the player falls out of the world boundary, respawn
			respawn()
	else:
		# We are in a dialogue
		play_animation("idle")

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
	# DELETE THE NEXT 2 IF STATEMENTS BEFORE SHIPPING GAME
	if Input.is_action_just_pressed("Path"):
		pathing = true
		print_debug("Pathing started")
	if Input.is_action_just_pressed("StopPath"):
		pathing = false
		print_debug("Pathing stopped")
		path.clear()
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
		if GameManager.get_current_instrument() == "sax":
			is_held = true
			return
			
		
		
		use_attack(GameManager.get_current_instrument(), direction)
	
	if Input.is_action_just_released("Decline") and GameManager.get_current_instrument() == "sax":
		was_held =false
		is_held = false
		use_attack(GameManager.get_current_instrument(), direction)
	
	direction = sign(round(Input.get_vector("Left", "Right", "Up", "Down")).normalized().x)
	
	# Wall attaching
	if is_on_wall_only() and direction == -get_wall_normal().x and velocity.y > -10 and !is_charging:
		# Added velocity.y > -10 to allow player to jump when beside wall
		attached_to_wall = true
	elif direction == get_wall_normal().x or Input.is_action_just_pressed("Down") or !is_on_wall() or is_charging:
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
	elif attached_to_wall and GameManager.get_current_instrument() == "violin":
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
	
	## Regular Jump - Disabled for sax
	if (is_on_floor() or coyote_time_counter > 0) and jump_buffer_counter > 0 and GameManager.get_current_instrument() != "sax":
		velocity.y = jump_velocity
		jump_buffer_counter = 0
		coyote_time_counter = 0
	
	## Wall Jump
	elif (attached_to_wall or coyote_time_wall_counter > 0) and jump_buffer_counter > 0 and GameManager.get_current_instrument() == "violin":
		attached_to_wall = false
		velocity.x = wall_jump_force * get_wall_normal().x
		velocity.y = jump_velocity/1.2
		pause_movement(0.1)
		jump_buffer_counter = 0
		coyote_time_wall_counter = 0
		$ViolinJump.play()
			
	## Double Jump - Added check for if drum unlocked
	elif Input.is_action_just_pressed("Accept") and !is_on_floor() and double_jump_count == 0 and GameManager.get_current_instrument() == "drum" and !no_doublejump_zone:
		velocity.y = jump_velocity
		double_jump_count += 1
		$DrumJump.play()
	
	## Dash
	elif GameManager.get_current_instrument() == "sax" and Input.is_action_just_pressed("Accept") and !is_charging and !is_dashing:
		#Start charging up a dash
		is_charging = true
		speed = 20
		$DashChargeTimer.start()
		$SaxCharge.play()
	
	# Otherwise, no jump is performed
		
	## Jump Cutting
	if Input.is_action_just_released("Accept") and velocity.y < -30 and cutting_enabled:
		velocity.y = - 30

func move_and_animate(delta) -> void:
	# only walk when there is a direction input and the player is not clinging to a wall
	smear.visible = !$BatonArea/BatonAtack.disabled
	drum_wave.visible = !$DrumKnockback/CollisionShape2D.disabled
	
	if knocked:
		velocity.x = 0
		return  # NO MOVING WHEN KNOCKED
	
	if direction != 0:
		last_direction = direction
		# Flip the sprite based on direction
		if direction > 0:
			sprite.flip_h = false  # Face right
			$CollisionShape2D.position.x = -3
			$BatonArea.scale.x = 1
			smear.scale.x = 0.2
			smear.position.x = 29
		elif direction < 0:
			sprite.flip_h = true # Face left
			$CollisionShape2D.position.x = 3
			$BatonArea.scale.x = -1
			smear.scale.x = -0.2
			smear.position.x = -29
	
	if is_dashing:
		# no need to use move_toward so they can turn on a dime
		velocity.x = last_direction * speed * dash_mult
		if is_on_wall() and sign(velocity.x) == -get_wall_normal().x:
			# stop dashing when hit a wall
			$DashExecuteTimer.stop()
			$DashExecuteTimer.emit_signal("timeout")
	elif direction and not attached_to_wall and moving_allowed:
		if sign(velocity.x) != direction:
			# Stronger deceleration if turning around or in air
			if not is_on_floor():
				velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta * 20)
			else:
				velocity.x = move_toward(velocity.x, direction * speed, deceleration * delta * 1.5)
		else:
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta) 
	elif moving_allowed:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
	
	if attack_animation:
		# Attack animations need to be handled elsewhere. So I added this
		move_and_slide()
		return  # Don't play the other animations if we are attacking
	
	## Animations go here
	if attached_to_wall and GameManager.get_current_instrument() == "violin":
		play_animation("wall_slide")
		# The next 2 if statements are to fix a graphical bug (sliding backwards on walls)
		if get_wall_normal().x < 0:
			sprite.flip_h = false  
		elif get_wall_normal().x > 0:
			sprite.flip_h = true
	elif is_charging:
		play_animation("charge_up")
	elif is_dashing:
		play_animation("sprint")
	elif not is_on_floor():
		if velocity.y > -30 and velocity.y < 30:
			play_animation("jump_apex")  # Top of the jump (gave a small range)
		elif velocity.y < 0:
			play_animation("jump_start")  # moving upwards
		elif velocity.y > 0:
			play_animation("falling")  # moving downwards
	elif is_on_floor():
		if direction != 0:
			# Attack animation is handled elsewhere (sorry!)
			play_animation("walk")
		else:
			# There is no other states. Just idle
			play_animation("idle")
			
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
			velocity.x += knockback_dir * 200
			velocity.y = -100
			pause_movement(0.2)

func pause_movement(howlong) -> void:
	# Briefly disable movement control (thanks chatgpt <3)
	moving_allowed = false
	await get_tree().create_timer(howlong, false).timeout
	moving_allowed = true

func use_attack(instrument: String, direction: int) -> void:
	$AttackCooldown.start(0.4)
	weapon_cooling_down = true
	match instrument:
		"baton":
			$BatonArea/BatonAtack.disabled = false
			$BatonArea/BatonAtack/BatonTimer.start()
			play_animation("baton_attack")
			smear.play("smear")
			attack_animation = true
		"drum":
			$DrumKnockback/DrumTimer.start()
			$DrumKnockback/CollisionShape2D.disabled = false
			play_animation("drum_attack")
			attack_animation = true
		"sax":
			# place sax functionality here
			$SaxAttack.play()
			shoot.emit(global_position, sprite.flip_h, angle)
			$Line2D.clear_points()
			play_animation("shooting")
			attack_animation = true
			$"Reed Timer".start()
			
			pass
		"violin":
			# place violin functionality here
			pass
		_:
			print_debug("player.use_attack called with unknown instrument! How did you get here?")
	
func pause_jumpcutting():
	# Pauses jump cutting. This is used currently just for mushrooms
	cutting_enabled = false
	await get_tree().create_timer(0.4).timeout
	cutting_enabled = true

func _on_dash_charge_timer_timeout() -> void:
	#start the dash, increase the speed of the player
	dash_mult = 2
	grav_div = 1.2
	speed = 100  # Reset after slowing down previously
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
	$DrumKnockback/CollisionShape2D.disabled = true
	attack_animation = false

#Re-disables the attack hitbox after the agreed upon duration
func _on_baton_timer_timeout() -> void:
	$BatonArea/BatonAtack.disabled = true
	attack_animation = false
	smear.stop()

### Consequence for enemies hitting the DRUM attack hitbox
## Commented out to remove drum damage
#func _on_drum_area_body_entered(body: Node2D) -> void:
	## Note that drum does 1/2 the damage of baton
	#if body.is_in_group("enemy") and body.has_method("take_damage"):
		#var hit_dir = sign(body.position.x - position.x)
		#if randf() < 0.1:
			## Critical strike! maybe play diff noise?
			#crit_label.visible = true
			#body.take_damage(damage, hit_dir)
		#else:
			## Regular damage :(
			#body.take_damage(damage/2, hit_dir)
		#
		#camera.apply_shake(5)
		#velocity.x += -hit_dir * 100  # knock the player back a tiny bit too

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
		
		camera.apply_shake(5)
		velocity.x += -hit_dir * 10  # knock the player back a tiny bit too

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


func _on_reed_timer_timeout() -> void:
	attack_animation = false # Replace with function body.
