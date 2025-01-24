extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -600.0

# This is how you define sprite types, not necessary but good practice for debugging
var sprite: AnimatedSprite2D

func _ready():
	# Hey chat this function is called when the sprite is first loaded
	# Put things here u wanna load before anything else
	sprite = $AnimatedSprite2D

## Use double hashtags for a "title comment", it looks a lil different!
func _physics_process(delta):
	# hey chat this function is called every frame, it is different than
	# the function called process, this one is specifically for physics.
	# I am not actually sure what the difference is lol but it's like update() in unity
	# If you wanna learn more, hold CTRL and click the func name to open the docs!
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		if sprite.animation != "running":
			sprite.play("running")  # Play the running animation
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
