extends Area2D

@export var value := 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	var game := get_tree().get_first_node_in_group("game")
	if game:
		game.add_coins(value)
	queue_free()
