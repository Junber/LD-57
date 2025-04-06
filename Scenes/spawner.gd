extends Node2D

@export var spawner_name: String

@export var enemies_to_spawn := 2
@export var enemy_scenes: Array[PackedScene]
@export var spawn_indicator_scene: PackedScene

var next_spawn := 0

func initiate_combat(combat_name: String) -> void:
	if spawner_name == combat_name:
		get_tree().get_first_node_in_group(&"game").set_force_combat(true)
		spawn()
		$Timer.start()


func spawn() -> void:
	var spawn_indicator := spawn_indicator_scene.instantiate()
	spawn_indicator.enemy_scene = enemy_scenes[next_spawn]
	spawn_indicator.global_position = \
		global_position + Vector2(randf_range(-500.0, 500.0), randf_range(-500.0, 500.0))
	get_parent().add_child(spawn_indicator)
	spawn_indicator.start(2.0)

	next_spawn = (next_spawn + 1) % enemy_scenes.size()
	enemies_to_spawn -= 1
	if enemies_to_spawn <= 0:
		queue_free()
		get_tree().get_first_node_in_group(&"game").set_force_combat(false)

func _on_timer_timeout() -> void:
	spawn()
