extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		GameManager.start_dialogue("findbreve")
		queue_free()  # remove this area
