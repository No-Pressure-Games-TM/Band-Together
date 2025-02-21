extends CanvasLayer

@onready var retry_btn: Button = $VBoxContainer/Retry

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	retry_btn.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_retry_pressed() -> void:
	SceneTransition.change_scene("res://scenes/levels/level_0.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
