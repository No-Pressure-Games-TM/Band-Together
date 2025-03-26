extends Control

@onready var start_game_btn: Button = $VBoxContainer/StartGame

func _ready():
	AudioManager.play_music(AudioManager.music_player.stream)
	start_game_btn.grab_focus()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		return  # Ignore mouse movement for this
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_start_pressed() -> void:
	SceneTransition.change_scene(GameManager.furthest_level)
	
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
