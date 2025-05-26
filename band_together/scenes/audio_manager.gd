extends Node2D

var INTERFACE_THEME_SCENES: Array[String] = ["GameOver"] 
var TITLE_THEME_SCENES: Array[String] = ["MainMenu", "SettingsMenu"]
var BEGINNING_CUTSCENE: Array[String] = ["Beginning"]
const FADE_DURATION: float = 1.0  # Duration of fade in seconds
var BEACH_SCENES: Array[String] = ["Level11", "Level12", "Level13" , "Level1End", "Level0", "Ending"]
var FOREST_SCENES: Array[String] = ["Level21", "Level22", "Level23" , "Level2End"]
var CAVE_SCENES: Array[String] = ["Level31", "Level32", "Level3_3", "Level3End"]

const NORMAL_VOL: int = 10
const ACTIVE_VOL: int = 15
const INACTIVE_VOL: int= -80
var active_scene: String = "Beach"

@onready var music_player: AudioStreamPlayer2D = $MusicPlayer
@onready var tween: Tween

var current_music: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().connect("node_added", Callable(self, "_on_scene_changed"))
	
func _on_scene_changed(scene: Node) -> void:
	#When first booting up game
	if scene == null:
		$TitleTheme.play()
		return
		
	adjust_volumes()
	if scene.get_parent() == get_tree().root:
		
		if scene.name in BEGINNING_CUTSCENE or scene.name in TITLE_THEME_SCENES or scene.name in INTERFACE_THEME_SCENES or scene.name in BEACH_SCENES or scene.name in CAVE_SCENES or scene.name in FOREST_SCENES:
			$Cave/Baton.stop()
			$Cave/Drum.stop()
			$Cave/Sax.stop()
			$Cave/Violin.stop()
			$Beach/Baton.stop()
			$Beach/Drum.stop()
			$Beach/Sax.stop()
			$Beach/Violin.stop()
			$Forest/Baton.stop()
			$Forest/Drum.stop()
			$Forest/Sax.stop()
			$Forest/Violin.stop()
			$Cutscenes/IntroCutscene.stop()
			$TitleTheme.stop()
		if scene.name in INTERFACE_THEME_SCENES:
			if current_music != music_player.stream:
				play_music(music_player.stream)
		elif scene.name == "MainMenu":
			stop_music()
			$TitleTheme.play()
		elif scene.name == "Beginning":
			stop_music()
			$Cutscenes/IntroCutscene.play()
		else:
			stop_music()
			#not an interface, do the music gavens way :3
			if scene.name in CAVE_SCENES:
				$Cave/Baton.play()
				$Cave/Drum.play()
				$Cave/Sax.play()
				$Cave/Violin.play()
				active_scene = "Cave"
				adjust_volumes_cave()
				
			if scene.name in BEACH_SCENES:
				$Beach/Baton.play()
				$Beach/Drum.play()
				$Beach/Sax.play()
				$Beach/Violin.play()
				active_scene = "Beach"
				adjust_volumes_beach()
				
			if scene.name in FOREST_SCENES:
				$Forest/Baton.play()
				$Forest/Drum.play()
				$Forest/Sax.play()
				$Forest/Violin.play()
				active_scene = "Forest"
				adjust_volumes_forest()
			
			
			
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
			

	
func adjust_volumes() -> void:
	if active_scene == "Beach":
		adjust_volumes_beach()
	if active_scene == "Forest":
		adjust_volumes_forest()
	if active_scene == "Cave":
		adjust_volumes_cave();
			
func adjust_volumes_beach() -> void:
	if GameManager.get_current_instrument() == "baton":
		$Beach/Baton.volume_db = ACTIVE_VOL
	else:
		$Beach/Baton.volume_db = NORMAL_VOL

	if GameManager.get_current_instrument() == "sax":
		$Beach/Sax.volume_db = ACTIVE_VOL
	elif GameManager.sax_unlocked:
		$Beach/Sax.volume_db = NORMAL_VOL
	else:
		$Beach/Sax.volume_db = INACTIVE_VOL

	if GameManager.get_current_instrument() == "drum":
		$Beach/Drum.volume_db = ACTIVE_VOL
	elif GameManager.drum_unlocked:
		$Beach/Drum.volume_db = NORMAL_VOL
	else:
		$Beach/Drum.volume_db = INACTIVE_VOL

	if GameManager.get_current_instrument() == "violin":
		$Beach/Violin.volume_db = ACTIVE_VOL
	elif GameManager.violin_unlocked:
		$Beach/Violin.volume_db = NORMAL_VOL
	else:
		$Beach/Violin.volume_db = INACTIVE_VOL

		
func adjust_volumes_forest() -> void:
	if GameManager.get_current_instrument() == "baton":
		$Forest/Baton.volume_db = ACTIVE_VOL
	else:
		$Forest/Baton.volume_db = NORMAL_VOL

	if GameManager.get_current_instrument() == "sax":
		$Forest/Sax.volume_db = ACTIVE_VOL
	elif GameManager.sax_unlocked:
		$Forest/Sax.volume_db = NORMAL_VOL
	else:
		$Forest/Sax.volume_db = INACTIVE_VOL

	if GameManager.get_current_instrument() == "drum":
		$Forest/Drum.volume_db = ACTIVE_VOL
	elif GameManager.drum_unlocked:
		$Forest/Drum.volume_db = NORMAL_VOL
	else:
		$Forest/Drum.volume_db = INACTIVE_VOL

	if GameManager.get_current_instrument() == "violin":
		$Forest/Violin.volume_db = ACTIVE_VOL
	elif GameManager.violin_unlocked:
		$Forest/Violin.volume_db = NORMAL_VOL
	else:
		$Forest/Violin.volume_db = INACTIVE_VOL

	
func adjust_volumes_cave() -> void:
	if GameManager.get_current_instrument() == "baton":
		$Cave/Baton.volume_db = ACTIVE_VOL
	else:
		$Cave/Baton.volume_db = NORMAL_VOL
	
	if GameManager.get_current_instrument() == "sax":
		$Cave/Sax.volume_db = ACTIVE_VOL
	elif GameManager.sax_unlocked:
		$Cave/Sax.volume_db = NORMAL_VOL
	else:
		$Cave/Sax.volume_db = INACTIVE_VOL
	
	if GameManager.get_current_instrument() == "drum":
		$Cave/Drum.volume_db = ACTIVE_VOL
	elif GameManager.drum_unlocked:
		$Cave/Drum.volume_db = NORMAL_VOL
	else:
		$Cave/Drum.volume_db = INACTIVE_VOL
	
	if GameManager.get_current_instrument() == "violin":
		$Cave/Violin.volume_db = ACTIVE_VOL
	elif GameManager.violin_unlocked:
		$Cave/Violin.volume_db = NORMAL_VOL
	else:
		$Cave/Violin.volume_db = INACTIVE_VOL
	
