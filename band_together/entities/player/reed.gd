extends Node2D

var direction: int = 1
@export var speedx:= 300
@export var speedy:= 350
var angle: float = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.flip_h = direction > 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#pass
	position.x += speedx * delta * direction * sin(angle)
	position.y -= speedy * delta * cos(angle)
	speedy -= 10


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("hi!")
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		var hit_dir = sign(body.position.x - position.x)
		body.take_damage(10, hit_dir)
	
