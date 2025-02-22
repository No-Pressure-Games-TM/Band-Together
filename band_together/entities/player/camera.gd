extends Camera2D

var shake_fade: float = 100.0                    # Speed of camera shake ending

var rng = RandomNumberGenerator.new()

var shake_strength: float = 0.0

func apply_shake(strength):
	# Learned this from https://www.youtube.com/watch?v=LGt-jjVf-ZU
	shake_strength = strength

func random_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength),
				   rng.randf_range(-shake_strength, shake_strength))

func set_limits(bottom_limit, top_limit, right_limit, left_limit):
	# Sets the bounds that the camera cannot go past
	limit_bottom = bottom_limit
	limit_right = right_limit
	limit_left = left_limit
	limit_top = top_limit

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		offset = random_offset()
