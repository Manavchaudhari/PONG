extends Node
## Autoload (Project Settings → Globals → Autoload, name it "GameState").
## Survives scene reloads, so hearts and the current level carry across levels.

const LEVEL_COUNT: int = 10
const START_HEARTS: int = 3
const MAX_HEARTS: int = 5
const MAX_WING_CHARGES: int = 3

var current_level: int = 3
var hearts: int = START_HEARTS
## Stored wings power-ups. Carry over between levels like hearts.
var wing_charges: int = 0


## Fresh run. Level select (Day 6) calls this with the chosen level.
func start_run(level: int = 1) -> void:
	current_level = level
	hearts = START_HEARTS
	wing_charges = 0


func get_level_data() -> LevelData:
	return load("res://resources/levels/level_%02d.tres" % current_level)


func tier_name() -> String:
	if current_level >= 9:
		return "Hard"
	if current_level >= 5:
		return "Medium"
	return "Easy"


func lose_heart() -> void:
	hearts -= 1


## Used by the heart power-up on Day 5.
func add_heart() -> void:
	hearts = min(hearts + 1, MAX_HEARTS)


## Returns true if that was the last level (game beaten).
func advance_level() -> bool:
	if current_level >= LEVEL_COUNT:
		return true
	current_level += 1
	return false


## Out of hearts: back to the first level of the current tier, hearts refilled, wings emptied.
func game_over() -> void:
	if current_level >= 9:
		current_level = 9
	elif current_level >= 5:
		current_level = 5
	else:
		current_level = 1
	hearts = START_HEARTS
	wing_charges = 0


## Wings power-up collected. Spending happens in the player script.
func add_wing_charge() -> void:
	wing_charges = min(wing_charges + 1, MAX_WING_CHARGES)
