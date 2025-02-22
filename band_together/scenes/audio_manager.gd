extends Node2D

var interface_theme_scenes = ["MainMenu", "GameOver", "Win"]  
@onready var music_player: AudioStreamPlayer2D = $MusicPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().connect("node_added", Callable(self, "_on_node_added"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _on_node_added(node: Node) -> void:
	# Check if the added node is a direct child of root (i.e., a new scene)
	if node.get_parent() == get_tree().root:
		# Wait until the next idle frame to ensure the scene is fully set up
		call_deferred("_check_current_scene", node)

func _check_current_scene(scene: Node) -> void:
	if scene.name in interface_theme_scenes:
		if not music_player.playing:
			music_player.play()
	else:
		music_player.stop()

# Global functions that can be used to change music across scenes
func play_music(stream: AudioStream):
	music_player.stream = stream
	music_player.play()

func stop_music():
	music_player.stop()
	
