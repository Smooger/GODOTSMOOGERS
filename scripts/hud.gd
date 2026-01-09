extends CanvasLayer

@onready var time_label: Label = %TimeLabel
@onready var coin_label: Label = %CoinLabel
@onready var status_label: Label = %StatusLabel
@onready var hint_label: Label = %HintLabel

func _ready() -> void:
	_ensure_restart_action()
	var game := get_tree().get_first_node_in_group("game")
	if game:
		game.connect("time_changed", _on_time_changed)
		game.connect("coins_changed", _on_coins_changed)
		game.connect("level_failed", _on_level_failed)
		game.connect("level_completed", _on_level_completed)
	_on_time_changed(0.0)
	_on_coins_changed(0)
	status_label.text = ""

func _on_time_changed(value: float) -> void:
	time_label.text = "Time: %0.1f" % value

func _on_coins_changed(value: int) -> void:
	coin_label.text = "Coins: %d" % value

func _on_level_failed() -> void:
	status_label.text = "Time's up! Broderick couldn't hold it..."
	hint_label.text = "Press R to retry"

func _on_level_completed() -> void:
	status_label.text = "Bathroom reached!"
	hint_label.text = "Press R to replay"

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
