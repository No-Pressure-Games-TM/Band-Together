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
		UI.decrease_health()
		await get_tree().create_timer(1).timeout  # Short delay after death
		get_tree().reload_current_scene.call_deferred()
		
