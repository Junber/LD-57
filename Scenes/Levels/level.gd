extends Node2D

func _ready() -> void:
	if has_node(^"SpawnPoint"):
		get_tree().get_first_node_in_group(&"player").global_position = $SpawnPoint.global_position
