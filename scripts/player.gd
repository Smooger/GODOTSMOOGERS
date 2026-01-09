extends CharacterBody2D

@export var move_speed: float = 260.0
@export var jump_velocity: float = -420.0
@export var air_control: float = 0.5
@export var coyote_time: float = 0.12

var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") as float
var _coyote_timer: float = 0.0

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

	if Input.is_action_just_pressed("jump") and (_coyote_timer > 0.0):
		velocity.y = jump_velocity
		_coyote_timer = 0.0

	move_and_slide()

func _ensure_input_actions() -> void:
	var actions := {
		"move_left": KEY_A,
		"move_right": KEY_D,
		"jump": KEY_SPACE,
	}
	for action in actions.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var event := InputEventKey.new()
			event.keycode = actions[action]
			InputMap.action_add_event(action, event)
