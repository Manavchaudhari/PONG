extends CharacterBody2D
## Knight player. Jumps (Mario-style variable height), double jumps, fast-falls and swings a sword.
## The knight is the paddle: it never moves left/right, and only the sword hits the ball.

## Main listens to this to keep the HUD's "Wings: N" up to date.
signal wing_charges_changed(charges: int)

@export_group("Wings")
## Flight time per charge.
@export var wings_duration: float = 5.0
## While winged: hold jump to rise at this speed...
@export var fly_up_speed: float = 450.0
## ...release to sink at this speed.
@export var fly_down_speed: float = 350.0

@onready var swing: SwingComponent = $SwingComponent
@onready var jump: JumpComponent = $JumpComponent
@onready var run: RunComponent = get_node_or_null("RunComponent")

## Knight is locked to the x position it starts at, like a Pong paddle.
var _start_x: float = 0.0
var _wings_time: float = 0.0


func _ready() -> void:
	_start_x = global_position.x


func _physics_process(delta: float) -> void:
	_try_use_wings()
	_jump(delta)
	swing.update(delta)


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
	_move()


## Wings: no gravity. Hold jump = rise, release = sink, hold fast_fall = dive.
func _fly(delta: float) -> void:
	_wings_time -= delta
	if Input.is_action_pressed("fast_fall"):
		velocity.y = jump.fast_fall_speed
	elif Input.is_action_pressed("jump"):
		velocity.y = -fly_up_speed
	else:
		velocity.y = fly_down_speed
	_move()
	# Placeholder visual replace later with art
	var blinking := _wings_time < 2.0 and int(_wings_time * 8.0) % 2 == 0
	modulate = Color(1, 1, 1) if (blinking or not has_wings()) else Color(0.7, 0.9, 1.4)


## Left and Right movement, locked like a paddle in normal mode
func _move() -> void:
	if run:
		velocity.x = run.get_x_velocity()
	else:
		velocity.x = 0.0
	move_and_slide()
	if run:
		run.clamp_to_screen(self)
	else:
		global_position.x = _start_x
