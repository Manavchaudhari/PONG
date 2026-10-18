extends Control
## Start screen + level select. This is the game's Main Scene.
## Level buttons are created in code, so adding levels never needs editor work.

const GAME_SCENE: String = "res://main.tscn"
const PLATFORM_SCENE: String = "res://platform_mode.tscn"

@onready var main_buttons: VBoxContainer = $Center/MainButtons
@onready var level_panel: VBoxContainer = $Center/LevelPanel
@onready var level_grid: GridContainer = $Center/LevelPanel/Grid


func _ready() -> void:
	$Center/MainButtons/PlayButton.pressed.connect(_start.bind(1))
	$Center/MainButtons/LevelSelectButton.pressed.connect(_show_levels.bind(true))
	$Center/MainButtons/PlatformButton.pressed.connect(_start_platform)
	$Center/MainButtons/QuitButton.pressed.connect(get_tree().quit)
	$Center/LevelPanel/BackButton.pressed.connect(_show_levels.bind(false))
	# Quit does nothing in a browser tab, so hide it on the web build.
	$Center/MainButtons/QuitButton.visible = not OS.has_feature("web")

	# 4 columns → each row is one tier: 1–4 Easy, 5–8 Medium, 9–10 Hard.
	level_grid.columns = 4
	for i in range(1, GameState.LEVEL_COUNT + 1):
		var b := Button.new()
		b.text = "%d\n%s" % [i, Helpers.tier_name(i)]
		b.custom_minimum_size = Vector2(120, 70)
		b.pressed.connect(_start.bind(i))
		level_grid.add_child(b)

	_show_levels(false)


func _show_levels(show: bool) -> void:
	main_buttons.visible = not show
	level_panel.visible = show
	# Give a button keyboard focus so Enter/arrow keys work without a mouse.
	if show:
		level_grid.get_child(0).grab_focus()
	else:
		$Center/MainButtons/PlayButton.grab_focus()


func _start_platform() -> void:
	get_tree().change_scene_to_file(PLATFORM_SCENE)


func _start(level: int) -> void:
	GameState.start_run(level)  # fresh 3 hearts, chosen level
	get_tree().change_scene_to_file(GAME_SCENE)
