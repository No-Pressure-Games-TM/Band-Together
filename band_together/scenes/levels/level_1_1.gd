extends Node2D

@onready var p: CharacterBody2D = $SceneObjects/Player

const reed_scene: PackedScene = preload("res://entities/player/reed.tscn")

func _ready():
	if GameManager.drum_unlocked:
		# Do the stuff unlocking the drum wouldve done. This just 
		# means the player has loaded this level but has died after getting drum.
		$SceneObjects/PressToDoubleJump.visible = true
		$SceneObjects/PressToSwap.visible = true
		# Change camera bounds
		p.camera.set_limits(p.bottom_limit, p.top_limit, 592, p.left_limit)
		$SceneObjects/DrumPickup.queue_free()  # Remove drum from the game cuz it's picked up
		
		# Debug by gaven, feel free to remove
		GameManager.sax_unlocked = true
		


func _on_player_shoot(pos: Vector2, facing_left) -> void:
	print("allegro shoots a reed from the saxophone, gross!")
	print(pos)
	
	var reed = reed_scene.instantiate()
	var direction = -1 if facing_left else 1

	#reed.position = pos
	
	reed.direction = direction
	$SceneObjects/Reeds.add_child(reed)
	reed.global_position = pos + Vector2(16*direction , 0)
