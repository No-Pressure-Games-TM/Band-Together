extends Node2D

func _ready() -> void:
	# Get references
	var flower = $Flower
	var vine = $Vine
	var player = $Player
	
	# Connect for one-time collapse
	if flower and vine:
		flower.hit.connect(vine.trigger_collapse_loop)
		# Or for repeatable:
		# flower.hit.connect(vine.trigger_collapse_repeatable)
	
	# Connect damage
	if vine and player:
		vine.player_hit.connect(func(damage): player.take_damage(1))
	
	# Enable manual testing with key press
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
func _process(delta: float) -> void:
	# For testing: Press R to manually reset the vine
	if Input.is_action_just_pressed("ui_home"): # Home key
		$Vine._reset_vine()
