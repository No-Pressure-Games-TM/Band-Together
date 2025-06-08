extends Control

@onready var resolution_dropdown: OptionButton = $VBoxContainer/Resolution/ResoDropdown
@onready var wm_dropdown: OptionButton = $VBoxContainer/WindowMode/WMDropdown
@onready var return_btn: Button = $VBoxContainer/Return
@onready var reset_btn: Button = $"VBoxContainer/Reset Game"
@onready var r_u_sure_timer: Timer = $"VBoxContainer/Reset Game/AreYouSureTimer"
@onready var easy_mode_button: CheckButton = $VBoxContainer/EasyMode
@onready var speedrun_mode_button: CheckButton = $"VBoxContainer/Speedrun Mode"

func _ready():
	AudioManager._on_scene_changed(null)
	# I don't think we need the game to load upon opening settings
	#print_debug("loading...")
	#await GameManager.load_game()
	#print_debug("loaded!")
	set_dropdown_text()
	easy_mode_button.button_pressed = GameManager.easy_mode
	speedrun_mode_button.button_pressed = GameManager.speedrun_mode

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		return  # Ignore mouse movement for this
	var current_focused = get_viewport().gui_get_focus_owner()
	if current_focused == null or not current_focused is Button:
		# No button is focused. Grab focus
		reset_btn.grab_focus()
	
	# Helped create with ChatGPT
	# Check if Accept action is pressed and trigger the focused button
	if event.is_action_pressed("Accept"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused is Button:
			focused.emit_signal("pressed")  # Manually trigger button press
		
func set_dropdown_text() -> void:
	match GameManager.res_x:
		640:
			resolution_dropdown.select(0)
		1280:
			resolution_dropdown.select(1)
		1920:
			resolution_dropdown.select(2)
		2560:
			resolution_dropdown.select(3)
		3840:
			resolution_dropdown.select(4)
	
	# Prevent players from sizing larger than their monitor
	var player_res_x: int = DisplayServer.screen_get_size()[0]  # x resolution of user's monitor
	if player_res_x < 3840:
		resolution_dropdown.remove_item(4)
	if player_res_x < 2560:
		resolution_dropdown.remove_item(3)
	# Otherwise, who tf is this guy who doesnt have a 1080p monitor in the big 25
	wm_dropdown.select(GameManager.screen_mode)

func _on_reset_game_pressed():
	if reset_btn.text == "Reset Progress":
		reset_btn.text = "Are you sure?"
		r_u_sure_timer.start(10)
	elif reset_btn.text == "Are you sure?":
		reset_btn.text = "RESET (FOR REAL!)"
		r_u_sure_timer.start(10)
	elif reset_btn.text == "RESET (FOR REAL!)":
		GameManager.reset_game()

func _on_reso_dropdown_item_selected(index):
	var chosen_res: PackedStringArray = resolution_dropdown.get_item_text(index).split("x")
	var x: int = int(chosen_res[0])
	var y: int = int(chosen_res[1])
	GameManager.res_x = x  # for saving
	GameManager.res_y = y
	GameManager.set_screen_resolution()
	GameManager.save_game()
	
func _on_wm_dropdown_item_selected(index):
	GameManager.screen_mode = index
	GameManager.set_screen_mode()
	GameManager.save_game()

func _on_return_pressed():
	# Changing scenes saves the game
	SceneTransition.change_scene("res://scenes/interfaces/main_menu/main_menu.tscn")

func _on_are_you_sure_timer_timeout():
	reset_btn.text = "Reset Progress"


func _on_easy_mode_toggled(toggled_on):
	if toggled_on:
		GameManager.easy_mode = true
	else:
		GameManager.easy_mode = false
	GameManager.save_game()

func _on_speedrun_mode_toggled(toggled_on):
	if toggled_on:
		GameManager.speedrun_mode = true
	else:
		GameManager.speedrun_mode = false
	GameManager.save_game()
