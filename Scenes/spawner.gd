extends Node2D

@export var spawner_name: String
@export_file("*.txt") var after_combat_dialog_file_name: String

@export var waves: Array[Wave]
@export var spawn_indicator_scene: PackedScene

@onready var timer: Timer = $Timer
@onready var top_left: Vector2 = $TopLeft.position
@onready var bottom_right: Vector2 = $BottomRight.position

var next_spawn := 0
var current_wave := 0
var starting := false

func initiate_combat(combat_name: String, save: bool) -> void:
	if spawner_name == combat_name:
		starting = true
		get_tree().get_first_node_in_group(&"game").set_in_combat(true, save)
		process_mode = Node.PROCESS_MODE_INHERIT
		spawn()
		starting = false


func spawn() -> void:
	if current_wave >= waves.size():
		return
	var wave := waves[current_wave]

	var spawn_indicator := spawn_indicator_scene.instantiate()
	spawn_indicator.enemy_scene = wave.enemy_scenes[next_spawn]
	spawn_indicator.global_position = \
		global_position + Vector2(randf_range(top_left.x, bottom_right.x),
								  randf_range(top_left.y, bottom_right.y))
	get_parent().add_child(spawn_indicator)
	spawn_indicator.start(wave.spawn_indicator_time)

	next_spawn += 1
	if next_spawn >= wave.enemy_scenes.size():
		timer.start(wave.delay_after)
		current_wave += 1
		next_spawn = 0
	else:
		timer.start(wave.delay_during)

func _process(_delta: float) -> void:
	if get_tree().get_node_count_in_group(&"enemy") == 0 and\
	get_tree().get_node_count_in_group(&"spawn_indicator") == 0:
		if current_wave >= waves.size():
			queue_free()
			get_tree().get_first_node_in_group(&"game").set_in_combat(false, false)
			if after_combat_dialog_file_name.is_empty():
				return
			var dialog_layer := get_tree().get_first_node_in_group(&"dialog")
			dialog_layer.load_file(after_combat_dialog_file_name)
			dialog_layer.start(self)
		else:
			spawn()

func get_save_data() -> bool:
	return starting

func load_save_data(data: bool) -> void:
	if data:
		initiate_combat(spawner_name, false)
