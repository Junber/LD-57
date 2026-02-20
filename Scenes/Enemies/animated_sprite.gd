extends AnimatedSprite2D

func _on_enemy_walking(walking: bool, left: bool) -> void:
	if walking:
		play(&"walk")
	else:
		play(&"idle")
	flip_h = left


func _on_enemy_attack() -> void:
	play(&"attack")


func _on_animation_finished() -> void:
	get_parent().on_attack_done()
