extends Node2D

func _ready() -> void:
	# Get references
	var flower = $Flower
	var vine = $Vine
	vine.setup_animation()
	
	# Connect for collapse loop
	if flower and vine:
		flower.hit.connect(vine.trigger_collapse_loop)
