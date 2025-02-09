extends Node

var lives: int = 3 
@export var hearts: Array[Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("\nGame started. \nLives: ", lives)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
		print("Game Over.\nReloading...\n")
		get_tree().reload_current_scene()
	else: 
		print("Lives: ", lives)
