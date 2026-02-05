extends CharacterBody2D

@export var move_speed := 120.0
@export var gravity_scale := 1.0
@export var max_health := 1
@export var is_boss := false

@onready var ground_check: RayCast2D = %GroundCheck
@onready var wall_check: RayCast2D = %WallCheck

var _gravity := ProjectSettings.get_setting("physics/2d/default_gravity")
var _direction := -1
var _health := 1

func _ready() -> void:
	add_to_group("enemy")
	_health = max_health

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
	if body is CharacterBody2D and body.velocity.y > 120.0 and body.global_position.y < global_position.y - 6.0:
		if body.has_method("stomp_bounce"):
			body.stomp_bounce()
		take_stomp_hit()
		return
	var game := get_tree().get_first_node_in_group("game")
	if game:
		game.fail_level()

func take_stomp_hit() -> void:
	_health -= 1
	if _health <= 0:
		_defeat()

func take_laser_hit() -> void:
	_health -= 1
	if _health <= 0:
		_defeat()

func _defeat() -> void:
	if is_boss:
		var game := get_tree().get_first_node_in_group("game")
		if game:
			game.complete_level()
	queue_free()
