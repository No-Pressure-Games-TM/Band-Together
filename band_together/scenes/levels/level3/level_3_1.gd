extends Node2D

@onready var flower: Flower = $Flower
@onready var vine: Vine = $Vine

func _ready() -> void:
	if GameManager.violin_unlocked:
		$ViolinPickup.queue_free()  # Remove violin from the game cuz it's picked up
		$WallJumpTip.visible = true
		$WallJumpTip2.visible = true
		GameManager.show_coins("violin")
	vine.setup_animation("expanded")
	if flower and vine:
		flower.hit.connect(vine.trigger_retract)
