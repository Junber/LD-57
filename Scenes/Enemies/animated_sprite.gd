extends AnimatedSprite2D

func _on_enemy_walking(walking: bool, left: bool) -> void:
	if walking:
		play(&"walk")
	else:
		play(&"idle")
	flip_h = left
