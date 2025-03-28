extends RigidBody2D

var dir: Vector2

@onready var start_pos = global_position
var knocked_back: bool = false

@onready var hit_flash: AnimationPlayer = $AnimatedSprite2D/HitFlash

@export var hp: float = 40.0

func _ready():
	$AnimatedSprite2D.play()
	apply_impulse(Vector2.RIGHT * 200)  # start pendulum movement

func _physics_process(delta):
	if abs(angular_velocity) < 0.5:
		apply_torque_impulse(50*sign(angular_velocity))
		apply_impulse(30*sign(angular_velocity)*Vector2.LEFT)

func take_damage(amount, knockback_dir):
	hit_flash.play("flash")
	hp -= amount
	if hp <= 0:
		die(knockback_dir)
	else:
		knocked_back = true
		apply_impulse(Vector2(-knockback_dir*400, 0))
		$KnockbackTimer.start(0.2)
		
func die(knockback_dir):
	set_collision_layer_value(4, false)  # Remove "enemy" collision layer
	set_collision_mask_value(3, false)  # Stop hitting terrain
	$Hitbox.set_collision_layer_value(5, false)  # Remove "hitbox" collision layer
	$Hitbox.set_collision_mask_value(2, false)  # Disable colliding with player
	get_parent().find_child("SpiderJoint").node_b = ""  # Disconnect node so it flies away
	apply_impulse(Vector2(-knockback_dir*400, -400))
	$DeathTimer.start()

func _on_death_timer_timeout():
	queue_free()  # Should be off screen by now, delete!

func _on_hitbox_body_entered(body):
	print("ENTERED")
	if body.name == "Player":
		body.take_damage(sign(body.position.x - position.x))

func _on_knockback_timer_timeout():
	knocked_back = false
