extends Node2D

var direction: int = 1
@export var speed_x:= 300
@export var speed_y:= 350
@export var proj_dmg:= 4  # Made it really low cuz there's no cooldown
@export var proj_grav:= 10
var angle: float = 0
@onready var despawn_timer: float = 4.0  # despawn after 4 seconds to reduce lag

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.flip_h = direction > 0
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#pass
	despawn_timer -= delta
	if despawn_timer <= 0:
		# Die after 4 seconds to reduce lag
		queue_free()
		
func _physics_process(delta):
	position.x += speed_x * delta * direction * sin(angle)
	position.y -= speed_y * delta * cos(angle)
	speed_y -= proj_grav

# copied from jons code (hayyyy) 
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		var hit_dir = sign(body.position.x - position.x)
		body.take_damage(proj_dmg, hit_dir)
	
# Added to destroy stalactites
func _on_area_2d_area_entered(area):
	if area.get_collision_layer() == 64:
		area.get_parent().queue_free()
