extends CanvasLayer

@onready var retry_btn: Button = $VBoxContainer/Retry

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		return  # Ignore mouse movement for this
		
	var current_focused = get_viewport().gui_get_focus_owner()
	if current_focused == null or not current_focused is Button:
		# No button is focused. Grab focus
		retry_btn.grab_focus()
		
	# Helped create with ChatGPT
	# Check if Accept action is pressed and trigger the focused button
	if event.is_action_pressed("Accept"):
		if current_focused is Button:
			current_focused.emit_signal("pressed")  # Manually trigger button press

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_retry_pressed() -> void:
	SceneTransition.change_scene(GameManager.furthest_level)

func _on_quit_pressed() -> void:
	get_tree().quit()
