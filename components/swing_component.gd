class_name SwingComponent
extends Node
## COMPONENT: Sword swing. turn hitbox on for a short window. hit the first
## thing inside it that has hit_by_player() then cooldown

@export var hitbox: Area2D
@export var visual: CanvasItem

@export_group("Swing")
## How long the sword hitbox is live after pressing swing.
@export var swing_active_time: float = 0.15
## Extra wait after the swing ends before you can swing again (stops spamming).
@export var swing_cooldown: float = 0.2

var _swing_timer: float = 0.0
var _cooldown_timer: float = 0.0
var _hit_this_swing: bool = false

func _ready() -> void:
	hitbox.monitoring = false
	visual.visible = false

func update(delta: float) -> void:
	_cooldown_timer = max(_cooldown_timer - delta, 0.0)

	if Input.is_action_just_pressed("swing") and _swing_timer <= 0.0 and _cooldown_timer <= 0.0:
		_swing_timer = swing_active_time
		_hit_this_swing = false
		hitbox.monitoring = true
		visual.visible = true

	if _swing_timer <= 0.0:
		return

	_swing_timer -= delta

	# Check overlaps every frame while the swing is live, so a ball that is
	# already inside the hitbox when you press swing still gets hit.
	if not _hit_this_swing:
		for body in hitbox.get_overlapping_bodies():
			if body.has_method("hit_by_player"):
				body.hit_by_player(hitbox.global_position.y)
				_hit_this_swing = true
				break

	if _swing_timer <= 0.0:
		hitbox.monitoring = false
		visual.visible = false
		_cooldown_timer = swing_cooldown
