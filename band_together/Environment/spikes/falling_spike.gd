extends Area2D

# Configuration variables
@export var is_falling_spike: bool = true
@export var fall_speed: float = 300.0
@export var fall_trigger_distance: float = 60.0
@export var trigger_delay: float = 0.5
@export var warning_time: float = 0.5
@export var reset_time: float = 2.0
@export var respawn_delay: float = 1.0

# State tracking variables
var player = null
var original_position: Vector2
var is_falling: bool = false
var has_hit: bool = false
var is_warning: bool = false
var is_delaying: bool = false
var warning_timer: float = 0.0
var delay_timer: float = 0.0
var reset_timer: float = 0.0
var respawn_timer: float = 0.0
var fall_gravity: float = 980.0

func _ready():
	# Store original position
	original_position = global_position
	
	# Find player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	
	# Setup detection area
	_setup_detection_area()

func _setup_detection_area():
	if has_node("DetectionArea"):
		return
	
	var area = Area2D.new()
	area.name = "DetectionArea"
	add_child(area)
	
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(fall_trigger_distance * 2, 500)
	shape.shape = rect
	shape.position = Vector2(0, 250)
	area.add_child(shape)
	
	area.body_entered.connect(_on_detection_area_body_entered)

func _on_detection_area_body_entered(body):
	if body.is_in_group("player") and not is_falling and not has_hit and not is_warning and not is_delaying:
		_start_fall_sequence()

func _start_fall_sequence():
	is_delaying = true
	delay_timer = 0.0
	modulate = Color(0.9, 0.9, 1.1)

func _physics_process(delta):
	# Try to find player if not found
	if player == null and Engine.get_frames_drawn() % 60 == 0:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]
	
	# Direct detection backup
	if player and not is_falling and not has_hit and not is_warning and not is_delaying:
		var x_distance = abs(player.global_position.x - global_position.x)
		var player_is_below = player.global_position.y > global_position.y
		
		if x_distance < fall_trigger_distance and player_is_below:
			_start_fall_sequence()
	
	# Delay phase
	if is_delaying:
		delay_timer += delta
		scale = Vector2(0.95 + sin(delay_timer * 3) * 0.05, 0.95 + sin(delay_timer * 3) * 0.05)
		
		if delay_timer >= trigger_delay:
			is_delaying = false
			is_warning = true
			warning_timer = 0.0
			modulate = Color(1, 0.5, 0.5)
			scale = Vector2(1, 1)
	
	# Warning phase
	elif is_warning:
		warning_timer += delta
		position.x = original_position.x + sin(warning_timer * 30) * 2
		
		if warning_timer >= warning_time:
			is_warning = false
			is_falling = true
			modulate = Color(1, 1, 1)
			position.x = original_position.x
	
	# Falling phase
	elif is_falling:
		position.y += fall_speed * delta
		fall_speed += fall_gravity * delta
	
	# Reset phase - after hit
	elif has_hit:
		reset_timer += delta
		
		if reset_timer >= reset_time:
			# Reset position and state
			global_position = original_position
			has_hit = false
			is_falling = false
			fall_speed = 300.0
			reset_timer = 0.0
			
			# Start respawn timer
			respawn_timer = 0.0
	
	# Respawn phase
	elif respawn_timer > 0.0:
		respawn_timer += delta
		
		if respawn_timer >= respawn_delay:
			# Start falling again
			respawn_timer = 0.0
			_start_fall_sequence()

func _on_body_entered(body):
	if has_hit:
		return
	
	# Player collision
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			var dir = sign(body.position.x - position.x)
			body.take_damage(dir)
		
		if body.has_method("respawn"):
			body.respawn()
		
		_spike_hit()
	
	# Enemy collision
	elif body.is_in_group("enemy") and body.has_method("take_damage"):
		var dir = sign(body.position.x - position.x)
		body.take_damage(10000, dir)
		_spike_hit()
	
	# Ground/wall collision
	elif body is StaticBody2D or body.is_in_group("ground") or body.is_in_group("platform"):
		if is_falling:
			_spike_hit()

func _spike_hit():
	if is_falling_spike:
		has_hit = true
		is_falling = false
		modulate = Color(1.2, 1.2, 1.2)
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 1, 1), 0.2)
		
		# Start reset timer
		reset_timer = 0.0
