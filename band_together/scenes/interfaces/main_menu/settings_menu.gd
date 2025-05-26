extends Control

@onready var resolution_dropdown: OptionButton = $VBoxContainer/Resolution/ResoDropdown
@onready var wm_dropdown: OptionButton = $VBoxContainer/WindowMode/WMDropdown
@onready var return_btn: Button = $VBoxContainer/Return
@onready var reset_btn: Button = $"VBoxContainer/Reset Game"
@onready var r_u_sure_timer: Timer = $"VBoxContainer/Reset Game/AreYouSureTimer"

func _ready():
	AudioManager._on_scene_changed(null)
	print_debug("loading...")
	await GameManager.load_game()
	print_debug("loaded!")
	set_dropdown_text()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		return  # Ignore mouse movement for this
		#
	#var current_focused = get_viewport().gui_get_focus_owner()
	#if $CreditsPanel.visible == true:
		#release_focus()
		#$CreditsPanel/CreditsText.grab_focus()
		#$CreditsPanel/CreditsText.grab_click_focus()
	#elif current_focused == null or not current_focused is Button:
		## No button is focused. Grab focus
		##start_game_btn.grab_focus()
	
	# Helped create with ChatGPT
	# Check if Accept action is pressed and trigger the focused button
	if event.is_action_pressed("Accept"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused is Button:
			focused.emit_signal("pressed")  # Manually trigger button press
	
	elif event.is_action_pressed("ui_cancel"):
		$CreditsPanel.visible = false
		$VBoxContainer.visible = true  # LOL I got frustrated with focus stuff and just added this and it worked so you can't click them behind the credits anymore
		
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
		# Reset levels progress
		GameManager.furthest_level = "res://scenes/levels/level_0.tscn"
		# Reset instruments progress
		GameManager.drum_unlocked = false
		GameManager.sax_unlocked = false
		GameManager.violin_unlocked = false
		GameManager.current_instrument = 0  # back to baton
		UI.lives = -1  # Reset lives
		UI.coins = 0  # Reset coins
		GameManager.new_game = true
		print_debug("starting save")
		await GameManager.save_game()
		print_debug("save finished")
		SceneTransition.change_scene("res://scenes/interfaces/main_menu/main_menu.tscn")


func _on_reso_dropdown_item_selected(index):
	var chosen_res: PackedStringArray = resolution_dropdown.get_item_text(index).split("x")
	var x: int = int(chosen_res[0])
	var y: int = int(chosen_res[1])
	DisplayServer.window_set_size(Vector2(x, y))
	get_window().move_to_center()
	GameManager.res_x = x  # for saving
	GameManager.res_y = y
	
func _on_wm_dropdown_item_selected(index):
	match index:
		0:  # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1:  # Borderless
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		2:  # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	GameManager.screen_mode = index

func _on_return_pressed():
	# Changing scenes saves the game
	SceneTransition.change_scene("res://scenes/interfaces/main_menu/main_menu.tscn")

func _on_are_you_sure_timer_timeout():
	reset_btn.text = "Reset Progress"
