extends Node2D

func _on_area_2d_body_entered(body):
	if body.velocity.y > 0:
		# Ensure whatever collides with it is moving downwards
		if body.name == "Player" and not Input.is_action_pressed("Down"):
			# hold down to pass through the mushroom. Hold jump to bounce extra high
			if Input.is_action_pressed("Accept"):
				body.velocity.y = 1.3 * body.jump_velocity
			else:
				body.velocity.y = body.jump_velocity
			body.double_jump_count = 0 # reset doublejump
			$Head/AnimationPlayer.play("squish")
		elif body.is_in_group("enemy"):
			# allow enemies to also bounce on it!
			body.velocity.y = -300
			$Head/AnimationPlayer.play("squish")


func _on_no_double_jumps_body_entered(body):
	if body.name == "Player":
		body.no_doublejump_zone = true


func _on_no_double_jumps_body_exited(body):
	if body.name == "Player":
		body.no_doublejump_zone = false
