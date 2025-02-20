extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_win_area_body_entered(_body: Node2D) -> void:
	print("You Win!\n")
	SceneTransition.change_scene("res://scenes/states/win/win.tscn")
