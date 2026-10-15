extends CharacterBody2D
## Knight player. Jumps (Mario-style variable height) and swings a sword.
## The knight is the paddle: it never moves left/right, and only the sword hits the ball.

@export_group("Jump")
@export var gravity: float = 2200.0
## Initial upward speed. Peak height = v² / (2 × gravity).
@export var jump_velocity: float = 1600.0
## Multiplier applied when Space is released while still rising. Lower = shorter taps.
@export_range(0.0, 1.0) var jump_cut: float = 0.45

@export_group("Swing")
## How long the sword hitbox is live after pressing swing.
@export var swing_active_time: float = 0.15
## Extra wait after the swing ends before you can swing again (stops spamming).
@export var swing_cooldown: float = 0.2

@onready var sword: Area2D = $Sword
@onready var sword_visual: CanvasItem = $Sword/ColorRect

## Knight is locked to the x position it starts at, like a Pong paddle.
var _start_x: float = 0.0
var _swing_timer: float = 0.0
var _cooldown_timer: float = 0.0
var _hit_this_swing: bool = false


func _ready() -> void:
	_start_x = global_position.x
	sword.monitoring = false
	sword_visual.visible = false


func _physics_process(delta: float) -> void:
	_jump(delta)
	_swing(delta)


func _jump(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_velocity
	# Releasing early cuts the jump short (Mario-style).
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut

	velocity.x = 0.0
	move_and_slide()
	global_position.x = _start_x


func _swing(delta: float) -> void:
	_cooldown_timer = max(_cooldown_timer - delta, 0.0)

	if Input.is_action_just_pressed("swing") and _swing_timer <= 0.0 and _cooldown_timer <= 0.0:
		_swing_timer = swing_active_time
		_hit_this_swing = false
		sword.monitoring = true
		sword_visual.visible = true

	if _swing_timer <= 0.0:
		return

	_swing_timer -= delta

	# Check overlaps every frame while the swing is live, so a ball that is
	# already inside the hitbox when you press swing still gets hit.
	if not _hit_this_swing:
		for body in sword.get_overlapping_bodies():
			if body.has_method("hit_by_player"):
				body.hit_by_player(sword.global_position.y)
				_hit_this_swing = true
				break

	if _swing_timer <= 0.0:
		sword.monitoring = false
		sword_visual.visible = false
		_cooldown_timer = swing_cooldown
