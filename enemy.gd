extends Area2D
## Flying enemy paddle. Every `reaction_time` seconds it decides where to go,
## then flies there at `max_speed`. These three numbers ARE the difficulty.

## How fast it can fly (pixels per second). Higher = harder.
@export var max_speed: float = 320.0
## How often it re-reads the ball's position. Lower = harder.
@export var reaction_time: float = 0.25
## Random miss added to its target (pixels). Lower = harder.
@export var aim_error: float = 40.0
## Keeps the enemy inside the arena (its center can't go past these).
@export var min_y: float = 100.0
@export var max_y: float = 620.0
## Where it drifts back to when the ball is moving away.
@export var rest_y: float = 360.0

var _ball: CharacterBody2D
var _target_y: float = 360.0
var _think_timer: float = 0.0


func _ready() -> void:
	_ball = get_tree().get_first_node_in_group("ball")
	_target_y = rest_y


func _physics_process(delta: float) -> void:
	_think_timer -= delta
	if _think_timer <= 0.0:
		_think_timer = reaction_time
		_choose_target()

	global_position.y = move_toward(global_position.y, _target_y, max_speed * delta)
	global_position.y = clamp(global_position.y, min_y, max_y)

	# Only hit the ball while it is coming toward us, so it can't be hit twice.
	for body in get_overlapping_bodies():
		if body.has_method("hit_by_enemy") and body.velocity.x > 0.0:
			body.hit_by_enemy(global_position.y)


func _choose_target() -> void:
	if _ball == null:
		return
	if _ball.velocity.x > 0.0:
		# Ball is coming: aim at it, with a bit of error.
		_target_y = _ball.global_position.y + randf_range(-aim_error, aim_error)
	else:
		# Ball is going away: drift back to the middle.
		_target_y = rest_y
