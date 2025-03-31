extends Area2D

@export var set_offset_to: int

func _on_body_entered(body):
	if body.name == "Player":
		body.camera.new_offset(set_offset_to)
