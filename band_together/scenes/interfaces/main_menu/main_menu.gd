extends Control

@onready var start_game_btn: Button = $VBoxContainer/StartGame

func _ready():
	#AudioManager.play_music(AudioManager.music_player.stream)
	AudioManager._on_scene_changed(null)
	print_debug("loading...")
	await GameManager.load_game()
	print_debug("loaded!")
	
	# Set window visual settings
	if FileAccess.file_exists("user://savegame.save"):
		# Save game file exists to pull data from. If not, do not call this (use defaults)
		GameManager.set_screen_resolution()
		GameManager.set_screen_mode()
	
	var window_size = DisplayServer.window_get_size()
	var screen_size = DisplayServer.screen_get_size()
	if window_size.x < 400 or window_size.y < 300 or window_size.x > screen_size.x or window_size.y > screen_size.y:
		# Reset to safe default (thanks chatgpt
		GameManager.res_x = 1280
		GameManager.res_y = 720
		GameManager.screen_mode = 0
		GameManager.set_screen_resolution()
		GameManager.set_screen_mode()
	
	if GameManager.new_game:
		start_game_btn.text = "New Game"
	else:
		start_game_btn.text = "Continue"
	if GameManager.speedrun_mode:
		$SpeedrunTimer.visible = true
		if GameManager.best_time == -1.0:
			# Not gotten a best time yet
			$SpeedrunTimer/BestTime.text = "--:--"
			$SpeedrunTimer/BestTimeMS.text = ".---"
		elif GameManager.best_time >= 3600:
			# Longer than an hour
			$SpeedrunTimer/BestTime.text = "%02d:%02d:%02d" % GameManager.get_time(GameManager.best_time)
		else:
			$SpeedrunTimer/BestTime.text = "%02d:%02d" % [GameManager.get_time(GameManager.best_time)[1], GameManager.get_time(GameManager.best_time)[2]]
		if GameManager.best_time != -1.0:
			var ms = "%.3f" % snapped(GameManager.best_time-int(GameManager.best_time), 0.001)
			$SpeedrunTimer/BestTimeMS.text = ms.substr(1)
	else:
		$SpeedrunTimer.visible = false
	
	# This next part fixes the bug where player gets stuck when quitting during dialogues
	# I really hope this doesn't create more bugs lol
	GameManager.in_dialogue = false
	GameManager.current_instrument = 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		return  # Ignore mouse movement for this
		
	var current_focused = get_viewport().gui_get_focus_owner()
	if $CreditsPanel.visible == true:
		release_focus()
		$CreditsPanel/CreditsText.grab_focus()
		$CreditsPanel/CreditsText.grab_click_focus()
	elif current_focused == null or not current_focused is Button:
		# No button is focused. Grab focus
		start_game_btn.grab_focus()
	
	# Helped create with ChatGPT
	# Check if Accept action is pressed and trigger the focused button
	if event.is_action_pressed("Accept"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused is Button:
			focused.emit_signal("pressed")  # Manually trigger button press
	
	elif event.is_action_pressed("ui_cancel"):
		$CreditsPanel.visible = false
		$VBoxContainer.visible = true  # LOL I got frustrated with focus stuff and just added this and it worked so you can't click them behind the credits anymore

func _on_start_pressed() -> void:
	if GameManager.new_game:
		SceneTransition.change_scene("res://scenes/beginning.tscn")
	else:
		SceneTransition.change_scene(GameManager.furthest_level)
	#SceneTransition.change_scene("res://scenes/levels/level2/level2_2.tscn")
	#SceneTransition.change_scene("res://scenes/test/test_walljump.tscn")
	
func _on_options_pressed() -> void:
	SceneTransition.change_scene("res://scenes/interfaces/main_menu/settings_menu.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_reset_game_pressed():
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
	SceneTransition.change_scene(get_tree().current_scene.scene_file_path)

func _on_credits_pressed():
	$CreditsPanel.visible = true
	$CreditsPanel/CreditsText.grab_focus()
	$VBoxContainer.visible = false  # LOL I got frustrated with focus stuff and just added this and it worked so you can't click them behind the credits anymore
