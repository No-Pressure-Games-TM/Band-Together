extends Control

@onready var start_game_btn: Button = $VBoxContainer/StartGame

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_game_btn.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_start_pressed() -> void:
	SceneTransition.change_scene("res://scenes/levels/level_0.tscn")
	#get_tree().change_scene_to_file("res://scenes/test/test_walljump.tscn")
	#SceneTransition.change_scene("res://scenes/levels/parallax.tscn")


func _on_options_pressed() -> void:
	print("Settings pressed")


func _on_exit_pressed() -> void:
	get_tree().quit()
