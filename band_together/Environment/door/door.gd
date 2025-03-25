extends Area2D

## The path to the next scene i.e. res://scenes/levels/level1_1.tscn (Leave blank if door_dialogue is not blank)
@export var destination_scene: String
## Play this dialogue before entering the door (Leave blank if destination_scene is not blank)
@export var door_dialogue: String

func _on_body_entered(body):
	if body.name == "Player":
		# wait for the player to be on floor
		while not body.is_on_floor():
			await get_tree().process_frame
		if door_dialogue != "":
			GameManager.start_dialogue(door_dialogue)
		elif destination_scene != "":
			GameManager.furthest_level = destination_scene
			SceneTransition.change_scene(destination_scene)

func disable():
	# Disable the current door
	$CollisionShape2D.disabled = true
	$AnimatedSprite2D.modulate = Color(0.5, 0.5, 0.5, 0.8)  # Make it look kinda ded
