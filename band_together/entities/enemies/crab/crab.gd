extends CharacterBody2D

# I FOLLOWED THIS TUTORIAL
# https://www.youtube.com/watch?v=P02PcfgqrY8&ab_channel=GameDevKnight

## Set to 1 if you want it to move right at the start
@export var direction: int = -1
@export var speed: float = 40.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast: RayCast2D = $RayCast2D

var stopped: bool = false

func _ready():
	$StopMoving.wait_time = randf_range(2.5, 4)  # Walk for random time length
	$StopMoving.start()
	sprite.play("walk")
	if direction > 0:
		direction = -direction  # I coded this weird so.. I guess I'll do this
		flip()

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if (not raycast.is_colliding() and is_on_floor()) or is_on_wall():
		flip()
	
	if stopped:
		if sprite.animation != "idle":
			sprite.play("idle")
		velocity.x = 0  # stop moving!
	else:
		if sprite.animation != "walk":
			sprite.play("walk")
		velocity.x = direction * speed
	move_and_slide()

func _process(delta):
	if (sprite.frame == 2 or sprite.frame == 5) and sprite.animation == "walk":
		sprite.position.y = 2
	else:
		sprite.position.y = 0

func flip():
	direction = -direction
	sprite.flip_h = !sprite.flip_h
	raycast.position.x *= -1  # Flip the raycast to the other side

func _on_hitbox_body_entered(body):
	if body.name == "Player":
		body.take_damage(sign(body.position.x - position.x))
		flip()  # makes it so player cannot stay in the hitbox


func _on_stop_moving_timeout():
	if stopped:
		# we want to start moving
		$StopMoving.wait_time = randf_range(2.5, 4)  # Walk for random time length
	else:
		# we want to stop moving
		$StopMoving.wait_time = randf_range(0.5, 1.5)
	stopped = !stopped
	$StopMoving.start()  # Reset the timer
		
