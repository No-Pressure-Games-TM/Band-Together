extends Area2D


func _on_body_entered(body):
	if body.name == "Player":
		body.take_damage(sign(body.position.x - position.x))
		body.respawn()
	
	elif body.is_in_group("enemy") and body.has_method("take_damage"):
		var hit_dir = sign(body.position.x - position.x)
		# This KILLS da enemy
		body.take_damage(10000, hit_dir)
