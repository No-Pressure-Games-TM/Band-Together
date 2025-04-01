extends Node2D

@onready var flower: Flower = $Flower
@onready var vine: Vine = $Vine

func _ready() -> void:
	vine.setup_animation("expanded")
	if flower and vine:
		flower.hit.connect(vine.trigger_retract)
