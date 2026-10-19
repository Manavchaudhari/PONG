class_name ScrollComponent
extends Node
## COMPONENT: slides whatever this is on to the left then delete it once off-screen

## move with the world = 1.0. less = feels further away
@export var speed_scale: float = 1.0

## parent is deleted once its x is left of this
@export var offscreen_x: float = -300.0


func _physics_process(delta: float) -> void:
	var parent := get_parent() as Node2D
	parent.position.x -= GameState.scroll_speed * speed_scale * delta
	if parent.global_position.x < offscreen_x:
		parent.queue_free()
