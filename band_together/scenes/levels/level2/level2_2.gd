extends Node2D

@onready var flower1: Flower = $Level2_2_Flower
@onready var flower2: Flower = $Level2_2_Flower2
@onready var flower3: Flower = $Level2_2_Flower3
@onready var vine1: Vine = $Level2_2_Vine
@onready var vine2: Vine = $Level2_2_Vine2
@onready var vine3: Vine = $Level2_2_Vine3
@onready var vine4: Vine = $Level2_2_Vine4
@onready var vine5: Vine = $Level2_2_Vine5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect vines to retract when the flower is hit
	if flower1 and flower2 and vine1 and vine2 and vine3:
		for vine in [vine1, vine2]:
			vine.setup_animation("expanded")
			flower1.hit.connect(vine.trigger_retract)
		vine3.setup_animation("expanded")
		flower2.hit.connect(vine3.trigger_retract)
		for vine in [vine4, vine5]:
			vine.setup_animation("expanded")
			flower3.hit.connect(vine.trigger_retract)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
