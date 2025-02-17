extends CanvasLayer

@onready var main_menu_btn: Button = $"VBoxContainer/Main Menu"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_menu_btn.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/states/main_menu/main_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
