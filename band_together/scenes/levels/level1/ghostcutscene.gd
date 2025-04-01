extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		if get_parent().name == "Level1End":
			get_parent().get_node("Breve").get_child(0).flip_h = true
			GameManager.start_dialogue("findbreve")
		if get_parent().name == "Level2End":
			get_parent().get_node("Forte").get_child(0).flip_h = true
			GameManager.start_dialogue("findforte")
		elif get_parent().name == "Level3End":
			GameManager.start_dialogue("findarco")
			
		queue_free()  # delete the area2D so player does not reactivate it
