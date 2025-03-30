extends CharacterBody2D

var despawn_timer: float = 5.0  # despawn after 5 seconds to reduce lag

func _physics_process(delta):
	if velocity.y < 200:
		velocity += get_gravity() * delta
	move_and_slide()
	despawn_timer -= delta
	if despawn_timer <= 0:
		queue_free()


func _on_hitbox_body_entered(body):
	if body.name == "Player":
		body.take_damage(sign(body.position.x - position.x))
