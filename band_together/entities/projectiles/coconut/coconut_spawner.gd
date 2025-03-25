extends Node2D

@onready var coconut = preload("res://entities/projectiles/coconut/coconut.tscn")
@export var max_spawnrate: float = 0.5  # spawn one at most every 0.5 seconds
@export var min_spawnrate: float = 1.0  # spawn one at least every 1 seconds
@export var grow_time: float = 0  # The time it takes to spawn the object
@export var moving: bool = false  # Enable to make it slide left and right!
@export var sliderange: float = 50.0
@export var slidespeed: float = 1

var start_position: Vector2
var time: float = 0

func _ready():
	start_position = position
	$Timer.start()

func _process(delta):
	time += delta * slidespeed
	if moving:
		position.x = start_position.x + sin(time) * sliderange

func _on_timer_timeout():
	# Found this in this video https://www.youtube.com/watch?v=YPvPqOqbx-I
	var instance = coconut.instantiate()
	instance.spawn_pos = global_position
	instance.grow_time = grow_time
	if moving:
		instance.grav_div = 8
	get_tree().get_root().add_child.call_deferred(instance)
	$Timer.start(grow_time + randf_range(max_spawnrate, min_spawnrate))
