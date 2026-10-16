class_name Helpers
extends RefCounted

## difficulty levels
static func tier_name(level: int) -> String:
	if level >= 9:
		return "Hard"
	if level >= 5:
		return "Medium"
	return "Easy"


## angle of the ball bouncing after hitting the paddle -> direction_x: 1 = right, -1 = left
static func angled_velocity(
		direction_x: float, 
		offset: float, 
		half_height: float,
		max_angle_deg: float, 
		speed: float) -> Vector2:
	var t: float = clamp(offset / half_height, -1.0, 1.0)
	var angle: float = deg_to_rad(t * max_angle_deg)
	return Vector2(cos(angle) * direction_x, sin(angle)) * speed


## random spawning in a rectangle area
static func random_point_in(area: Rect2) -> Vector2:
	return Vector2(
		randf_range(area.position.x, area.end.x),
		randf_range(area.position.y, area.end.y))
