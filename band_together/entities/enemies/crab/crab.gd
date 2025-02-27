extends CharacterBody2D

# I FOLLOWED THIS TUTORIAL
# https://www.youtube.com/watch?v=P02PcfgqrY8&ab_channel=GameDevKnight
## Set to 1 if you want it to move right at the start
@export var direction: int = -1
@export var speed: float = 40.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast: RayCast2D = $RayCast2D
@onready var hit_flash: AnimationPlayer = $AnimatedSprite2D/HitFlash

var stopped: bool = false

@export var hp: float = 20.0
var knocked_back: bool = false
var spinning = false

func _ready():
	$StopMoving.wait_time = randf_range(2.5, 4)  # Walk for random time length
	$StopMoving.start()
	sprite.play("walk")
	if direction > 0:
		sprite.flip_h = !sprite.flip_h
		raycast.position.x *= -1

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if not knocked_back:
		if (not raycast.is_colliding() and is_on_floor()) or is_on_wall():
			flip()
	
		if stopped:
			if sprite.animation != "idle":
				sprite.play("idle")
			velocity.x = 0  # stop moving!
		else:
			if sprite.animation != "walk":
				sprite.play("walk")
			velocity.x = direction * speed
	move_and_slide()

func _process(delta):
	# This part makes the crab do those cute lil bounces :p
	if (sprite.frame == 2 or sprite.frame == 5) and sprite.animation == "walk" and velocity.x > 0:
		sprite.position.y = 2
	else:
		sprite.position.y = 0
	
	if spinning:
		rotation_degrees += 360 * delta * 2

func flip():
	direction = -direction
	sprite.flip_h = !sprite.flip_h
	raycast.position.x *= -1  # Flip the raycast to the other side
	
func take_damage(amount, knockback_dir):
	hit_flash.play("flash")
	hp -= amount
	if hp <= 0:
		die(knockback_dir)
	else:
		knocked_back = true
		velocity.x = knockback_dir * 50
		velocity.y = -100
		$KnockbackTimer.start(0.2)
		

func die(knockback_dir):
	set_collision_layer_value(4, false)  # Remove "enemy" collision layer
	set_collision_mask_value(3, false)  # Disable colliding with the environment
	$Hitbox.set_collision_layer_value(5, false)  # Remove "hitbox" collision layer
	$Hitbox.set_collision_mask_value(2, false)  # Disable colliding with player
	knocked_back = true  # This means it will not move with it's normal pathing
	
	velocity = Vector2(knockback_dir * 300, -200)
	spinning = true
	$DeathTimer.start()

func _on_hitbox_body_entered(body):
	if body.name == "Player":
		body.take_damage(sign(body.position.x - position.x))
		flip()  # makes it so player cannot stay in the hitbox

func _on_stop_moving_timeout():
	if stopped:
		# we want to start moving
		$StopMoving.wait_time = randf_range(2.5, 4)  # Walk for random time length
	else:
		# we want to stop moving
		$StopMoving.wait_time = randf_range(0.5, 1.5)
	stopped = !stopped
	$StopMoving.start()  # Reset the timer
		
func _on_knockback_timer_timeout():
	knocked_back = false

func _on_death_timer_timeout():
	queue_free()  # Should be off screen by now, delete!
