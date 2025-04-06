extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_enemy_walking(walking: bool, _left: bool) -> void:
	if walking:
		animation_player.play(&"walk")
	else:
		animation_player.play(&"idle")
