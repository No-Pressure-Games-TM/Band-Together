extends AnimatedSprite2D

@onready var stalactite = preload("res://entities/projectiles/stalactite/stalactite.tscn")

func _ready():
	play() # start the animation

func _on_frame_changed():
	if frame == 3:
		# The frame was just 2
		# drop the stalactite!
		var instance = stalactite.instantiate()
		instance.global_position = global_position
		get_tree().current_scene.add_child(instance)  # make sure it's added to the scene
		$GrowNew.start() # Start the cooldown timer

func _on_grow_new_timeout():
	play()  # Start the animation again!
