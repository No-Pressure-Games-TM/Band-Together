extends Node2D

@onready var flower: Flower = $Level2_1_Flower
@onready var vine1: Vine = $Level2_1_Vine
@onready var vine2: Vine = $Level2_1_Vine2
@onready var door: Area2D = $Door

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect vines to retract when the flower is hit
	if flower and vine1 and vine2:
		for vine in [vine1, vine2]:
			vine.setup_animation("expanded")
			flower.hit.connect(vine.trigger_retract)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
		
