extends CharacterBody2D

@export var blue_ghost: bool = false
@export var yellow_ghost: bool = false
@export var orange_ghost: bool = false
@export var player_node: CharacterBody2D
@export var moving: bool = false

var target_pos: Vector2
var follow_range: float = 5.0  # 5 pixels
var follow_speed: float = 111.0

func _ready():
	if blue_ghost:
		$AnimatedSprite2D.play("blue")
	elif yellow_ghost:
		$AnimatedSprite2D.play("yellow")
	else:
		# orange or unspecified
		$AnimatedSprite2D.play("orange")
	
	# Try to find player if not already set
	if player_node == null:
		player_node = find_player()
		
# Attempt to find the player if not set in editor

func find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player_node = players[0]
		return player_node

	print("Ghost couldn't find player! Will try again next frame.")
	return null

func _physics_process(delta):
	if moving:
		if player_node.find_child("AnimatedSprite2D").flip_h:
			# player is facing left
			target_pos = player_node.global_position + Vector2(25, 0)
		else:
			target_pos = player_node.global_position - Vector2(25,0)
		var direction = target_pos - global_position
		var distance = direction.length()
		
		if direction.x < 0:
			# player is left of ghost
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
		
		if distance > follow_range:
			# do not move in y direction
			velocity.x = direction.normalized().x * follow_speed
		else:
			velocity = Vector2.ZERO
		
		# I dont need to care about gravity, it's a ghost!
		move_and_slide()
