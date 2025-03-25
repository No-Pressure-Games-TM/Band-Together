extends Area2D

@onready var start_pos: Vector2 = position
var time_elapsed: float = 0.0

@export var bob_speed: float = 2.0  # The rate at which the pickup moves up and down
@export var bob_height: int = 0  # The number of pixels the thing bobs up an down
@export var coin_code: String = "0"

func _ready():
	if coin_code != "0":
		visible = false  # Make invisible if it has a code
		$CollisionShape2D.disabled = true
	if is_in_group("coin"):
		$AnimatedSprite2D.play("default")
		
func enable():
	visible = true
	$CollisionShape2D.disabled = false

func _process(delta):
	time_elapsed += delta
	global_position.y = start_pos.y + sin(time_elapsed * bob_speed) * bob_height

func _on_body_entered(body):
	if body.name == "Player":
		if name == "DrumPickup":
			GameManager.drum_unlocked = true
			GameManager.current_instrument = 1  # Force set instrument to "drum"
			# Show tutorials
			get_parent().get_node("PressToDoubleJump").visible = true
			get_parent().get_node("PressToSwap").visible = true
			# Change camera bounds
			body.camera.set_limits(body.bottom_limit, body.top_limit, 592, body.left_limit)
			queue_free()  # Remove drum from the game cuz it's picked up
			GameManager.start_dialogue("finddrum")
		
		elif is_in_group("coin"):
			UI.get_coin()
			# play a sound here
			queue_free()
			
