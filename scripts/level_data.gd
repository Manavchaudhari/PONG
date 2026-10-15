class_name LevelData
extends Resource
## One of these per level. Every difficulty number lives here, so balancing
## happens in the Inspector (double-click a level_XX.tres), not in code.

@export var goals_to_win: int = 2

@export_group("Ball")
@export var ball_speed: float = 420.0
@export var ball_speed_up_per_hit: float = 15.0
@export var ball_max_speed: float = 800.0

@export_group("Enemy")
## Higher = harder.
@export var ai_speed: float = 260.0
## Seconds between re-reading the ball. Lower = harder.
@export var ai_reaction_time: float = 0.35
## Random miss in pixels. Lower = harder.
@export var ai_aim_error: float = 60.0

@export_group("Power-ups")
@export var powerups_enabled: bool = false
