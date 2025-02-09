extends CharacterBody2D

#region Physics
const SPEED: float = 100.0
const JUMP_VELOCITY: float = -300.0
var double_jump_count: int = 0
#region

#keeps track of if the character has attached to the wall
var attached_to_wall = false
var used_walljump = 0 # ternary value, it is 0 if the user has not recently used a walljump, -1 if they have
#recently jumped off a left facing wall, or 1 if they have recently jumped off a right facing wall 

var current_wall = 1
var recent_wall = 0
#could also instead keep a variable for the most recently touched wall, so that the player could jump off 
#of two different walls that face the same direction that are just adjacent to each other. 
#yea i think im gonna go with that one

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

## Use double hashtags for a "title comment", it looks a lil different!
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() and not attached_to_wall:
		velocity += get_gravity() * delta
	else:
		double_jump_count = 0

	# Handle jump.
	if Input.is_action_just_pressed("Accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			recent_wall = null
	
		
		elif attached_to_wall:
			
			velocity.y = JUMP_VELOCITY
			attached_to_wall = false
			recent_wall = current_wall
			current_wall = null
		
			
		elif is_on_wall():
			#print(position.x)
			current_wall = int(position.x)
			if recent_wall != current_wall:
				#need to handle it so there can only be one wall jump on a single wall at a time
				velocity.y = 0
				#set current wall to the wall the player is currently on 
				
				print(current_wall)
				attached_to_wall = true
				
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
