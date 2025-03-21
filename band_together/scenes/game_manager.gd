extends Node

var instruments_list: Array[String] = ["baton", "drum", "sax", "violin"]
var drum_unlocked: bool = false
var sax_unlocked: bool = false
var violin_unlocked: bool = true
var current_instrument: int = 0  # Array index of instruments_list

# rudimentary saving system in case players die
var furthest_level: String = "res://scenes/levels/level_0.tscn"
var last_ground_position: Vector2 = Vector2.ZERO

# dialogic
var in_dialogue: bool = false

func _ready():
	Dialogic.signal_event.connect(dialogic_signal_end)  # 17 minutes in, https://www.youtube.com/watch?v=Tmy1tzhDLl4&ab_channel=DevWorm

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

func save_ground_position(pos: Vector2) -> void:
	last_ground_position = pos

func get_last_ground_position() -> Vector2:
	return last_ground_position
	
func start_dialogue(dialogue_name: String):
	# Start a dialogue. Pause the rest of the game
	in_dialogue = true
	Dialogic.start(dialogue_name)

func dialogic_signal_end(arg: String):
	# This is where we choose what happens at the end of dialogs
	# for example if arg == "test_dialog": do this
	in_dialogue = false
