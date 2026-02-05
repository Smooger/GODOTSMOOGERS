extends Area2D

@export var speed := 620.0
@export var max_range := 460.0

var _direction := 1
var _start_position := Vector2.ZERO

func _ready() -> void:
	_start_position = global_position
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position.x += speed * _direction * delta
	if global_position.distance_to(_start_position) >= max_range:
		queue_free()

func set_direction(dir: int) -> void:
	_direction = 1 if dir >= 0 else -1
	scale.x = _direction

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemy") and body.has_method("take_laser_hit"):
		body.take_laser_hit()
		queue_free()
