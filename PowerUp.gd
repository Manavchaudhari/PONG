extends Area2D
## A floating power-up. Collected when the BALL flies through it,
## but only if the player hit the ball last. Enemy shots pass straight through.

signal collected(type: Type)

enum Type { WINGS, HEART }

@export var type: Type = Type.WINGS
## Seconds before it disappears if nobody collects it.
@export var lifetime: float = 9.0
@export var bob_height: float = 8.0
@export var bob_speed: float = 3.0

var _age: float = 0.0
var _base_y: float = 0.0


func _ready() -> void:
	_base_y = position.y
	body_entered.connect(_on_body_entered)
	# Placeholder look until art exists: blue = wings, red = heart.
	$ColorRect.color = Color(0.4, 0.8, 1.0) if type == Type.WINGS else Color(1.0, 0.3, 0.35)


func _process(delta: float) -> void:
	_age += delta
	position.y = _base_y + sin(_age * bob_speed) * bob_height
	# Blink during the last 2 seconds so the player knows it's about to vanish.
	visible = _age < lifetime - 2.0 or int(_age * 8.0) % 2 == 0
	if _age >= lifetime:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("ball"):
		return
	if body.last_hitter != body.Hitter.PLAYER:
		return  # enemy shot or fresh serve: pass through
	collected.emit(type)
	queue_free()
