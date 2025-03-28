extends Camera2D

# For the shake, I tried this video instead https://www.youtube.com/watch?v=JDzUjJypQ9s
var decay: float = 0.8
var max_offset: Vector2 = Vector2(100, 75)
var max_roll: float = 0.2
@export var camera_offset_y: int = 0

var trauma: float = 0.0
var trauma_power: int = 2

# following
@onready var player_node = get_parent().get_node("Player")
@export var following_player: bool = true


func _ready():
	randomize()
	global_position = player_node.global_position
	offset.y = camera_offset_y
	fix_limits()
	

func _process(delta):
	if following_player:
		global_position = player_node.global_position
	
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
	else:
		offset = Vector2(0, camera_offset_y)

func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)


func shake() -> void:
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * randf_range(-1, 1)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = camera_offset_y + max_offset.y * amount * randf_range(-1, 1)

func new_offset(value: int):
	# Change the camera offset to a new value
	camera_offset_y = value
	fix_limits()

func fix_limits():
	# This fixes the limits when the offset is changed
	# This is because camera limits use position rather than offset
	limit_top = limit_top + camera_offset_y
	limit_bottom = limit_bottom - camera_offset_y
