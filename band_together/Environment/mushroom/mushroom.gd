extends Node2D
# This is for a few specific mushrooms that the no doublejump zone is getting in the way
@export var disable_no_doublejump_zone: bool = false

func _ready():
	if disable_no_doublejump_zone:
		$NoDoubleJumps/CollisionShape2D.disabled = true

func _on_area_2d_body_entered(body):
	if body.velocity.y > 0:
		# Ensure whatever collides with it is moving downwards
		if body.name == "Player":
			# Hold jump to bounce extra high
			if body.jump_buffer_counter > 0 or Input.is_action_pressed("Accept"):
				body.velocity.y = 1.5 * body.jump_velocity
			else:
				body.velocity.y = body.jump_velocity
			body.pause_jumpcutting()
			body.double_jump_count = 0 # reset doublejump
			$Head/AnimationPlayer.play("squish")
		elif body.is_in_group("enemy"):
			# allow enemies to also bounce on it!
			body.velocity.y = -300
			$Head/AnimationPlayer.play("squish")


func _on_no_double_jumps_body_entered(body):
	if body.name == "Player":
		body.toggle_double_jump(false)


func _on_no_double_jumps_body_exited(body):
	if body.name == "Player":
		body.toggle_double_jump(true)
