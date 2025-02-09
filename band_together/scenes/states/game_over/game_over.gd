extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/test/test_helen.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
