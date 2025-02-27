extends CharacterBody2D

var random_weight_multiplier: float  # different coconuts fall at different speeds!
var spawn_pos: Vector2  # The location to spawn this coconut

func _ready():
	global_position = spawn_pos
	random_weight_multiplier = randf_range(0.3, 1.4)  # Adjust as needed

func _physics_process(delta):
	velocity += get_gravity() * delta * random_weight_multiplier
	move_and_slide()

func knockback(direction: Vector2):
	velocity.x = direction.x * 500
	velocity.y = direction.y * 500
	$Hitbox.set_collision_layer_value(5, false)  # Remove "hitbox" collision layer
	$Hitbox.set_collision_mask_value(2, false)  # Disable colliding with player
	$Hitbox.set_collision_mask_value(4, true)  # Enable colliding with enemies

func _on_hitbox_body_entered(body):
	if body.name == "Player":
		body.take_damage(sign(body.position.x - position.x))
	
	elif body.is_in_group("enemy") and body.has_method("take_damage"):
		var hit_dir = sign(body.position.x - position.x)
		# This does a LOT of damage cuz it's so hard to hit
		body.take_damage(100, hit_dir)
