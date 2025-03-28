extends CharacterBody2D

@export var speed: int = 50
var dir: Vector2  # The direction the bat is moving
var target_pos: Vector2

# These are the limits the bat can fly around in (global position)
@export var top_y: int = -1000000
@export var bot_y: int = -1000000
@export var left_x: int = -1000000
@export var right_x: int = -1000000
@export var wander_range: int = 128

var chasing: bool = false
@onready var start_pos = global_position
var knocked_back: bool = false

@onready var hit_flash: AnimationPlayer = $AnimatedSprite2D/HitFlash

@export var hp: float = 25.0
var spinning = false

func _ready():
	$AnimatedSprite2D.play()

func _physics_process(delta):
	if not chasing and not spinning:
		dir = target_pos - global_position
		velocity = dir.normalized() * speed
		if global_position.distance_to(target_pos) < 3.0:
			$ChangeDirection.stop()
			_on_change_direction_timeout()  # find a new location
			
	if spinning:
		rotation_degrees += 360 * delta * 2
		velocity += get_gravity() * delta
		
	move_and_slide()

func _on_change_direction_timeout():
	$ChangeDirection.wait_time = randf_range(1, 2)  # Move in a dir for this long
	if not chasing and not spinning and not knocked_back:
		# Choose random uniform new direction
		var rangex = randi_range(-wander_range, wander_range)
		var rangey = randi_range(-wander_range, wander_range)
		var posx = clamp(start_pos.x + rangex, left_x, right_x)  # ensure stays in bounds
		var posy = clamp(start_pos.y + rangey, top_y, bot_y)  # ensure stays in bounds
		target_pos = Vector2(posx, posy)
		$ChangeDirection.start()

func take_damage(amount, knockback_dir):
	hit_flash.play("flash")
	hp -= amount
	if hp <= 0:
		die(knockback_dir)
	else:
		knocked_back = true
		velocity.x = knockback_dir * 50
		$KnockbackTimer.start(0.2)
		
func die(knockback_dir):
	set_collision_layer_value(4, false)  # Remove "enemy" collision layer
	$Hitbox.set_collision_layer_value(5, false)  # Remove "hitbox" collision layer
	$Hitbox.set_collision_mask_value(2, false)  # Disable colliding with player
	
	velocity = Vector2(knockback_dir * 300, -200)
	spinning = true
	$ChangeDirection.stop()
	$DeathTimer.start()

func _on_death_timer_timeout():
	queue_free()  # Should be off screen by now, delete!

func _on_hitbox_body_entered(body):
	if body.name == "Player":
		body.take_damage(sign(body.position.x - position.x))

func _on_knockback_timer_timeout():
	knocked_back = false
