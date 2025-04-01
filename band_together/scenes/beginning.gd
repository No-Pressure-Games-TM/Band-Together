extends Node2D

@export var wait_before_dialogue: float = 3

func _ready():
	$AnimatedSprite2D.play("default")
	UI.get_node("CoinCount").visible = false
	UI.get_node("CurrentWeapon").visible = false
	UI.get_node("CoinIcon").visible = false
	UI.get_node("Hearts").visible = false

func _physics_process(delta):
	if wait_before_dialogue > 0:
		wait_before_dialogue -= delta
		if wait_before_dialogue <= 0:
			GameManager.start_dialogue("introcutscene")
