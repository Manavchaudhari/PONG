extends Node2D
## Platform Mode: Platform + side scroller
## 3 misses and kingdom ded

enum MatchState { PLAYING, WON, LOST }

const MENU_SCENE: String = "res://main_menu.tscn"

##Ball + enemy difficulty
@export var level: LevelData
@export var goals_to_win: int = 3

@export_group("Scrolling")
@export var start_scroll_speed: float = 150.0
@export var max_scroll_speed: float = 400.0
## How much faster the world gets every second.
@export var scroll_acceleration: float = 5.0

@onready var ball: CharacterBody2D = $Ball
@onready var enemy: Area2D = $Enemy
@onready var hud_label: Label = $HUD/Label
@onready var kingdom: HealthComponent = $Kingdom
@onready var player: CharacterBody2D = $Player
@onready var spawner: Node2D = $PowerUpSpawner
@onready var platforms: Node2D = $PlatformSpawner

var score: int = 0
var state: MatchState = MatchState.PLAYING


func _ready() -> void:
	GameState.scroll_speed = start_scroll_speed
	GameState.wing_charges = 0  # fresh run: no leftover wings from classic
	spawner.powerup_collected.connect(_on_powerup_collected)
	player.wing_charges_changed.connect(_on_wing_charges_changed)
	_apply_level()
	$LeftGoal.body_entered.connect(_on_left_goal)
	$RightGoal.body_entered.connect(_on_right_goal)
	kingdom.changed.connect(_on_kingdom_changed)
	kingdom.died.connect(_on_kingdom_ruined)
	_update_hud()
	ball.reset()


func _apply_level() -> void:
	ball.start_speed = level.ball_speed
	ball.speed_up_per_hit = level.ball_speed_up_per_hit
	ball.max_speed = level.ball_max_speed
	enemy.max_speed = level.ai_speed
	enemy.reaction_time = level.ai_reaction_time
	enemy.aim_error = level.ai_aim_error


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file(MENU_SCENE)
		return
	if state != MatchState.PLAYING and Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()
	if state == MatchState.PLAYING:
		GameState.scroll_speed = min(GameState.scroll_speed + scroll_acceleration * delta, max_scroll_speed)

## kingdom tak a hit
func _on_left_goal(body: Node2D) -> void:
	if state != MatchState.PLAYING or body != ball:
		return
	kingdom.damage(1)
	if kingdom.is_alive():
		ball.reset.call_deferred()

## enemy take a hit
func _on_right_goal(body: Node2D) -> void:
	if state != MatchState.PLAYING or body != ball:
		return
	score += 1
	_update_hud()
	if score >= goals_to_win:
		_end_match(MatchState.WON, "KINGDOM IS SAVED YIPPPIEEEEE")
	else:
		ball.reset.call_deferred()


func _on_kingdom_changed(_current: int, _max_value: int) -> void:
	_update_hud()


func _on_kingdom_ruined() -> void:
	_end_match(MatchState.LOST, "KINGDOM DED BOOOO")


func _on_powerup_collected(type: int) -> void:
	if state != MatchState.PLAYING:
		return
	match type:
		0:  # WINGS
			player.add_wing_charge()
		1:  # HEART
			kingdom.heal(1)


## Skip once the match is over, so spending wings can't wipe the end message.
func _on_wing_charges_changed(_charges: int) -> void:
	if state == MatchState.PLAYING:
		_update_hud()


func _end_match(new_state: MatchState, message: String) -> void:
	state = new_state
	ball.stop.call_deferred()
	spawner.clear()
	hud_label.text += "\n" + message + "\nEnter to play again  Esc for menu"
	platforms.enabled = false
	GameState.scroll_speed = 0.0  # every ScrollComponent stops where it is


func _update_hud() -> void:
	hud_label.text = "PLATFORM MODE   kingdom: %d / %d    Goals: %d / %d  Wings: %d / %d" % [kingdom.current, kingdom.max_health, score, goals_to_win, GameState.wing_charges, GameState.MAX_WING_CHARGES]
