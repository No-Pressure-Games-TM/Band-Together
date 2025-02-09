extends Node

var lives: int = 3 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("\nGame started. \nLives: ", lives)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func decrease_health():
	lives -= 1
	if (lives == 0):
		print("Game Over.\nReloading...\n")
		get_tree().reload_current_scene()
	else: 
		print("Lives: ", lives)
