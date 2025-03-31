extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# When player falls off scene, reload.
func _on_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		if body.i_frame_timer < 0:
			# only lose health if not in i-frames
			UI.decrease_health()
		body.respawn()
		
