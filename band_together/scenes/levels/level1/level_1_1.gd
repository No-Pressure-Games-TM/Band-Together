extends Node2D

@onready var cam = $SceneObjects/Camera

func _ready():
	if GameManager.drum_unlocked:
		# Do the stuff unlocking the drum wouldve done. This just 
		# means the player has loaded this level but has died after getting drum.
		$SceneObjects/PressToDoubleJump.visible = true
		$SceneObjects/PressToSwap.visible = true
		# Change camera bounds
		cam.limit_right = 592
		GameManager.show_coins("1")  # show the part 2 coins
		$SceneObjects/DrumPickup.queue_free()  # Remove drum from the game cuz it's picked up


#func _on_player_shoot(pos: Vector2, facing_left, angle) -> void:
	#print("allegro shoots a reed from the saxophone, gross!")
	#print(pos)
	#
	#var reed = reed_scene.instantiate()
	#var direction = -1 if facing_left else 1
#
	##reed.position = pos
	#
	#reed.direction = direction
	#reed.angle = angle
	#$SceneObjects/Reeds.add_child(reed)
	#reed.global_position = pos + Vector2(16*direction , 0)
