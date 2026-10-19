class_name PlatformSpawner
extends Node2D
## Spawn platform at the right edge at random height and gap

@export var platform_scene: PackedScene
@export var enabled: bool = true

## Seconds between platforms
@export var min_gap: float = 1.5
@export var max_gap: float = 3.0

##right edge of the screen
@export var spawn_x: float = 1450.0

##Heights at which a platform can appear at. The floor's top is y = 680
@export var min_y: float = 380.0
@export var max_y: float = 640.0

var _wait: float = 2.0

func _process(delta: float) -> void:
	if not enabled:
		return
	_wait -= delta
	if _wait <= 0.0:
		_spawn()
		_wait = randf_range(min_gap, max_gap)


func _spawn() -> void:
	var p: Node2D = platform_scene.instantiate()
	p.position = Vector2(spawn_x, randf_range(min_y, max_y))
	add_child(p)
