extends Node

signal coins_changed(total: int)
signal time_changed(time_left: float)
signal level_failed
signal level_completed

@export var starting_time := 45.0
@export var overtime_cap := 30.0

var time_left := 0.0
var coins := 0
var outfit_level := 0
var active := true

func _ready() -> void:
	add_to_group("game")
	start_level()

func _process(delta: float) -> void:
	if not active:
		return
	if time_left <= 0.0:
		return
	_time_tick(delta)

func start_level() -> void:
	time_left = starting_time
	coins = 0
	outfit_level = 0
	active = true
	emit_signal("time_changed", time_left)
	emit_signal("coins_changed", coins)

func _time_tick(delta: float) -> void:
	time_left = max(time_left - delta, 0.0)
	emit_signal("time_changed", time_left)
	if time_left <= 0.0:
		fail_level()

func add_time(amount: float) -> void:
	var cap := starting_time + overtime_cap
	time_left = clamp(time_left + amount, 0.0, cap)
	emit_signal("time_changed", time_left)

func add_coins(amount: int) -> void:
	coins += amount
	emit_signal("coins_changed", coins)

func spend_coins(cost: int) -> bool:
	if coins < cost:
		return false
	coins -= cost
	outfit_level += 1
	emit_signal("coins_changed", coins)
	return true

func fail_level() -> void:
	if not active:
		return
	active = false
	emit_signal("level_failed")

func complete_level() -> void:
	if not active:
		return
	active = false
	emit_signal("level_completed")

func retry_level() -> void:
	get_tree().reload_current_scene()
