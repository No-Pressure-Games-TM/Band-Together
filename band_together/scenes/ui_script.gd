extends Node

@onready var pause_panel: Panel = %PausePanel
@onready var resume_btn: Button = $PausePanel/VBoxContainer/Resume
@onready var hearts: Array[Node] = $Hearts/HBoxContainer.get_children()
@onready var current_weapon_display: TextureRect = $CurrentWeapon

#region weapon icons
var baton = preload("res://assets/portraits/baton.png")
var drum = preload("res://assets/portraits/drum.png")
#endregion

var not_allowed_scenes: Array[String] = ["GameOver", "Win", "MainMenu"]
var default_lives: int = 3  # This allows us to add more hearts if we want!
var lives: int

func _ready():
	lives = default_lives
	reset()  # This is only called once. The first time anything in the game loads.

func reset() -> void:
	# This is replacing the ready() function. An autoloaded scene persists across
	# scene changes, so this function needs to be called every time a scene changes
	print("scene name: " +get_tree().current_scene.name)
	var scene_name: String = get_tree().current_scene.name
	if scene_name in not_allowed_scenes:
		print("NOT ALLOWED SCENE! NO PAUSING")
		# https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html#process-modes
		process_mode = PROCESS_MODE_DISABLED
		self.visible = false
	else:
		process_mode = PROCESS_MODE_ALWAYS
		self.visible = true
		if lives <= 0:
			lives = default_lives
			for heart in hearts:
				heart.show()
		print("\nScene changed. \nLives: ", lives)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:	
	# Pause screen logic
	var esc_pressed = Input.is_action_just_pressed("Pause")
	
	if (esc_pressed):
		resume_btn.grab_focus()
		get_tree().paused = true
		pause_panel.show()
	
	match GameManager.get_current_instrument():
		"baton":
			current_weapon_display.texture = baton
		"drum":
			current_weapon_display.texture = drum
		"sax":
			pass
		"violin":
			pass

func _input(event: InputEvent) -> void:
	# Helped create with ChatGPT
	# Check if Accept action is pressed and trigger the focused button
	if event.is_action_pressed("Accept") and pause_panel.visible:
		var focused = get_viewport().gui_get_focus_owner()
		if focused is Button:
			focused.emit_signal("pressed")  # Manually trigger button press
			get_viewport().set_input_as_handled()

func _on_resume_pressed() -> void:
	await get_tree().create_timer(0.05).timeout  # This is because player was jumping when unpausing
	pause_panel.hide()
	get_tree().paused = false


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	pause_panel.hide()
	SceneTransition.change_scene("res://scenes/interfaces/main_menu/main_menu.tscn")

func decrease_health():
	lives -= 1
	# Show only the number of hearts equal to 'lives', hide the rest
	for i in range(len(hearts)):
		hearts[i].visible = i < lives
		
	if (lives == 0):
		print("Game Over.\n")
		SceneTransition.change_scene("res://scenes/interfaces/game_over/game_over.tscn")
	else: 
		print("Lives: ", lives)
