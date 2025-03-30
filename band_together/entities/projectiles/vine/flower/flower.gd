class_name Flower
extends StaticBody2D

signal hit
var has_triggered: bool = false
@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_entered)
		hitbox.area_entered.connect(_on_hitbox_entered)
	else:
		print("Flower: Hitbox not found!")

func _on_hitbox_entered(entity: Node2D) -> void:
	if has_triggered:
		print("Flower: Already triggered, ignoring")
		return

	var triggerer: Node2D = entity if entity is CharacterBody2D else entity.get_parent()
	
	# Check if the triggerer is the flower itself or one of its children
	if triggerer == self or triggerer.is_ancestor_of(self):
		return

	if triggerer.is_in_group("enemy"):
		print("Flower: Entity is an enemy, not triggering")
		return

	_trigger_hit(triggerer.name)

func _trigger_hit(triggerer_name: String) -> void:
	print("Flower: Triggered by ", triggerer_name)
	has_triggered = true
	hit.emit()
