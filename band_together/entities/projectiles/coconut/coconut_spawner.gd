extends Node2D

@onready var coconut = preload("res://entities/projectiles/coconut/coconut.tscn")
@export var max_spawnrate: float = 0.5  # spawn one at most every 0.5 seconds
@export var min_spawnrate: float = 1.0  # spawn one at least every 1 seconds

func _ready():
	$Timer.start()

func _on_timer_timeout():
	# Found this in this video https://www.youtube.com/watch?v=YPvPqOqbx-I
	var instance = coconut.instantiate()
	instance.spawn_pos = global_position
	get_tree().get_root().add_child.call_deferred(instance)
	$Timer.start(randf_range(max_spawnrate, min_spawnrate))
