extends Node2D

func _ready():
	if GameManager.is_instrument_unlocked(2):
		pass  # This is where the player goes and dialogue for when level 2 is done
	elif GameManager.is_instrument_unlocked(1):
		# Drum is unlocked
		$SceneObjects/Player.position = Vector2(560, 144)  # Move player
	else:
		# No instruments unlocked. Play intro dialogue and don't move player
		GameManager.start_dialogue("prologue")
	
