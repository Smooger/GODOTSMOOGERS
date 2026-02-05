extends CanvasLayer

@onready var time_label: Label = %TimeLabel
@onready var coin_label: Label = %CoinLabel
@onready var status_label: Label = %StatusLabel
@onready var hint_label: Label = %HintLabel
@onready var level_label: Label = %LevelLabel
@onready var laser_label: Label = %LaserLabel

func _ready() -> void:
	_ensure_restart_action()
	var game := get_tree().get_first_node_in_group("game")
	if game:
		game.connect("time_changed", _on_time_changed)
		game.connect("coins_changed", _on_coins_changed)
		game.connect("level_failed", _on_level_failed)
		game.connect("level_completed", _on_level_completed)
		game.connect("level_changed", _on_level_changed)
		game.connect("laser_changed", _on_laser_changed)
	_on_time_changed(0.0)
	_on_coins_changed(0)
	_on_level_changed(1, "Desert Ruins")
	_on_laser_changed(false, 0)
	status_label.text = ""

func _on_time_changed(value: float) -> void:
	time_label.text = "Time: %0.1f" % value

func _on_coins_changed(value: int) -> void:
	coin_label.text = "Coins: %d" % value

func _on_level_changed(level_number: int, theme_name: String) -> void:
	level_label.text = "Level %d/7 - %s" % [level_number, theme_name]
	status_label.text = ""
	hint_label.text = "A/D move · Space jump · F fire laser · R retry"

func _on_laser_changed(enabled: bool, charges: int) -> void:
	if enabled:
		laser_label.text = "Laser: %d" % charges
	else:
		laser_label.text = "Laser: OFF"

func _on_level_failed() -> void:
	status_label.text = "You were defeated!"
	hint_label.text = "Press R to retry"

func _on_level_completed() -> void:
	var game := get_tree().get_first_node_in_group("game")
	if game and game.current_level >= game.total_levels:
		status_label.text = "T-Rex defeated! You won!"
		hint_label.text = "Press R to play again"

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		var game := get_tree().get_first_node_in_group("game")
		if game and not game.active:
			game.retry_level()

func _ensure_restart_action() -> void:
	if InputMap.has_action("restart"):
		return
	InputMap.add_action("restart")
	var event := InputEventKey.new()
	event.keycode = KEY_R
	InputMap.action_add_event("restart", event)
