extends RichTextLabel

var is_using_controller: bool = false
var z = "res://assets/control_icons/z.png"
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
		append_text("Press [img]%s[/img] in the air\nto double jump." % a_gamepad)
	else:
		append_text("Press [img]%s[/img] in the air\nto double jump." % z)
