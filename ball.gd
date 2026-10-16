extends CharacterBody2D
## Pong ball. Bounces off floor/ceiling. The knight's sword and the enemy launch it.

enum Hitter { NONE, PLAYER, ENEMY }

@export var start_speed: float = 550.0
## Speed added every time the player hits the ball.
@export var speed_up_per_hit: float = 25.0
@export var max_speed: float = 1200.0
## Steepest angle (degrees) a hit can send the ball at.
@export var max_bounce_angle: float = 55.0
## Half the sword hitbox height — keep in sync with the sword's CollisionShape2D.
@export var sword_half_height: float = 60.0
## Half the enemy hitbox height — keep in sync with the enemy's CollisionShape2D.
@export var enemy_half_height: float = 60.0
## Pause before each serve, so the player can get ready.
@export var serve_delay: float = 0.8

## Who touched the ball last. Power-ups only count when this is PLAYER.
var last_hitter: Hitter = Hitter.NONE
var speed: float = 0.0
var _spawn_position: Vector2


func _ready() -> void:
	add_to_group("ball")  # lets the enemy find the ball without a hard-coded path
	_spawn_position = global_position
	reset()


func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())

	# Safety net only: goals should catch the ball long before this.
	if global_position.x < -300.0 or global_position.x > 1580.0:
		reset()


## Put the ball back in the middle, wait, then serve toward the player.
func reset() -> void:
	global_position = _spawn_position
	velocity = Vector2.ZERO
	speed = start_speed
	last_hitter = Hitter.NONE
	await get_tree().create_timer(serve_delay).timeout
	var angle := deg_to_rad(randf_range(-30.0, 30.0))
	velocity = Vector2(-cos(angle), sin(angle)) * speed


## Freeze the ball (used when the match ends).
func stop() -> void:
	velocity = Vector2.ZERO
	set_physics_process(false)


## Called by the sword. Top of the blade sends it up, middle straight, bottom down.
func hit_by_player(sword_center_y: float) -> void:
	speed = min(speed + speed_up_per_hit, max_speed)
	_launch(1.0, global_position.y - sword_center_y, sword_half_height)
	last_hitter = Hitter.PLAYER


## Called by the enemy. Same angle rule, but sends the ball left.
func hit_by_enemy(enemy_center_y: float) -> void:
	_launch(-1.0, global_position.y - enemy_center_y, enemy_half_height)
	last_hitter = Hitter.ENEMY


## direction_x: 1 = right, -1 = left. offset/half_height gives -1 (top) .. 1 (bottom).
func _launch(direction_x: float, offset: float, half_height: float) -> void:
	velocity = Helpers.angled_velocity(direction_x, offset, half_height, max_bounce_angle, speed)
