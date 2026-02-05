extends CharacterBody2D

@export var move_speed: float = 260.0
@export var jump_velocity: float = -420.0
@export var air_control: float = 0.5
@export var coyote_time: float = 0.12
@export var laser_scene: PackedScene

var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") as float
var _coyote_timer: float = 0.0
var _facing := 1

func _ready() -> void:
	add_to_group("player")
	_ensure_input_actions()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += _gravity * delta
		_coyote_timer = max(_coyote_timer - delta, 0.0)
	else:
		_coyote_timer = coyote_time

	var direction := Input.get_axis("move_left", "move_right")
	var target_speed := direction * move_speed
	var control := 1.0 if is_on_floor() else air_control
	velocity.x = move_toward(velocity.x, target_speed, move_speed * control * delta)
	if direction != 0.0:
		_facing = int(sign(direction))

	if Input.is_action_just_pressed("jump") and (_coyote_timer > 0.0):
		velocity.y = jump_velocity
		_coyote_timer = 0.0

	if Input.is_action_just_pressed("shoot"):
		_shoot_laser()

	move_and_slide()

func stomp_bounce() -> void:
	velocity.y = jump_velocity * 0.65

func _shoot_laser() -> void:
	var game := get_tree().get_first_node_in_group("game")
	if not game or not laser_scene:
		return
	if not game.consume_laser_charge():
		return
	var laser := laser_scene.instantiate()
	laser.global_position = global_position + Vector2(16 * _facing, -8)
	if laser.has_method("set_direction"):
		laser.set_direction(_facing)
	get_tree().current_scene.add_child(laser)

func _ensure_input_actions() -> void:
	var actions := {
		"move_left": KEY_A,
		"move_right": KEY_D,
		"jump": KEY_SPACE,
		"shoot": KEY_F,
	}
	for action in actions.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var event := InputEventKey.new()
			event.keycode = actions[action]
			InputMap.action_add_event(action, event)
