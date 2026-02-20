class_name Wave
extends Resource

@export var enemy_scenes: Array[PackedScene] = []
@export var delay_during := 0.5
@export var delay_after := 10.0
@export var spawn_indicator_time := 2.0

func _init(
	_enemy_scenes: Array[PackedScene] = [],
	_delay_during := 0.5,
	_delay_after := 10.0,
	_spawn_indicator_time := 2.0
	) -> void:

	enemy_scenes = _enemy_scenes
	delay_during = _delay_during
	delay_after = _delay_after
	spawn_indicator_time = _spawn_indicator_time
