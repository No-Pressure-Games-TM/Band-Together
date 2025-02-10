extends CharacterBody2D

#region Physics
const SPEED: float = 100.0
const JUMP_VELOCITY: float = -300.0
var double_jump_count: int = 0
#region

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

## Use double hashtags for a "title comment", it looks a lil different!
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		double_jump_count = 0
		
	if Input.is_action_just_pressed("Drum"):
		$DrumArea/DrumAttack.disabled = false
		$DrumArea/DrumAttack/DrumTimer.start()
		
		
	if Input.is_action_just_pressed("Baton"):
		$BatonArea/BatonAtack.disabled = false
		
		$BatonArea/BatonAtack/BatonTimer.start()

	# Handle jump.
	if Input.is_action_just_pressed("Accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif double_jump_count == 0:
			velocity.y = JUMP_VELOCITY
			double_jump_count += 1
	if Input.is_action_just_released("Accept") and velocity.y < -60:
		velocity.y = - 60

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("Left", "Right")
	if direction:
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


func _on_drum_timer_timeout() -> void:
	$DrumArea/DrumAttack.disabled = true


func _on_baton_timer_timeout() -> void:
	$BatonArea/BatonAtack.disabled = true 


func _on_drum_area_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		body.rotate(1)
		


func _on_baton_area_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		body.rotate(1)
		
	pass # Replace with function body.
