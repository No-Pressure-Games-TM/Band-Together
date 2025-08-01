extends Node

@onready var pause_panel: Panel = %PausePanel
@onready var resume_btn: Button = $PausePanel/VBoxContainer/Resume
@onready var hearts: Array[Node] = $Hearts/HBoxContainer.get_children()
@onready var current_weapon_display: TextureRect = $CurrentWeapon

#region weapon icons
var baton = preload("res://assets/portraits/baton.png")
var drum = preload("res://assets/portraits/drum.png")
var sax = preload("res://assets/portraits/saxophone item.PNG")
var violin = preload("res://assets/portraits/violin item.PNG")
#endregion

var not_allowed_scenes: Array[String] = ["GameOver", "Win", "MainMenu", "SettingsMenu"]
var default_lives: int = 3  # This allows us to add more hearts if we want!
var lives: int
var coins: int = 0
var startcoins: int
var starttime: float
var increment_speedrun_timer = false

func _ready():
	lives = default_lives
	reset()

func reset() -> void:
	# This is replacing the ready() function. An autoloaded scene persists across
	# scene changes, so this function needs to be called every time a scene changes
	var scene_name: String = get_tree().current_scene.name
	if scene_name in not_allowed_scenes:
		increment_speedrun_timer = false  # For speedrun timer reasons!
		print("NOT ALLOWED SCENE! NO PAUSING")
		# https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html#process-modes
		process_mode = PROCESS_MODE_DISABLED
		self.visible = false
	else:
		process_mode = PROCESS_MODE_ALWAYS  # Changed this from ALWAYS, change back if issues
		increment_speedrun_timer = true  # For speedrun timer reasons!
		self.visible = true
		if lives <= 0:
			coins = 0  # Reset coins on death
			$CoinCount.text = "x%s" % coins
			lives = default_lives
			for heart in hearts:
				heart.show()
		startcoins = coins
		starttime = GameManager.current_time
		refresh()
		print("\nScene changed. \nLives: ", lives)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:	
	match GameManager.get_current_instrument():
		"baton":
			current_weapon_display.texture = baton
		"drum":
			current_weapon_display.texture = drum
		"sax":
			current_weapon_display.texture = sax
		"violin":
			current_weapon_display.texture = violin
	# Increment the speedrun clock every frame
	if increment_speedrun_timer:
		GameManager.current_time += _delta
	if GameManager.speedrun_mode:
		$SpeedrunTimer.visible = true
		if GameManager.best_time >= 3600:
			# Longer than an hour
			$SpeedrunTimer/BestTime.text = "%02d:%02d:%02d" % GameManager.get_time(GameManager.current_time)
		else:
			$SpeedrunTimer/BestTime.text = "%02d:%02d" % [GameManager.get_time(GameManager.current_time)[1], GameManager.get_time(GameManager.current_time)[2]]
		var ms = "%.3f" % snapped(GameManager.current_time-int(GameManager.current_time), 0.001)
		$SpeedrunTimer/BestTimeMS.text = ms.substr(1)
	else:
		$SpeedrunTimer.visible = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		return  # Ignore mouse movement for this
		
	var current_focused = get_viewport().gui_get_focus_owner()
	if current_focused == null or not current_focused is Button:
		# No button is focused. Grab focus
		resume_btn.grab_focus()
	
	# Helped create with ChatGPT
	# Check if Accept action is pressed and trigger the focused button
	if event.is_action_pressed("Accept") and pause_panel.visible:
		if current_focused is Button:
			current_focused.emit_signal("pressed")  # Manually trigger button press
			get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("Pause"):
		if pause_panel.visible:
			_on_resume_pressed()  # unpause
			get_viewport().set_input_as_handled()
		else:
			increment_speedrun_timer = false  # For speedrun timer reasons!
			resume_btn.grab_focus()
			if GameManager.in_dialogue == true:
				Dialogic.Text.hide_textbox()
			get_tree().paused = true
			pause_panel.show()
			get_viewport().set_input_as_handled()

func _on_resume_pressed() -> void:
	await get_tree().create_timer(0.05).timeout  # This is because player was jumping when unpausing
	increment_speedrun_timer = true  # For speedrun timer reasons!
	pause_panel.hide()
	get_tree().paused = false
	if GameManager.in_dialogue == true:
		Dialogic.Text.show_textbox()


func _on_main_menu_pressed() -> void:
	await get_tree().create_timer(0.05).timeout  # Slight delay to stop jumping
	get_tree().paused = false
	pause_panel.hide()
	if GameManager.in_dialogue:
		Dialogic.end_timeline()
	GameManager.current_time = starttime  # Set the time back if they quit the level
	coins = startcoins  # coins were not resetting properly on reset or death
	SceneTransition.change_scene("res://scenes/interfaces/main_menu/main_menu.tscn")

func decrease_health():
	$DamageSound.play()
	
	if not GameManager.easy_mode:
		# Only decreate health if not in easy mode
		lives -= 1
	
	# Show only the number of hearts equal to 'lives', hide the rest
	for i in range(len(hearts)):
		hearts[i].visible = i < lives
	
	if coins >= 50 and lives < 3:
		# get a new life! Currently bonus hearts not implemented
		lives += 1
		coins -= 50  # subtract coins
		for i in range(len(hearts)):
			hearts[i].visible = i < lives
		$HealSound.play()
		$CoinCount.text = "x%s" % coins
		
		
	if (lives == 0):
		print("Game Over.\n")
		coins = startcoins  # coins were not resetting properly on reset or death
		SceneTransition.change_scene("res://scenes/interfaces/game_over/game_over.tscn")
	else: 
		print("Lives: ", lives)


func _on_reset_pressed():
	var current_scene = get_tree().current_scene
	await get_tree().create_timer(0.05).timeout  # Slight delay to stop jumping
	get_tree().paused = false
	pause_panel.hide()
	if current_scene.name == "Level11":
		GameManager.drum_unlocked = false  # Reset drum unlocked state if this level
		GameManager.current_instrument = 0  # Reset to baton
	coins = startcoins  # coins were not resetting properly on reset or death
	SceneTransition.change_scene(current_scene.scene_file_path)

func get_coin():
	coins += 1
	$CoinSound.play()
	if coins >= 50 and lives < 3:
		# get a new life! Currently bonus hearts not implemented
		lives += 1
		coins -= 50  # subtract coins
		for i in range(len(hearts)):
			hearts[i].visible = i < lives
		$HealSound.play()
		$CoinCount.text = "x%s" % coins
	$CoinCount.text = "x%s" % coins
	
func refresh():
	# I made this function because hearts and coins looked wrong with save system
	for i in range(len(hearts)):
		hearts[i].visible = i < lives
	$CoinCount.text = "x%s" % coins
