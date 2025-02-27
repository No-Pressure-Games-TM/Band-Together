extends CanvasLayer

@onready var retry_btn: Button = $VBoxContainer/Retry

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	retry_btn.grab_focus()

func _input(event: InputEvent) -> void:
	# Helped create with ChatGPT
	# Check if Accept action is pressed and trigger the focused button
	if event.is_action_pressed("Accept"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused is Button:
			focused.emit_signal("pressed")  # Manually trigger button press

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_retry_pressed() -> void:
	SceneTransition.change_scene(GameManager.furthest_level)

func _on_quit_pressed() -> void:
	get_tree().quit()
