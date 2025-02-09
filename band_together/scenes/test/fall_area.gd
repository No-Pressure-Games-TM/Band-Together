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
		get_tree().reload_current_scene()
