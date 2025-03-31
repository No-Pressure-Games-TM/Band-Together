extends Camera2D

# For the shake, I tried this video instead https://www.youtube.com/watch?v=JDzUjJypQ9s
var decay: float = 0.8
var max_offset: Vector2 = Vector2(100, 75)
var max_roll: float = 0.2
@export var camera_offset_y: float = 0
@export var camera_offset_x: float = 0.0
var current_offset_y: float  # Used for intermediate offset for smooth movement
var current_offset_x: float

var trauma: float = 0.0
var trauma_power: int = 2

# following
@onready var player_node = get_parent().get_node("Player")
@export var following_player: bool = true
@export var lock_x = false
@export var lock_y = false


func _ready():
	randomize()
	if following_player:
		global_position = player_node.global_position
	offset.y = camera_offset_y
	offset.x = camera_offset_x
	fix_limits(camera_offset_x, camera_offset_y)
	

func _process(delta):
	if following_player:
		if not lock_x and not lock_y:
			global_position = player_node.global_position
		elif not lock_x:
			# y is locked
			global_position.x = player_node.global_position.x
		else:
			# x is locked
			global_position.y = player_node.global_position.y
		# else both are completely locked so don't even update
	
	# smoothly move the camera if there is a new offset
	current_offset_y = lerp(current_offset_y, camera_offset_y, delta*3)
	current_offset_x = lerp(current_offset_x , camera_offset_x, delta*3)
	
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
	else:
		offset = Vector2(current_offset_x, current_offset_y)

func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)


func shake() -> void:
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * randf_range(-1, 1)
	offset.x = current_offset_x + max_offset.x * amount * randf_range(-1, 1)
	offset.y = current_offset_y + max_offset.y * amount * randf_range(-1, 1)

func new_offset(value_x, value_y):
	# Change the camera offset to a new value
	var offset_change_y = value_y - camera_offset_y
	var offset_change_x = value_x - camera_offset_x
	camera_offset_x = value_x
	camera_offset_y = value_y
	fix_limits(offset_change_x, offset_change_y)

func fix_limits(offset_change_x: float, offset_change_y: float):
	# This fixes the limits when the offset is changed
	# This is because camera limits use position rather than offset
	limit_top -= offset_change_y
	limit_bottom -= offset_change_y
	limit_left -= offset_change_x
	limit_right -= offset_change_x
