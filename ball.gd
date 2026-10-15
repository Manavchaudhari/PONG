extends CharacterBody2D
## Pong ball. Bounces off walls, gets launched by the knight's sword.

enum Hitter { NONE, PLAYER, ENEMY }

@export var start_speed: float = 550.0
## Speed added every time the player hits the ball.
@export var speed_up_per_hit: float = 25.0
@export var max_speed: float = 1200.0
## Steepest angle (degrees) the sword can send the ball at.
@export var max_bounce_angle: float = 55.0
## Half the sword hitbox height — keep in sync with the sword's CollisionShape2D.
@export var sword_half_height: float = 60.0

## Who touched the ball last. Power-ups only count when this is PLAYER.
var last_hitter: Hitter = Hitter.NONE
var speed: float = 0.0
var _spawn_position: Vector2


func _ready() -> void:
	_spawn_position = global_position
	reset()


func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())

	# Temporary until goals exist (Day 3): ball left the screen → respawn.
	if global_position.x < -50.0 or global_position.x > 1330.0:
		reset()


func reset() -> void:
	global_position = _spawn_position
	speed = start_speed
	last_hitter = Hitter.NONE
	# Serve toward the player with a small random angle.
	var angle := deg_to_rad(randf_range(-30.0, 30.0))
	velocity = Vector2(-cos(angle), sin(angle)) * speed


## Called by the sword. Where the ball meets the blade decides the angle:
## top of the blade sends it up, middle sends it straight, bottom sends it down.
func hit_by_player(sword_center_y: float) -> void:
	var offset: float = clamp((global_position.y - sword_center_y) / sword_half_height, -1.0, 1.0)
	var angle: float = deg_to_rad(offset * max_bounce_angle)
	speed = min(speed + speed_up_per_hit, max_speed)
	velocity = Vector2(cos(angle), sin(angle)) * speed  # always to the right
	last_hitter = Hitter.PLAYER
