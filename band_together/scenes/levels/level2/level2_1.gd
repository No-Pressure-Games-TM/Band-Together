extends Node2D

@onready var vine: Vine = $Level2_1_Vine
@onready var flower: Flower = $Level2_1_Flower

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect for retracting vine
	if flower and vine:
		vine.setup_animation("expanded")
		flower.hit.connect(vine.trigger_retract)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
