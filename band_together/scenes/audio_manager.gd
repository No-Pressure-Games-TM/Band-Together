extends Node2D

var INTERFACE_THEME_SCENES: Array[String] = ["MainMenu", "Pause", "GameOver", "Win"]  
const FADE_DURATION: float = 1.0  # Duration of fade in seconds

@onready var music_player: AudioStreamPlayer2D = $MusicPlayer
@onready var tween: Tween

var current_music: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().connect("node_added", Callable(self, "_on_scene_changed"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _on_scene_changed(scene: Node) -> void:
	if scene.get_parent() == get_tree().root:
		if scene.name in INTERFACE_THEME_SCENES:
			if current_music != music_player.stream:
				play_music(music_player.stream)
		else:
			stop_music()
			
			
# Global functions that can be used across scenes to control music
func play_music(stream: AudioStream) -> void:
	if stream == current_music and music_player.playing:
		return

	if music_player.playing:
		fade_out()
		await tween.finished
	
	current_music = stream
	music_player.stream = stream
	music_player.volume_db = -80  # Start from silent
	music_player.play()
	fade_in()

func stop_music() -> void:
	if music_player.playing:
		fade_out()
		await tween.finished
		music_player.stop()
		current_music = null

func fade_in() -> void:
	tween = create_tween()
	tween.tween_property(music_player, "volume_db", 0, FADE_DURATION)

func fade_out() -> void:
	tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80, FADE_DURATION)

func set_music_for_scene(scene_name: String, stream: AudioStream) -> void:
	if scene_name in INTERFACE_THEME_SCENES:
		if get_tree().current_scene.name == scene_name:
			play_music(stream)
		else:
			current_music = stream
	
