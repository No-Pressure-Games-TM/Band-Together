extends RichTextLabel

var is_using_controller: bool = false
var x = "res://assets/control_icons/x.png"
var b_gamepad = "res://assets/control_icons/b_gamepad.png"

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
		append_text("Press [img]%s[/img] with drum to\ndeflect projectiles." % b_gamepad)
	else:
		append_text("Press [img]%s[/img] with drum to\ndeflect projectiles." % x)
