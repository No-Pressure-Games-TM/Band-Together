extends CharacterBody2D

# I FOLLOWED THIS TUTORIAL
# https://www.youtube.com/watch?v=P02PcfgqrY8&ab_channel=GameDevKnight

## Set to 1 if you want it to move right at the start
@export var direction: int = -1
@export var speed: float = 60.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast: RayCast2D = $RayCast2D

func _ready():
	if direction > 0:
		direction = -direction  # I coded this weird so.. I guess I'll do this
		flip()
	sprite.play("default")

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if (not raycast.is_colliding() and is_on_floor()) or is_on_wall():
		flip()
	
	velocity.x = direction * speed
	move_and_slide()

func flip():
	direction = -direction
	sprite.flip_h = !sprite.flip_h
	raycast.position.x *= -1  # Flip the raycast to the other side


func _on_hitbox_body_entered(body):
	if body.name == "Player":
		UI.decrease_health()
		# ChatGPT helped me make a knockback!
		body.knocked_back(sign(body.position.x - position.x))
