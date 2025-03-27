extends Control

@onready var transition_rect: ColorRect = $CanvasLayer/TransitionRect
@onready var animation_player: AnimationPlayer = $CanvasLayer/AnimationPlayer
@onready var canvas_layer: CanvasLayer = $CanvasLayer
var transitioning: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func change_scene(target_scene: String):
	 # A higher value ensures it's rendered on top of other scenes/nodes
	transitioning = true
	canvas_layer.layer = 10 
	var old_scene = get_tree().current_scene
	
	animation_player.play("transition_in") 
	await animation_player.animation_finished  
	animation_player.play("transition_out")
	get_tree().call_deferred("change_scene_to_file", target_scene)
	
	while get_tree().current_scene == null or get_tree().current_scene == old_scene:
		await get_tree().process_frame  # Wait 1 frame for assignment
	UI.reset()
	transitioning = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
