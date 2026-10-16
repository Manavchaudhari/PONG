class_name JumpComponent
extends Node
## COMPONENT: gravity, variable_height, jump, double jump and fast fall
## only changes body.velocity.y. body will call update_y() every frame

@export_group("Jump")

@export var gravity: float = 2200.0
## Initial upward speed. Peak height = v² / (2 × gravity).
@export var jump_velocity: float = 1600.0 
##Multiplier applied when Space is released while still rising. Lower = shorter taps.
@export_range(0.0, 1.0) var jump_cut: float = 0.45
## Extra jumps allowed in the air before landing again.
@export var air_jumps: int = 1
## Weaker than the ground jump.
@export var air_jump_velocity: float = 1200.0
## Holding (s) snaps the knight down at least this fast (also cancels upward speed).
@export var fast_fall_speed: float = 1500.0

var _air_jumps_left: int = 0

func reset_air_jumps() -> void:
	_air_jumps_left = air_jumps

func update_y(body: CharacterBody2D, delta: float)-> void:
	if body.is_on_floor():
		_air_jumps_left = air_jumps
	else:
		body.velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump"):
		if body.is_on_floor():
			body.velocity.y = -jump_velocity
		elif _air_jumps_left > 0:
			_air_jumps_left -= 1
			body.velocity.y = -air_jump_velocity
	# Releasing early cuts the jump short (Mario-style).
	if Input.is_action_just_released("jump") and body.velocity.y < 0.0:
		body.velocity.y *= jump_cut

	# Fast-fall: get down for a low return instead of floating at gravity speed.
	if Input.is_action_pressed("fast_fall") and not body.is_on_floor():
		body.velocity.y = max(body.velocity.y, fast_fall_speed)
