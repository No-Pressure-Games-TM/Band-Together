class_name Vine
extends RigidBody2D

signal player_hit(damage: int)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D

var original_height: float = 0.0
var initial_position: Vector2
var has_hit_player: bool = false
var has_collapsed: bool = false
var is_looping: bool = false
var damage_amount: int = 1
var loop_delay: float = 3.0  # Time in seconds before resetting for next loop
var original_body_position: Vector2
var original_hitbox_position: Vector2

# Called when the node enters the scene tree
func _ready() -> void:
	setup_animation()
	connect_signals()
	
	# Store original positions and dimensions to scale the collision shape later
	store_original_dimensions()
	original_body_position = body_collision.position
	original_hitbox_position = hitbox_shape.position
	
	# Store initial position
	initial_position = global_position
	
	# Set initial physics state
	freeze = true

# Store the original collision dimensions for scaling later
func store_original_dimensions() -> void:
	if body_collision.shape is CapsuleShape2D:
		original_height = body_collision.shape.height

# Set up initial animation state
func setup_animation() -> void:
	sprite.animation = "idle"
	sprite.play()

# Connect all necessary signals
func connect_signals() -> void:
	sprite.frame_changed.connect(_on_frame_changed)
	sprite.animation_finished.connect(_on_animation_finished)
	hitbox.body_entered.connect(_on_hitbox_body_entered)

# Trigger the vine to collapse once
func trigger_collapse() -> void:
	if not has_collapsed:
		has_collapsed = true
		is_looping = false
		start_collapse()

# Trigger the vine to collapse in a loop
func trigger_collapse_loop() -> void:
	has_collapsed = false
	is_looping = true
	start_collapse()

# Start the actual collapse animation and physics
func start_collapse() -> void:
	# Reset hit detection
	has_hit_player = false
	
	# Change animation
	sprite.animation = "collapse"
	sprite.play()
	
	# Enable physics
	freeze = false

# Handle animation finished
func _on_animation_finished() -> void:
	if sprite.animation == "collapse" and is_looping:
		# Wait before resetting
		await get_tree().create_timer(loop_delay).timeout
		reset_vine()

# Reset vine to initial state
func reset_vine() -> void:
	# Reset position and physics
	global_position = initial_position
	freeze = true
	gravity_scale = 0
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	
	# Reset collision shapes
	update_single_shape(body_collision.shape, 1.0)
	update_single_shape(hitbox_shape.shape, 1.0)
	body_collision.position.y = 0
	hitbox_shape.position.y = 0
	
	# Reset animation
	sprite.animation = "idle"
	sprite.play()
	
	# Allow collapsing again
	has_collapsed = false
	has_hit_player = false
	
	# Start a new collapse if looping
	if is_looping:
		await get_tree().create_timer(1.0).timeout
		start_collapse()

# Update collision based on progress
func _on_frame_changed() -> void:
	if sprite.animation == "collapse":
		# Calculate animation progress (0.0 to 1.0)
		var frame_count = sprite.sprite_frames.get_frame_count("collapse")
		var progress = float(sprite.frame) / max(1, frame_count - 1)
		
		update_collision_shapes(progress)

# Calculate collision shape as vine grows
func update_collision_shapes(progress: float) -> void:
	# Calculate growth factor
	var growth = 1.0 + (3.0 * progress)
	
	update_single_shape(body_collision.shape, growth)
	update_single_shape(hitbox_shape.shape, growth)
	
	# We need to adjust position to grow from top
	if body_collision.shape is CapsuleShape2D:
		# Calculate the anchor point (assuming top of capsule)
		var capsule = body_collision.shape as CapsuleShape2D
		var new_height = original_height * growth
		var height_diff = new_height - original_height
		
		# Adjust position to grow downward - keep X the same
		body_collision.position.y = original_body_position.y + (height_diff / 2)
		hitbox_shape.position.y = original_hitbox_position.y + (height_diff / 2)
		
# Update a single collision shape based on its type
func update_single_shape(shape: Shape2D, growth: float) -> void:
	shape.height = original_height * growth

# Handle player collision with vine
func _on_hitbox_body_entered(body: Node2D) -> void:
	# If we want to damage the player when they hit the vine, we'd add it here!
	if body.is_in_group("Player") and sprite.animation == "collapse" and not has_hit_player:
		has_hit_player = true
		
# Stop looping if needed
func stop_loop() -> void:
	is_looping = false
