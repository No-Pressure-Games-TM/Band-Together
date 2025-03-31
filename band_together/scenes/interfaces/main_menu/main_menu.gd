extends Control

@onready var start_game_btn: Button = $VBoxContainer/StartGame

func _ready():
	AudioManager.play_music(AudioManager.music_player.stream)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		return  # Ignore mouse movement for this
		
	var current_focused = get_viewport().gui_get_focus_owner()
	if current_focused == null or not current_focused is Button:
		# No button is focused. Grab focus
		start_game_btn.grab_focus()
	
	# Helped create with ChatGPT
	# Check if Accept action is pressed and trigger the focused button
	if event.is_action_pressed("Accept"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused is Button:
			focused.emit_signal("pressed")  # Manually trigger button press
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_start_pressed() -> void:
	#SceneTransition.change_scene(GameManager.furthest_level)
	SceneTransition.change_scene("res://scenes/levels/level2/level2_2.tscn")
	#SceneTransition.change_scene("res://scenes/test/test_walljump.tscn")
	
func _on_options_pressed() -> void:
	print("Settings pressed")


func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_reset_game_pressed():
	# Reset levels progress
	GameManager.furthest_level = "res://scenes/levels/level_0.tscn"
	# Reset instruments progress
	GameManager.drum_unlocked = false
	GameManager.sax_unlocked = false
	GameManager.violin_unlocked = false
	GameManager.current_instrument = 0  # back to baton
	UI.lives = -1  # Reset lives
	UI.coins = 0  # Reset coins
	SceneTransition.change_scene(get_tree().current_scene.scene_file_path)
