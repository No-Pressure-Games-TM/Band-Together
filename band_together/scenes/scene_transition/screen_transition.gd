extends Control

@onready var transition_rect: ColorRect = $CanvasLayer/TransitionRect
@onready var animation_player: AnimationPlayer = $CanvasLayer/AnimationPlayer
@onready var canvas_layer: CanvasLayer = $CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func change_scene(target_scene: String):
	 # A higher value ensures it's rendered on top of other scenes/nodes
	canvas_layer.layer = 10 
	
	animation_player.play("transition_in") 
	await animation_player.animation_finished  
	animation_player.play("transition_out")  
	get_tree().call_deferred("change_scene_to_file", target_scene)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
