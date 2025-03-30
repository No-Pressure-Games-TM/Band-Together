extends Node2D

@export var vine: Vine

func _ready() -> void:
	# Get references
	var flower = $Flower
	var vine = $Vine
	
	# Connect for collapse loop
	if flower and vine:
		flower.hit.connect(vine.trigger_collapse)
