extends Node2D

@onready var p: CharacterBody2D = $SceneObjects/Player

func _ready():
	if GameManager.drum_unlocked:
		# Do the stuff unlocking the drum wouldve done. This just 
		# means the player has loaded this level but has died after getting drum.
		$SceneObjects/PressToDoubleJump.visible = true
		$SceneObjects/PressToSwap.visible = true
		$SceneObjects/PressToShockwave.visible = true
		# Change camera bounds
		p.camera.set_limits(p.bottom_limit, p.top_limit, 592, p.left_limit)
		$SceneObjects/DrumPickup.queue_free()  # Remove drum from the game cuz it's picked up
