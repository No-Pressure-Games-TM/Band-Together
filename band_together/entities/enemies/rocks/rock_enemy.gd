extends RigidBody2D

@onready var game_manager: Node = $"../../../GameManager"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	# Enemy collision detection
	if (body.name == "Player"):
		game_manager.decrease_health()
