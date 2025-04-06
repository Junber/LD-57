extends "res://Scenes/Interactables/interactable.gd"

func _process(_delta: float) -> void:
	var player: Node2D = get_tree().get_first_node_in_group(&"player")
	var distance := (player.global_position - global_position).length()
	if distance > 500:
		$CanvasLayer.visible = false
	else:
		$CanvasLayer.visible = true
		$CanvasLayer/ColorRect.modulate = Color(1.0, 1.0, 1.0, 1.0 - (distance + 500.0) / 1000.0)
