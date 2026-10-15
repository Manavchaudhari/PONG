extends Node2D
## Runs one level. Reads its settings from GameState.get_level_data(),
## then reloads itself for the next level / retry.

enum MatchState { PLAYING, LEVEL_WON, GAME_BEATEN, GAME_OVER }

const MENU_SCENE: String = "res://main_menu.tscn"

@onready var ball: CharacterBody2D = $Ball
@onready var enemy: Area2D = $Enemy
@onready var hud_label: Label = $HUD/Label
@onready var player: CharacterBody2D = $Player
@onready var spawner: Node2D = $PowerUpSpawner

var level: LevelData
var score: int = 0
var state: MatchState = MatchState.PLAYING


func _ready() -> void:
	level = GameState.get_level_data()
	_apply_level()
	$LeftGoal.body_entered.connect(_on_left_goal)
	$RightGoal.body_entered.connect(_on_right_goal)
	spawner.powerup_collected.connect(_on_powerup_collected)
	player.wing_charges_changed.connect(_on_wing_charges_changed)
	_update_hud()
	ball.reset()  # first serve happens here, AFTER the level speeds are applied


func _apply_level() -> void:
	ball.start_speed = level.ball_speed
	ball.speed_up_per_hit = level.ball_speed_up_per_hit
	ball.max_speed = level.ball_max_speed
	enemy.max_speed = level.ai_speed
	enemy.reaction_time = level.ai_reaction_time
	enemy.aim_error = level.ai_aim_error
	spawner.enabled = level.powerups_enabled


func _process(_delta: float) -> void:
	# Esc → back to the menu at any time.
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file(MENU_SCENE)
		return
	if state == MatchState.PLAYING or not Input.is_action_just_pressed("ui_accept"):
		return
	match state:
		MatchState.LEVEL_WON, MatchState.GAME_OVER:
			get_tree().reload_current_scene()
		MatchState.GAME_BEATEN:
			get_tree().change_scene_to_file(MENU_SCENE)


## Ball got past the knight.
func _on_left_goal(body: Node2D) -> void:
	if state != MatchState.PLAYING or body != ball:
		return
	GameState.lose_heart()
	_update_hud()  # update BEFORE GameState changes level/hearts below
	if GameState.hearts <= 0:
		GameState.game_over()  # sets current_level to the tier start
		_end_match(MatchState.GAME_OVER, "GAME OVER — Enter to retry from level %d" % GameState.current_level)
	else:
		_next_serve()


## Ball got past the enemy.
func _on_right_goal(body: Node2D) -> void:
	if state != MatchState.PLAYING or body != ball:
		return
	score += 1
	_update_hud()  # update BEFORE GameState moves to the next level below
	if score < level.goals_to_win:
		_next_serve()
	elif GameState.advance_level():
		_end_match(MatchState.GAME_BEATEN, "YOU BEAT THE GAME — Enter for menu")
	else:
		_end_match(MatchState.LEVEL_WON, "LEVEL CLEAR — Enter for level %d" % GameState.current_level)


func _on_powerup_collected(type: int) -> void:
	if state != MatchState.PLAYING:
		return
	match type:
		0:  # WINGS
			player.add_wing_charge()  # HUD updates via wing_charges_changed
		1:  # HEART
			GameState.add_heart()
			_update_hud()


## Skip once the match is over, so spending wings can't wipe the end message.
func _on_wing_charges_changed(_charges: int) -> void:
	if state == MatchState.PLAYING:
		_update_hud()


func _next_serve() -> void:
	ball.reset.call_deferred()


func _end_match(new_state: MatchState, message: String) -> void:
	state = new_state
	ball.stop.call_deferred()
	spawner.clear()
	hud_label.text += "\n" + message + "\n(Esc for menu)"


func _update_hud() -> void:
	hud_label.text = "Level %d (%s)     Hearts: %d     Wings: %d     Goals: %d / %d" % [
		GameState.current_level, GameState.tier_name(), GameState.hearts,
		GameState.wing_charges, score, level.goals_to_win]
