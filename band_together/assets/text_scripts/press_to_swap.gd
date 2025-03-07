extends RichTextLabel

var is_using_controller: bool = false
var s = "res://assets/control_icons/s.png"
var r_gamepad = "res://assets/control_icons/r_gamepad.png"
var a = "res://assets/control_icons/a.png"
var l_gamepad = "res://assets/control_icons/l_gamepad.png"
var scrup = "res://assets/control_icons/scroll_up.png"
var scrdown = "res://assets/control_icons/scroll_down.png"

func _ready():
	update_text(is_using_controller)

func _input(event):
	## Used for checking what controller player is using
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if not is_using_controller:
			# Controller
			is_using_controller = true
			update_text(is_using_controller)
	elif event is InputEventKey:
		if is_using_controller:
			# Keyboard
			is_using_controller = false
			update_text(is_using_controller)

func update_text(is_using_controller: bool):
	clear()
	if is_using_controller:
		append_text("Press [img]%s[/img] [img]%s[/img] to swap\ninstruments." % [l_gamepad, r_gamepad])
	else:
		append_text("Press [img]%s[/img] [img]%s[/img] or [img]%s[/img] [img]%s[/img]\nto swap instruments." % [a, s, scrup, scrdown])
