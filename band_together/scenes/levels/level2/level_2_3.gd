extends Node2D

@onready var flower1: Flower = $Level2_3_Flower1
@onready var vine1: Vine = $Level2_3_Vine1
@onready var vine2: Vine = $Level2_3_Vine2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect vines to retract when the flower is hit
	if flower1 and vine1 and vine2:
		for vine in [vine1, vine2]:
			vine.setup_animation("expanded")
			flower1.hit.connect(vine.trigger_retract)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
