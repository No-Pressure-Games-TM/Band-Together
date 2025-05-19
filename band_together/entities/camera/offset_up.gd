extends Area2D

@export var set_x_offset_to: int = 0
@export var set_y_offset_to: int = 0
@export var start_disabled: bool = false

func _on_body_entered(body):
	if body.name == "Player":
		body.camera.new_offset(set_x_offset_to, set_y_offset_to)

func toggle():
	# Disable if enabled, enable if disabled
	$CollisionShape2D.disabled = not $CollisionShape2D.disabled
