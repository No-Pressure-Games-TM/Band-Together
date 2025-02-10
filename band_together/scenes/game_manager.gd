extends Node

var lives: int = 3 
@export var hearts: Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("\nGame started. \nLives: ", lives)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func decrease_health():
	lives -= 1
	
	# Update hearts displayed
	for current_hearts in 3:
		if (current_hearts < lives):
			hearts[current_hearts].show()
		else: 
			hearts[current_hearts].hide()
	
	if (lives == 0):
		print("Game Over.\n")
		get_tree().call_deferred("change_scene_to_file", "res://scenes/states/game_over/game_over.tscn")
	else: 
		print("Lives: ", lives)
