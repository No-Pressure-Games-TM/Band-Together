extends RichTextLabel

var is_using_controller: bool = false
var q = "res://assets/control_icons/q.png"
var r_gamepad = "res://assets/control_icons/r_gamepad.png"
var e = "res://assets/control_icons/e.png"
var l_gamepad = "res://assets/control_icons/l_gamepad.png"
var scrup = "res://assets/control_icons/scroll_up.png"
var scrdown = "res://assets/control_icons/scroll_down.png"

func _ready():
	update_text()

func _input(event):
	## Used for checking what controller player is using
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if not is_using_controller:
			# Controller
			is_using_controller = true
			update_text()
	elif event is InputEventKey:
		if is_using_controller:
			# Keyboard
			is_using_controller = false
			update_text()

func update_text():
	clear()
	if is_using_controller:
		append_text("Press [img]%s[/img] [img]%s[/img] to swap\ninstruments." % [l_gamepad, r_gamepad])
	else:
		append_text("Press [img]%s[/img] [img]%s[/img] or [img]%s[/img] [img]%s[/img]\nto swap instruments." % [q, e, scrup, scrdown])
