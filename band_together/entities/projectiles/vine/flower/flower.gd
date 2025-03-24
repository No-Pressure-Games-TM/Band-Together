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
	# Don't trigger if the flower was hit by an enemy
	if body.is_in_group("enemy"):
		print("Flower hit by enemy - ignoring")
		return
	
	# Trigger for any body, not just player
	if not has_triggered:
		print("Flower triggered by: ", body.name)
		has_triggered = true
		hit.emit()
