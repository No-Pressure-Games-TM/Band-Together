extends Camera2D

var random_strength: float = 30.0               # Strength of camera shake
var shake_fade: float = 100.0                    # Speed of camera shake ending

var rng = RandomNumberGenerator.new()

var shake_strength: float = 0.0

func apply_shake():
	# Learned this from https://www.youtube.com/watch?v=LGt-jjVf-ZU
	shake_strength = random_strength

func random_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength),
				   rng.randf_range(-shake_strength, shake_strength))

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		offset = random_offset()
