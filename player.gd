extends CharacterBody2D
## Knight player. Jumps (Mario-style variable height), double jumps, fast-falls and swings a sword.
## The knight is the paddle: it never moves left/right, and only the sword hits the ball.

## Main listens to this to keep the HUD's "Wings: N" up to date.
signal wing_charges_changed(charges: int)

@export_group("Swing")
## How long the sword hitbox is live after pressing swing.
@export var swing_active_time: float = 0.15
## Extra wait after the swing ends before you can swing again (stops spamming).
@export var swing_cooldown: float = 0.2

@export_group("Wings")
## Flight time per charge.
@export var wings_duration: float = 5.0
## While winged: hold jump to rise at this speed...
@export var fly_up_speed: float = 450.0
## ...release to sink at this speed.
@export var fly_down_speed: float = 350.0

@onready var sword: Area2D = $Sword
@onready var sword_visual: CanvasItem = $Sword/ColorRect
@onready var jump: JumpComponent = $JumpComponent

## Knight is locked to the x position it starts at, like a Pong paddle.
var _start_x: float = 0.0
var _swing_timer: float = 0.0
var _cooldown_timer: float = 0.0
var _hit_this_swing: bool = false
var _wings_time: float = 0.0


func _ready() -> void:
	_start_x = global_position.x
	sword.monitoring = false
	sword_visual.visible = false


func _physics_process(delta: float) -> void:
	_try_use_wings()
	_jump(delta)
	_swing(delta)


## Called by Main when the ball collects a wings power-up.
func add_wing_charge() -> void:
	GameState.add_wing_charge()
	wing_charges_changed.emit(GameState.wing_charges)


func has_wings() -> bool:
	return _wings_time > 0.0


## Spend a charge. Ignored while already flying, so a charge can't be wasted by accident.
func _try_use_wings() -> void:
	if not Input.is_action_just_pressed("use_wings") or has_wings() or GameState.wing_charges <= 0:
		return
	GameState.wing_charges -= 1
	_wings_time = wings_duration
	jump.reset_air_jumps()
	wing_charges_changed.emit(GameState.wing_charges)


func _jump(delta: float) -> void:
	if has_wings():
		_fly(delta)
		return

	jump.update_y(self,delta)

	velocity.x = 0.0
	move_and_slide()
	global_position.x = _start_x


## Wings: no gravity. Hold jump = rise, release = sink, hold fast_fall = dive.
func _fly(delta: float) -> void:
	_wings_time -= delta
	if Input.is_action_pressed("fast_fall"):
		velocity.y = jump.fast_fall_speed
	elif Input.is_action_pressed("jump"):
		velocity.y = -fly_up_speed
	else:
		velocity.y = fly_down_speed
	velocity.x = 0.0
	move_and_slide()
	global_position.x = _start_x
	# Placeholder visual until wings art exists: tint the knight, blink in the last 2s.
	var blinking := _wings_time < 2.0 and int(_wings_time * 8.0) % 2 == 0
	modulate = Color(1, 1, 1) if (blinking or not has_wings()) else Color(0.7, 0.9, 1.4)


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
