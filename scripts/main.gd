extends Node2D

@export var enemy_scene: PackedScene
@export var coin_scene: PackedScene
@export var powerup_scene: PackedScene
@export var goal_scene: PackedScene

@onready var game: Node = $Game
@onready var player: CharacterBody2D = $Player
@onready var level_root: Node2D = $LevelEntities
@onready var backdrop: ColorRect = $BackgroundLayer/Backdrop

const THEMES := [
	{"name":"Desert Ruins","color":Color("d6b06a")},
	{"name":"Ice World","color":Color("9ad9ff")},
	{"name":"Moon Base","color":Color("1f2343")},
	{"name":"Underwater Base","color":Color("2b6ca3")},
	{"name":"Rainbow Fortress","color":Color("c77dff")},
	{"name":"Dinosaur Island","color":Color("5b8f3b")},
	{"name":"T-Rex Showdown","color":Color("913a2f")},
]

func _ready() -> void:
	game.connect("level_completed", _on_level_completed)
	game.connect("level_failed", _on_level_failed)
	_load_level(1)

func _on_level_completed() -> void:
	if game.current_level >= game.total_levels:
		return
	_load_level(game.current_level + 1)

func _on_level_failed() -> void:
	# stop spawning and let HUD show retry prompt.
	pass

func _clear_level_entities() -> void:
	for child in level_root.get_children():
		child.queue_free()

func _load_level(level_number: int) -> void:
	_clear_level_entities()
	var theme = THEMES[level_number - 1]
	game.configure_level(level_number, theme.name)
	backdrop.color = theme.color
	player.global_position = Vector2(120, 520)
	_build_platform_layout(level_number)
	_spawn_collectibles(level_number)
	_spawn_enemies(level_number)
	_spawn_goal(level_number)

func _build_platform_layout(level_number: int) -> void:
	var spacing := 160.0
	for i in range(5 + level_number):
		var body := StaticBody2D.new()
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(120, 24)
		collision.shape = shape
		body.add_child(collision)
		var visual := Polygon2D.new()
		visual.polygon = PackedVector2Array([Vector2(-60,-12),Vector2(60,-12),Vector2(60,12),Vector2(-60,12)])
		visual.color = Color(0.18 + 0.04 * level_number, 0.22, 0.26, 1.0)
		body.add_child(visual)
		var x := 200.0 + i * spacing
		var y := 560.0 - 58.0 * (i % 3)
		body.global_position = Vector2(min(x, 1160), y)
		level_root.add_child(body)

	# Ground strip.
	var ground := StaticBody2D.new()
	var g_collision := CollisionShape2D.new()
	var g_shape := RectangleShape2D.new()
	g_shape.size = Vector2(1600, 70)
	g_collision.shape = g_shape
	ground.add_child(g_collision)
	var g_visual := Polygon2D.new()
	g_visual.polygon = PackedVector2Array([Vector2(-800,-35),Vector2(800,-35),Vector2(800,35),Vector2(-800,35)])
	g_visual.color = Color(0.14,0.14,0.17,1.0)
	ground.add_child(g_visual)
	ground.global_position = Vector2(740, 670)
	level_root.add_child(ground)

func _spawn_collectibles(level_number: int) -> void:
	for i in range(2 + level_number):
		var coin := coin_scene.instantiate()
		coin.global_position = Vector2(270 + i * 120, 440 - 36 * (i % 2))
		level_root.add_child(coin)

	var powerup := powerup_scene.instantiate()
	powerup.global_position = Vector2(740, 280)
	level_root.add_child(powerup)

func _spawn_enemies(level_number: int) -> void:
	var enemy_count := min(2 + level_number, 7)
	for i in range(enemy_count):
		var enemy := enemy_scene.instantiate()
		enemy.global_position = Vector2(460 + i * 110, 520 - 30 * (i % 3))
		if enemy.has_method("set"):
			enemy.set("max_health", 1 + int(level_number >= 5))
		level_root.add_child(enemy)

	if level_number == 7:
		var boss := enemy_scene.instantiate()
		boss.global_position = Vector2(1060, 540)
		boss.scale = Vector2(2.2, 2.2)
		boss.set("is_boss", true)
		boss.set("max_health", 8)
		boss.set("move_speed", 90.0)
		boss.set("gravity_scale", 1.15)
		level_root.add_child(boss)

func _spawn_goal(level_number: int) -> void:
	if level_number == 7:
		return
	var goal := goal_scene.instantiate()
	goal.global_position = Vector2(1160, 150)
	level_root.add_child(goal)
