extends CharacterBody2D

var hp: float = 14  # 1 baton hit or 2 drum hits kill
var spinning = false
@onready var hit_flash: AnimationPlayer = $AnimatedSprite2D/HitFlash

func _ready():
	$AnimatedSprite2D.play("default")

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if spinning:
		rotation_degrees += 360 * delta * 2

func take_damage(amount, knockback_dir):
	hit_flash.play("flash")
	hp -= amount
	
	if hp <= 0:
		die(knockback_dir)
	else:
		velocity.y = -100  # do a little hop to look good when hit

func die(knockback_dir):
	set_collision_layer_value(4, false)  # Remove "enemy" collision layer
	set_collision_mask_value(3, false)  # Disable colliding with the environment
	$Hitbox.set_collision_layer_value(5, false)  # Remove "hitbox" collision layer
	$Hitbox.set_collision_mask_value(2, false)  # Disable colliding with player
	
	velocity = Vector2(knockback_dir * 100, -200)
	spinning = true
	$DeathTimer.start()

func _on_hitbox_body_entered(body):
	if body.name == "Player":
		body.take_damage(sign(body.position.x - position.x))

func _on_death_timer_timeout():
	queue_free()  # Should be off screen by now, delete!
