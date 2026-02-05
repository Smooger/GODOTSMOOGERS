extends Node

signal coins_changed(total: int)
signal time_changed(time_left: float)
signal level_failed
signal level_completed
signal level_changed(level_number: int, theme_name: String)
signal laser_changed(enabled: bool, charges: int)

@export var starting_time := 55.0
@export var overtime_cap := 30.0
@export var total_levels := 7

var time_left := 0.0
var coins := 0
var outfit_level := 0
var active := true
var current_level := 1
var current_theme := "Desert Ruins"
var laser_enabled := false
var laser_charges := 0

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
	laser_enabled = false
	laser_charges = 0
	emit_signal("time_changed", time_left)
	emit_signal("coins_changed", coins)
	emit_signal("laser_changed", laser_enabled, laser_charges)
	emit_signal("level_changed", current_level, current_theme)

func configure_level(level_number: int, theme_name: String) -> void:
	current_level = level_number
	current_theme = theme_name
	active = true
	time_left = starting_time + float(level_number * 2)
	emit_signal("time_changed", time_left)
	emit_signal("level_changed", current_level, current_theme)

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

func grant_laser(charges: int) -> void:
	laser_enabled = true
	laser_charges += charges
	emit_signal("laser_changed", laser_enabled, laser_charges)

func consume_laser_charge() -> bool:
	if not laser_enabled:
		return false
	if laser_charges <= 0:
		laser_enabled = false
		emit_signal("laser_changed", laser_enabled, laser_charges)
		return false
	laser_charges -= 1
	if laser_charges <= 0:
		laser_enabled = false
	emit_signal("laser_changed", laser_enabled, laser_charges)
	return true

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
