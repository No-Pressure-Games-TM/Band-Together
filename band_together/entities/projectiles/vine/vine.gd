class_name Vine
extends RigidBody2D

#-------------------------------------------------------------------------------
# Signals
#-------------------------------------------------------------------------------
signal player_hit(damage: int)

#-------------------------------------------------------------------------------
# Node References
#-------------------------------------------------------------------------------
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D

#-------------------------------------------------------------------------------
# Persistent Data (survives scene reloads)
#-------------------------------------------------------------------------------
static var true_original_height: float = 0.0  # Original height stored once for all vines
static var dimensions_stored: bool = false    # Whether dimensions have been stored yet

#-------------------------------------------------------------------------------
# Instance Properties
#-------------------------------------------------------------------------------
var original_height: float = 0.0              # This instance's copy of the height
var initial_position: Vector2                 # Starting position
var original_body_position: Vector2           # Original collision shape position
var original_hitbox_position: Vector2         # Original hitbox position
var damage_amount: int = 1                    # Damage dealt to player
var loop_delay: float = 3.0                   # Time between collapse cycles

#-------------------------------------------------------------------------------
# State Tracking
#-------------------------------------------------------------------------------
var has_hit_player: bool = false              # Prevents multiple hits in one collapse
var has_collapsed: bool = false               # Whether vine is currently collapsed
var is_looping: bool = false                  # Whether vine should loop collapse

#-------------------------------------------------------------------------------
# Initialization
#-------------------------------------------------------------------------------

# Called when the node enters the scene tree
func _ready() -> void:
	# Initialize basic components
	setup_animation()
	connect_signals()
	
	# Handle dimension storage and scene reload detection
	store_original_dimensions()
	
	# Store initial positions
	original_body_position = body_collision.position
	original_hitbox_position = hitbox_shape.position
	initial_position = global_position
	
	# Handle scene reload case
	if dimensions_stored:
		# Reset collision shapes if this is a reload
		if body_collision.shape is CapsuleShape2D:
			body_collision.shape.height = original_height
		if hitbox_shape.shape is CapsuleShape2D:
			hitbox_shape.shape.height = original_height
		
		# Reset positions
		body_collision.position = original_body_position
		hitbox_shape.position = original_hitbox_position
	
	# Start frozen
	freeze = true

# Store the initial capsule height for later resets
func store_original_dimensions() -> void:
	# First-time storage for any vine
	if not dimensions_stored:
		if body_collision.shape is CapsuleShape2D:
			true_original_height = body_collision.shape.height
			dimensions_stored = true
	
	# Always copy to this instance
	if body_collision.shape is CapsuleShape2D:
		original_height = true_original_height

# Set up initial animation state
func setup_animation() -> void:
	sprite.animation = "idle"
	sprite.play()

# Connect all necessary signals
func connect_signals() -> void:
	sprite.frame_changed.connect(_on_frame_changed)
	sprite.animation_finished.connect(_on_animation_finished)
	hitbox.body_entered.connect(_on_hitbox_body_entered)

#-------------------------------------------------------------------------------
# Public API
#-------------------------------------------------------------------------------

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

# Stop the vine from looping
func stop_loop() -> void:
	is_looping = false

#-------------------------------------------------------------------------------
# Internal Collapse Logic
#-------------------------------------------------------------------------------

# Start the actual collapse animation and physics
func start_collapse() -> void:
	# Reset hit detection
	has_hit_player = false
	
	# Change animation
	sprite.animation = "collapse"
	sprite.play()
	
	# Enable physics
	freeze = false

# Reset vine to initial state
func reset_vine() -> void:
	# Reset position and physics
	global_position = initial_position
	freeze = true
	gravity_scale = 0
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	
	# Reset collision shapes size
	if body_collision and body_collision.shape is CapsuleShape2D:
		body_collision.shape.height = original_height
	if hitbox_shape and hitbox_shape.shape is CapsuleShape2D:
		hitbox_shape.shape.height = original_height
	
	# Reset positions to original values
	if body_collision:
		body_collision.position = original_body_position
	if hitbox_shape:
		hitbox_shape.position = original_hitbox_position
	
	# Reset animation
	sprite.animation = "idle"
	sprite.play()
	
	# Reset state flags
	has_collapsed = false
	has_hit_player = false
	
	# Handle looping if needed
	if is_looping:
		await get_tree().create_timer(1.0).timeout
		start_collapse()

#-------------------------------------------------------------------------------
# Collision Shape Management
#-------------------------------------------------------------------------------

# Update a single collision shape based on its type
func update_single_shape(shape: Shape2D, growth: float) -> void:
	if shape is CapsuleShape2D:
		shape.height = original_height * growth

# Update both collision shapes based on animation progress
func update_collision_shapes(progress: float) -> void:
	# Calculate growth factor
	var growth = 1.0 + (3.0 * progress)
	
	# Update shape sizes
	update_single_shape(body_collision.shape, growth)
	update_single_shape(hitbox_shape.shape, growth)
	
	# Adjust positions to grow downward from top
	if body_collision.shape is CapsuleShape2D:
		var new_height = original_height * growth
		var height_diff = new_height - original_height
		
		# Keep X position the same, only adjust Y to grow downward
		body_collision.position.y = original_body_position.y + (height_diff / 2)
		hitbox_shape.position.y = original_hitbox_position.y + (height_diff / 2)

#-------------------------------------------------------------------------------
# Signal Handlers
#-------------------------------------------------------------------------------

# Updates collision shape when animation frame changes
func _on_frame_changed() -> void:
	if sprite.animation == "collapse":
		# Calculate animation progress (0.0 to 1.0)
		var frame_count = sprite.sprite_frames.get_frame_count("collapse")
		var progress = float(sprite.frame) / max(1, frame_count - 1)
		update_collision_shapes(progress)

# Handles animation completion
func _on_animation_finished() -> void:
	if sprite.animation == "collapse" and is_looping:
		# Wait before resetting
		await get_tree().create_timer(loop_delay).timeout
		reset_vine()

# Detects when player is hit by vine, in case we want to add damage
func _on_hitbox_body_entered(body: Node2D) -> void:
	# Only trigger for players during collapse animation
	if body.is_in_group("Player") and sprite.animation == "collapse" and not has_hit_player:
		has_hit_player = true
