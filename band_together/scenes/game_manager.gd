extends Node

var instruments_list: Array[String] = ["baton", "drum", "sax", "violin"]
@onready var drum_unlocked: bool = false
@onready var sax_unlocked: bool = false
@onready var violin_unlocked: bool = false
var current_instrument: int = 0  # Array index of instruments_list

# rudimentary saving system in case players die
@onready var furthest_level: String = "res://scenes/levels/level_0.tscn"
var last_ground_position: Vector2 = Vector2.ZERO
@onready var new_game: bool = true

# dialogic
var in_dialogue: bool = false
var current_dialogue: String = ""

# saved settings (default values)
@onready var res_x: int = 1920  # horizontal resolution
@onready var res_y: int = 1080  # vertical resolution
@onready var screen_mode: int = 1  # 0,1,2 == windowed,borderless,fullscreen

# fun modes
@onready var speedrun_mode: bool = false
@onready var current_time: float = 0.0
@onready var best_time: float = -1.0
@onready var easy_mode: bool = false

## NEW SAVING SYSTEM
# https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html
func save_game():
	var save_data: Dictionary = {
		"drum_unlocked" : drum_unlocked,
		"sax_unlocked": sax_unlocked,
		"violin_unlocked": violin_unlocked,
		"current_health" : UI.lives,
		"current_money" : UI.coins,
		"current_room" : furthest_level,
		"is_new_game" : new_game,
		"res_x" : res_x,
		"res_y" : res_y,
		"screen_mode" : screen_mode,
		"speedrun_mode" : speedrun_mode,
		"easy_mode" : easy_mode,
		"current_time" : current_time,
		"best_time" : best_time
	}
	var save_file : FileAccess = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var json_string : String = JSON.stringify(save_data)
	save_file.store_line(json_string)
	
func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return  # nothing to load, no save yet
	
	var save_file : FileAccess = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		
		var json = JSON.new()
		
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
			
		var save_data = json.data
		drum_unlocked = save_data["drum_unlocked"]
		sax_unlocked = save_data["sax_unlocked"]
		violin_unlocked = save_data["violin_unlocked"]
		UI.lives = save_data["current_health"]
		UI.coins = save_data["current_money"]
		furthest_level = save_data["current_room"]
		new_game = save_data["is_new_game"]
		var screen_size = DisplayServer.screen_get_size()
		res_x = clamp(save_data["res_x"], 640, screen_size.x)
		res_y = clamp(save_data["res_y"], 480, screen_size.y)
		speedrun_mode = save_data["speedrun_mode"]
		easy_mode = save_data["easy_mode"]
		current_time = save_data["current_time"]
		best_time = save_data["best_time"]

func show_coins(code: String):
	# Show all pickups with the given code
	for coin in get_tree().get_nodes_in_group("coin"):
		if coin.coin_code == code:
			coin.enable()

func get_current_instrument() -> String:
	return instruments_list[current_instrument]
	
## Cycles through instruments based on cycle_dir (1 for right, -1 for left)
func set_current_instrument(cycle_dir: int) -> void:
	# Sets the value of current_instrument to an array index for the instrument
	# to equip. Checks if instrument is unlocked then adjusts
	var new_instrument: int = current_instrument
	for i in range(4):
		# Could have used a while loop, but this is guaranteed faster!
		new_instrument = (new_instrument + cycle_dir + 4) % 4
		# ^ +4 because godot modulo doesn't work on negatives ??
		if is_instrument_unlocked(new_instrument):
			current_instrument = new_instrument
			break  # Do not keep cycling if instrument is good
		# Else we want to keep cycling left or right until we have an unlocked!

## Helper for set_current_instrument, returns if instrument at index is unlocked
func is_instrument_unlocked(index: int) -> bool:
	match index:
		0:
			return true
		1:
			return drum_unlocked
		2:
			return sax_unlocked
		3:
			return violin_unlocked
		_:
			print_debug("is_instrument_unlocked: index greater than 3 or less than 0. How did you even get here?")
			return false

func get_time(seconds: float):
	# Note that int() truncates so it rounds down (ignore decimals)
	var hours = int(seconds/3600)
	var mins = int((seconds/60))%60
	var secs = int(seconds)%60
	return [hours, mins, secs]
	
func set_screen_mode():
	match screen_mode:
		0:  # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1:  # Borderless
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		2:  # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func set_screen_resolution():
	var screen_size = DisplayServer.screen_get_size()
	var clamped_x = min(res_x, screen_size.x)
	var clamped_y = min(res_y, screen_size.y)
	DisplayServer.window_set_size(Vector2(clamped_x, clamped_y))
	get_window().move_to_center()

func save_ground_position(pos: Vector2) -> void:
	last_ground_position = pos

func get_last_ground_position() -> Vector2:
	return last_ground_position
	
func start_dialogue(dialogue_name: String):
	# Start a dialogue. Pause the rest of the game
	in_dialogue = true
	current_dialogue = dialogue_name
	Dialogic.start(dialogue_name)

func dialogic_signal_end():
	# This is where we choose what happens at the end of dialogs
	# Only need to add a case if you want something to happen at end of dialogue
	var do_breve_finaltime : bool = false
	match current_dialogue:
		"door1":
			furthest_level = "res://scenes/levels/level1/level1_1.tscn"
			SceneTransition.change_scene("res://scenes/levels/level1/level1_1.tscn")
		"finddrum":
			show_coins("1")
		"findviolin":
			show_coins("violin")
		"findarco":
			get_tree().current_scene.find_child("Arco").moving = true
		"findforte":
			get_tree().current_scene.find_child("Forte").moving = true
		"findbreve":
			get_tree().current_scene.find_child("Breve").moving = true
		"ending":
			UI.increment_speedrun_timer = false
			if current_time < best_time or best_time == -1.0:
				best_time = current_time  # RUN OVER BABYYY
			get_tree().current_scene.get_node("CanvasModulate/AnimationPlayer").play("fade_to_black")
			await get_tree().create_timer(5).timeout
			if not speedrun_mode:
				UI.get_node("CoinCount").visible = true
				UI.get_node("CurrentWeapon").visible = true
				UI.get_node("CoinIcon").visible = true
				UI.get_node("Hearts").visible = true
				reset_game()
			else:
				do_breve_finaltime = true
		"breve_finaltime":
			UI.get_node("CoinCount").visible = true
			UI.get_node("CurrentWeapon").visible = true
			UI.get_node("CoinIcon").visible = true
			UI.get_node("Hearts").visible = true
			reset_game()
		"introcutscene":
			new_game = false
			SceneTransition.change_scene("res://scenes/levels/level_0.tscn")
			UI.get_node("CoinCount").visible = true
			UI.get_node("CurrentWeapon").visible = true
			UI.get_node("CoinIcon").visible = true
			UI.get_node("Hearts").visible = true
	current_dialogue = ""
	await get_tree().create_timer(0.05).timeout  # Slight delay to stop jumping
	in_dialogue = false
	if do_breve_finaltime:
		start_dialogue("breve_finaltime")

func reset_game():
	# Reset levels progress
	furthest_level = "res://scenes/levels/level_0.tscn"
	# Reset instruments progress
	drum_unlocked = false
	sax_unlocked = false
	violin_unlocked = false
	current_instrument = 0  # back to baton
	UI.lives = -1  # Reset lives
	UI.coins = 0  # Reset coins
	new_game = true
	current_time = 0.0
	print_debug("starting save")
	await GameManager.save_game()
	print_debug("save finished")
	SceneTransition.change_scene("res://scenes/interfaces/main_menu/main_menu.tscn")

## Leaving this here in case I ever want to try to make it work, sad :(
#func update_font() -> void:
	#var font: Font
	#if ez_font:
		#font = load("res://assets/Swansea.ttf")
	#else:
		#font = load("res://assets/GrapeSoda.ttf")
	#ProjectSettings.set_setting("gui/theme/custom_font", font)
	#if get_tree().root.theme == null:
		#get_tree().root.theme = Theme.new()
	#var updated_theme = get_tree().root.theme.duplicate()
	#updated_theme.default_font = font
	## Thanks for this next part, chatgpt <3
	#var control_classes = ["Label", "Button", "CheckButton", "OptionButton", "RichTextLabel", "LineEdit"]
	#for node_name in control_classes:
		#updated_theme.set_font("font", node_name, font)
	#get_tree().root.theme = updated_theme
