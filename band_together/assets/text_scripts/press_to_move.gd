extends RichTextLabel

var is_using_controller: bool = false
var left = "res://assets/control_icons/a.png"
var left_gamepad = "res://assets/control_icons/left_gamepad.png"
var right = "res://assets/control_icons/d.png"
var right_gamepad = "res://assets/control_icons/right_gamepad.png"
var a_gamepad = "res://assets/control_icons/a_gamepad.png"

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
		append_text("Press [img]%s[/img] [img]%s[/img] to move.\nPress [img]%s[/img] to jump.\nHold [img]%s[/img] to jump higher." % [left_gamepad, right_gamepad, a_gamepad, a_gamepad])
	else:
		append_text("Press [img]%s[/img] [img]%s[/img] to move.\nPress SPACE to jump.\nHold SPACE to jump higher." % [left, right])
