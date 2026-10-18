class_name RunComponent
extends Node
## COMPONENT: Player can run left and right in platform mode

@export var move_speed: float = 420.0
##furthrest
@export var min_x: float = 40.0
@export var max_x: float = 1240.0

func get_x_velocity() -> float:
	return Input.get_axis("move_left","move_right") * move_speed

func clamp_to_screen(body: Node2D) -> void:
	body.global_position.x = clamp(body.global_position.x, min_x, max_x)
