extends CharacterBody2D

@export var move_speed := 120.0
@export var gravity_scale := 1.0

@onready var ground_check: RayCast2D = %GroundCheck
@onready var wall_check: RayCast2D = %WallCheck

var _gravity := ProjectSettings.get_setting("physics/2d/default_gravity")
var _direction := -1

func _ready() -> void:
	add_to_group("enemy")

func _physics_process(delta: float) -> void:
	velocity.y += _gravity * gravity_scale * delta
	velocity.x = _direction * move_speed

	if wall_check.is_colliding() or not ground_check.is_colliding():
		_flip()

	move_and_slide()

func _flip() -> void:
	_direction *= -1
	ground_check.target_position.x *= -1
	wall_check.target_position.x *= -1

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	var game := get_tree().get_first_node_in_group("game")
	if game:
		game.fail_level()
