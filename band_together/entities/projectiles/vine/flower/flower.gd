class_name Flower
extends StaticBody2D

signal hit
var has_triggered: bool = false

@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	if hitbox:
		# Connect to the hitbox's body_entered signal
		hitbox.body_entered.connect(_on_hitbox_body_entered)

func _on_hitbox_body_entered(body: Node2D) -> void:
	print("Something entered flower hitbox: ", body.name)
	
	# Trigger for any body, not just player
	if not has_triggered:
		print("Flower triggered by: ", body.name)
		has_triggered = true
		hit.emit()
