extends CharacterBody2D

var spawn_pos: Vector2  # The location to spawn this coconut
var despawn_timer: float = 5.0  # despawn after 3 seconds to reduce lag
var grow_time: float = 0  # Time to grow after spawning and before dropping
var elapsed_grow_time: float = 0
var grav_div = 2

func _ready():
	global_position = spawn_pos
	if grow_time != 0:
		scale = Vector2(0.1,0.1)  # tiny!
		$Hitbox.set_collision_layer_value(5, false)  # Disable "hitbox" collision layer
		$Hitbox.set_collision_mask_value(2, false)  # Disable colliding with player

func _physics_process(delta):
	if scale != Vector2.ONE:
		elapsed_grow_time += delta
		var t = clampf(elapsed_grow_time/grow_time, 0.1, 1)
		scale = lerp(Vector2.ZERO, Vector2.ONE, t)
		if scale == Vector2.ONE:
			$Hitbox.set_collision_layer_value(5, true)  # Enable "hitbox" collision layer
			$Hitbox.set_collision_mask_value(2, true)  # Enable colliding with player
	else:
		velocity += get_gravity() * delta / grav_div
		move_and_slide()
		despawn_timer -= delta
		if despawn_timer <= 0:
			queue_free()

func knockback(direction: Vector2):
	if velocity != Vector2.ZERO:
		velocity.x = direction.x * 350
		velocity.y = direction.y * 350
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
