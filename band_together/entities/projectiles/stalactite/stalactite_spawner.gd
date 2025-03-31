extends AnimatedSprite2D

@onready var stalactite = preload("res://entities/projectiles/stalactite/stalactite.tscn")
@export var wait_to_start: float = 0  # How long to wait before dropping
@export var wait_between: float = 1  # How long to wait between dropping
var started: bool = false

func _ready():
	if wait_to_start == 0:
		play() # start the animation
		started = true
		
func _process(delta):
	if not started:
		wait_to_start -= delta
		if wait_to_start <= 0:
			play()
			started = true

func _on_frame_changed():
	if frame == 3:
		# The frame was just 2
		# drop the stalactite!
		var instance = stalactite.instantiate()
		instance.global_position = global_position
		get_tree().current_scene.add_child(instance)  # make sure it's added to the scene
		$GrowNew.start(wait_between) # Start the cooldown timer

func _on_grow_new_timeout():
	play()  # Start the animation again!
