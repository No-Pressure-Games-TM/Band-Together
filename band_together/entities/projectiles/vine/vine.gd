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
	initial_position = global_position
	original_body_position = body_collision.position
	original_hitbox_position = hitbox_shape.position
	if body_collision.shape is CapsuleShape2D:
		original_height = body_collision.shape.height
	setup_animation("idle")
	connect_signals()
	set_deferred("freeze", true)

func setup_animation(animation: String = "idle") -> void:
	sprite.animation = animation
	sprite.play()
	has_collapsed = (animation == "expanded")
	is_expanded = (animation == "expanded")
	
	var growth = 4.0 if animation == "expanded" else 1.0
	update_collision_shapes(growth)

func connect_signals() -> void:
	sprite.frame_changed.connect(_on_frame_changed)
	sprite.animation_finished.connect(_on_animation_finished)

#-------------------------------------------------------------------------------
# External Methods
#-------------------------------------------------------------------------------
func trigger_collapse() -> void:
	print("Vine: trigger_collapse called")
	if not has_collapsed and not is_retracting:
		has_collapsed = true
		is_looping = false
		start_collapse()

func trigger_collapse_loop() -> void:
	print("Vine: trigger_collapse_loop called")
	if not is_retracting:
		has_collapsed = false
		is_looping = true
		start_collapse()

func stop_loop() -> void:
	print("Vine: stop_loop called")
	is_looping = false

func trigger_retract() -> void:
	print("Vine: trigger_retract called")
	if has_collapsed and not is_retracting:
		start_retract()

#-------------------------------------------------------------------------------
# Internal Collapse Logic
#-------------------------------------------------------------------------------
func start_collapse() -> void:
	print("Vine: start_collapse called")
	sprite.animation = "collapse"
	sprite.play()
	set_deferred("freeze", false)
	is_expanded = false
	

func start_retract() -> void:
	sprite.animation = "retract"
	sprite.play()
	set_deferred("freeze", true)
	is_retracting = true
	has_collapsed = false

func reset_vine() -> void:
	global_position = initial_position
	set_deferred("freeze", true)
	set_deferred("gravity_scale", 0)
	set_deferred("linear_velocity", Vector2.ZERO)
	set_deferred("angular_velocity", 0)
	setup_animation("retract")
	is_retracting = false
	has_collapsed = true
	is_expanded = true

func complete_reset() -> void:
	setup_animation("idle")
	is_retracting = false
	is_expanded = false
	has_collapsed = false
	if is_looping:
		print("Vine: Looping, waiting ", loop_delay, " seconds")
		await get_tree().create_timer(loop_delay).timeout
		start_collapse()

#-------------------------------------------------------------------------------
# Collision Shape Management
#-------------------------------------------------------------------------------
func update_collision_shapes(growth: float) -> void:
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
		var progress = float(sprite.frame) / max(1, sprite.sprite_frames.get_frame_count("collapse") - 1)
		update_collision_shapes(1.0 + (3.0 * progress))
	elif sprite.animation == "retract":
		var progress = float(sprite.frame) / max(1, sprite.sprite_frames.get_frame_count("retract") - 1)
		update_collision_shapes(4.0 - (3.0 * progress))

func _on_animation_finished() -> void:
	if sprite.animation == "collapse":
		# Freeze vine in collapsed state
		set_deferred("freeze", true)
		
		# If looping, wait then reset
		if is_looping:
			# Wait before resetting (full cycle)
			await get_tree().create_timer(loop_delay).timeout
			reset_vine()
	
	elif sprite.animation == "retract":
		# Only happens for looping vines that are retracting
		complete_reset()
