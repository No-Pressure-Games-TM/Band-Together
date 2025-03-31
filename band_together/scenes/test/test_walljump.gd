extends Node2D

@onready var flower: Flower = $Flower
@onready var vine_1: Vine = $Vine
@onready var vine_2: Vine = $Vine2
@onready var vine_3: Vine = $Vine3

#-------------------------------------------------------------------------------
# Vine Use Case Examples
#-------------------------------------------------------------------------------
func _ready() -> void:
	if flower and vine_1 and vine_2 and vine_3:
		# Step 1: State initial animation state; "idle" is set by default
		vine_3.setup_animation("expanded") # Explicitly state when not "idle"
		
		# Step 2: Connect the flower's "hit" signal to different vine behaviors
		# Example 1: Simple collapse
		# When the flower is hit, vine_1 will collapse once
		flower.hit.connect(vine_1.trigger_collapse)
		
		# Example 2: Looping collapse
		# When the flower is hit, vine_2 will repeatedly collapse and reset
		flower.hit.connect(vine_2.trigger_collapse_loop)
		
		# Example 3: Retraction
		# When the flower is hit, vine_3 will retract (opposite of collapse)
		flower.hit.connect(vine_3.trigger_retract)
	
