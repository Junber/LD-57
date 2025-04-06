extends Node2D

@export var spawner_name: String
@export_file("*.txt") var after_combat_dialog_file_name: String

@export var enemies_to_spawn := 2
@export var enemy_scenes: Array[PackedScene]
@export var spawn_indicator_scene: PackedScene

var next_spawn := 0
var starting := false

func initiate_combat(combat_name: String) -> void:
	if spawner_name == combat_name:
		starting = true
		get_tree().get_first_node_in_group(&"game").set_in_combat(true)
		spawn()
		$Timer.start()
		starting = false


func spawn() -> void:
	if enemies_to_spawn <= 0:
		return
	var spawn_indicator := spawn_indicator_scene.instantiate()
	spawn_indicator.enemy_scene = enemy_scenes[next_spawn]
	spawn_indicator.global_position = \
		global_position + Vector2(randf_range(-500.0, 500.0), randf_range(-500.0, 500.0))
	get_parent().add_child(spawn_indicator)
	spawn_indicator.start(2.0)

	next_spawn = (next_spawn + 1) % enemy_scenes.size()
	enemies_to_spawn -= 1

func _process(_delta: float) -> void:
	if enemies_to_spawn <= 0:
		if get_tree().get_node_count_in_group(&"enemy") == 0 and\
		get_tree().get_node_count_in_group(&"spawn_indicator") == 0:
			queue_free()
			get_tree().get_first_node_in_group(&"game").set_in_combat(false)
			if after_combat_dialog_file_name.is_empty():
				return
			var dialog_layer := get_tree().get_first_node_in_group(&"dialog")
			dialog_layer.load_file(after_combat_dialog_file_name)
			dialog_layer.start(self)

func _on_timer_timeout() -> void:
	spawn()

func get_save_data() -> bool:
	return starting

func load_save_data(data: bool) -> void:
	if data:
		initiate_combat(spawner_name)
