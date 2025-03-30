class_name Vine
extends RigidBody2D

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
var loop_delay: float = 3.0                   # Time between collapse cycles

#-------------------------------------------------------------------------------
# State Tracking
#-------------------------------------------------------------------------------
var has_collapsed: bool = false               # Whether vine is currently collapsed
var is_looping: bool = false                  # Whether vine should loop collapse
var is_retracting: bool = false               # Whether vine is currently retracting
var is_expanded: bool = false                 # Whether vine is in expanded state

#-------------------------------------------------------------------------------
# Initialization
#-------------------------------------------------------------------------------
func _ready() -> void:
	store_original_dimensions()
	original_body_position = body_collision.position
	original_hitbox_position = hitbox_shape.position
	initial_position = global_position
	setup_animation()  # Start with idle animation by default
	connect_signals()
	freeze = true

func store_original_dimensions() -> void:
	if not dimensions_stored:
		if body_collision.shape is CapsuleShape2D:
			true_original_height = body_collision.shape.height
		dimensions_stored = true
	if body_collision.shape is CapsuleShape2D:
		original_height = true_original_height

func setup_animation(animation: String = "idle") -> void:
	sprite.animation = animation
	sprite.play()
	has_collapsed = (animation == "expanded")
	is_expanded = (animation == "expanded")
	
	var growth = 4.0 if animation == "expanded" else 1.0
	
	if body_collision.shape is CapsuleShape2D:
		body_collision.shape.height = original_height * growth
	if hitbox_shape.shape is CapsuleShape2D:
		hitbox_shape.shape.height = original_height * growth
	
	var height_diff = (original_height * growth) - original_height
	body_collision.position.y = original_body_position.y + (height_diff / 2)
	hitbox_shape.position.y = original_hitbox_position.y + (height_diff / 2)

func connect_signals() -> void:
	sprite.frame_changed.connect(_on_frame_changed)
	sprite.animation_finished.connect(_on_animation_finished)

#-------------------------------------------------------------------------------
# External Methods
#-------------------------------------------------------------------------------
func trigger_collapse() -> void:
	if not has_collapsed and not is_retracting:
		has_collapsed = true
		is_looping = false
		start_collapse()

func trigger_collapse_loop() -> void:
	if not is_retracting:
		has_collapsed = false
		is_looping = true
		start_collapse()

func stop_loop() -> void:
	is_looping = false

func trigger_retract() -> void:
	if has_collapsed and not is_retracting:
		start_retract()

#-------------------------------------------------------------------------------
# Internal Collapse Logic
#-------------------------------------------------------------------------------
func start_collapse() -> void:
	sprite.animation = "collapse"
	sprite.play()
	freeze = false
	is_expanded = false

func start_retract() -> void:
	sprite.animation = "retract"
	sprite.play()
	freeze = true
	is_retracting = true
	has_collapsed = false

func reset_vine() -> void:
	global_position = initial_position
	freeze = true
	gravity_scale = 0
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	setup_animation("expanded")
	is_retracting = true
	has_collapsed = false

func complete_reset() -> void:
	setup_animation("idle")
	is_retracting = false
	is_expanded = false
	if is_looping:
		await get_tree().create_timer(loop_delay).timeout
		start_collapse()

#-------------------------------------------------------------------------------
# Collision Shape Management
#-------------------------------------------------------------------------------
func update_collision_shapes(progress: float, grow: bool) -> void:
	var growth
	if grow:
		growth = 1.0 + (3.0 * progress)  # Grow from 1x to 4x
	else:
		growth = 4.0 - (3.0 * progress)  # Shrink from 4x to 1x
	
	if body_collision.shape is CapsuleShape2D:
		body_collision.shape.height = original_height * growth
	if hitbox_shape.shape is CapsuleShape2D:
		hitbox_shape.shape.height = original_height * growth
	
	var height_diff = (original_height * growth) - original_height
	body_collision.position.y = original_body_position.y + (height_diff / 2)
	hitbox_shape.position.y = original_hitbox_position.y + (height_diff / 2)

#-------------------------------------------------------------------------------
# Signal Handlers
#-------------------------------------------------------------------------------
func _on_frame_changed() -> void:
	if sprite.animation == "collapse":
		var frame_count = sprite.sprite_frames.get_frame_count("collapse")
		var progress = float(sprite.frame) / max(1, frame_count - 1)
		update_collision_shapes(progress, true)
	elif sprite.animation == "retract":
		var frame_count = sprite.sprite_frames.get_frame_count("retract")
		var progress = float(sprite.frame) / max(1, frame_count - 1)
		update_collision_shapes(progress, false)

func _on_animation_finished() -> void:
	if sprite.animation == "collapse":
		freeze = true
		has_collapsed = true
		is_expanded = false
		if is_looping:
			await get_tree().create_timer(loop_delay).timeout
			reset_vine()
	elif sprite.animation == "retract":
		complete_reset()
