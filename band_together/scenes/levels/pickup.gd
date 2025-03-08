extends Area2D

@onready var start_pos: Vector2 = position
var time_elapsed: float = 0.0

@export var bob_speed: float = 2.0  # The rate at which the pickup moves up and down
@export var bob_height: int = 4  # The number of pixels the thing bobs up an down

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
		# elif is_in_group("Healthpickup"):
			# ^ Idea for adding health pickups
