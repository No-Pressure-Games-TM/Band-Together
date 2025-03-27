extends Camera2D

# For the shake, I tried this video instead https://www.youtube.com/watch?v=JDzUjJypQ9s
@export var decay: float = 0.8
@export var max_offset: Vector2 = Vector2(100, 75)
@export var max_roll: float = 0.2
@export var left_limit: int = -10000000        # Camera left limit (px)
@export var right_limit: int = 10000000        # Camera right limit (px)
@export var top_limit: int = -10000000         # Camera top limit (px)
@export var bottom_limit: int = 10000000        # Camera bottom limit (px)
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
	set_limits(bottom_limit, top_limit, right_limit, left_limit)
	

func _process(delta):
	if following_player:
		global_position = player_node.global_position
	
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()


func set_limits(bottom_limit, top_limit, right_limit, left_limit):
	# Sets the bounds that the camera cannot go past
	limit_bottom = bottom_limit
	limit_right = right_limit
	limit_left = left_limit
	limit_top = top_limit


func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)


func shake() -> void:
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * randf_range(-1, 1)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)
