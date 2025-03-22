extends Node2D

var direction: int = 1
@export var speed:= 300
var angle: float = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.flip_h = direction > 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#pass
	position.x += speed * delta * direction * sin(angle)
	position.y -= speed * delta * cos(angle)
