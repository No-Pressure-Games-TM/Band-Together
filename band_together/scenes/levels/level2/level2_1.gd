extends Node2D

@onready var flower: Flower = $Level2_1_Flower
@onready var vine1: Vine = $Level2_1_Vine
@onready var vine2: Vine = $Level2_1_Vine2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect for retracting vine
	if flower and vine1 and vine2:
		vine1.setup_animation("expanded")
		vine2.setup_animation("expanded")
		flower.hit.connect(vine1.trigger_retract)
		flower.hit.connect(vine2.trigger_retract)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
		
