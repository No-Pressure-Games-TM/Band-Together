extends Node2D

func _ready():
	if GameManager.is_instrument_unlocked(2):
		# This is where the player goes and dialogue for when level 2 is done
		$SceneObjects/Player.position = Vector2(499, -80)  # Move player
		$SceneObjects/Door1.disable()
		$SceneObjects/Door2.disable()
	elif GameManager.is_instrument_unlocked(1):
		# Drum is unlocked
		$SceneObjects/Player.position = Vector2(560, 144)  # Move player
		$SceneObjects/Door1.disable()
		GameManager.show_coins("2")
	else:
		# No instruments unlocked. Play intro dialogue and don't move player
		GameManager.start_dialogue("prologue")
		GameManager.show_coins("1")
	
