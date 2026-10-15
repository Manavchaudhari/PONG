extends Node2D
## Spawns one power-up at a time at a random time and place in the middle of the arena.
## Guarantee: if the first spawn of a level isn't a heart, the second one is.

signal powerup_collected(type: int)

@export var powerup_scene: PackedScene
## Main sets this from LevelData.powerups_enabled. Leave on to test without levels.
@export var enabled: bool = true
@export var min_wait: float = 6.0
@export var max_wait: float = 12.0
## Where power-ups can appear (keep it between the knight and the enemy).
@export var spawn_area: Rect2 = Rect2(400, 140, 480, 440)
@export_range(0.0, 1.0) var heart_chance: float = 0.4

var _wait: float = 0.0
var _current: Node = null
var _spawn_count: int = 0
var _heart_spawned: bool = false


func _ready() -> void:
	_wait = randf_range(min_wait, max_wait)


func _process(delta: float) -> void:
	if not enabled or is_instance_valid(_current):
		return  # only one power-up on screen at a time
	_wait -= delta
	if _wait <= 0.0:
		_spawn()
		_wait = randf_range(min_wait, max_wait)


func _spawn() -> void:
	var p = powerup_scene.instantiate()
	var force_heart := _spawn_count >= 1 and not _heart_spawned
	if force_heart or randf() < heart_chance:
		p.type = p.Type.HEART
		_heart_spawned = true
	else:
		p.type = p.Type.WINGS
	p.position = Vector2(
		randf_range(spawn_area.position.x, spawn_area.end.x),
		randf_range(spawn_area.position.y, spawn_area.end.y))
	p.collected.connect(func(t): powerup_collected.emit(t))
	add_child(p)
	_current = p
	_spawn_count += 1


func clear() -> void:
	if is_instance_valid(_current):
		_current.queue_free()
	enabled = false
