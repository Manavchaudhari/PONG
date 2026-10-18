class_name HealthComponent
extends Node
## COMPONENT: health points

signal changed(current: int, max_value: int)
signal died

@export var max_health: int = 3

var current: int = 0

func _ready() -> void:
	current = max_health

func damage(amount: int = 1) -> void:
	if current <= 0:
		return # already dead ignore any extra hits
	current = max(current - amount, 0)
	changed.emit(current, max_health)
	if current == 0:
		died.emit()


func heal(amount: int = 1) -> void:
	current = min(current + amount, max_health)
	changed.emit(current, max_health)


func is_alive() -> bool:
	return current > 0
