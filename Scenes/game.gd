extends Node2D

@export_file("*.txt") var start_dialog := ""

@onready var calmMusic: AudioStreamPlayer = $CalmMusicPlayer
@onready var battleMusic: AudioStreamPlayer = $BattleMusicPlayer

var in_combat := false
var current_level: Node2D = null

func _ready() -> void:
	battleMusic.volume_linear = 0.0
	start.call_deferred()

func start() -> void:
	if load_game("auto_save"):
		return
	$DialogLayer.load_file(start_dialog)
	$DialogLayer.start(self)

func set_music_no_fade(calm: AudioStream, battle: AudioStream) -> void:
	calmMusic.stream = calm
	if battle:
		battleMusic.stream = battle
	calmMusic.play()
	battleMusic.play()

var calm_stream_path: String
var battle_stream_path: String
func set_music(calm: AudioStream, battle: AudioStream, fade_time: float) -> void:
	var prev_calm := calmMusic.volume_linear
	var prev_battle := battleMusic.volume_linear

	calm_stream_path = calm.resource_path
	if battle:
		battle_stream_path = battle.resource_path

	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(calmMusic, ^"volume_linear", 0.0, fade_time)
	tween.parallel().tween_property(battleMusic, ^"volume_linear", 0.0, fade_time)
	tween.tween_callback(set_music_no_fade.bind(calm, battle))
	tween.tween_property(calmMusic, ^"volume_linear", prev_calm, fade_time)
	tween.parallel().tween_property(battleMusic, ^"volume_linear", prev_battle, fade_time)

func load_level(path: String) -> void:
	if current_level:
		current_level.name = "DELETING"
		current_level.queue_free()
	current_level = load(path).instantiate()
	add_child.call_deferred(current_level)

func set_in_combat(new_in_combat: bool, save: bool) -> void:
	in_combat = new_in_combat

	var fade_time := 1.0
	var tween := create_tween().set_parallel()
	tween.tween_property(calmMusic, ^"volume_linear", 0.0 if in_combat else 1.0, fade_time)
	tween.tween_property(battleMusic, ^"volume_linear", 1.0 if in_combat else 0.0, fade_time)

	if save:
		save_game("auto_save")
	get_tree().call_group(&"combat_listener", &"set_combat", in_combat)

func get_save_path(save_name: String) -> String:
	return "user://" + save_name + ".save"

func save_game(save_name: String) -> void:
	var data := {}
	for node in get_tree().get_nodes_in_group(&"saveable"):
		if !node.is_queued_for_deletion():
			data[node.get_path()] = node.get_save_data()
	var file := FileAccess.open(get_save_path(save_name), FileAccess.WRITE)
	file.store_var(data)
	file.close()

func load_priotity_order(a: Node, b: Node) -> bool:
	return \
		(a.get_load_priotity() if a.has_method(&"get_load_priotity") else 0) > \
		(b.get_load_priotity() if b.has_method(&"get_load_priotity") else 0)

func load_game(save_name: String) -> bool:
	if !FileAccess.file_exists(get_save_path(save_name)):
		return false
	var file := FileAccess.open(get_save_path(save_name), FileAccess.READ)
	var data: Dictionary = file.get_var()
	file.close()

	load_save_data(data.get(get_path()))
	load_node_data.call_deferred(data)
	return true

func load_node_data(data: Dictionary) -> void:
	var nodes := get_tree().get_nodes_in_group(&"saveable")
	nodes.sort_custom(load_priotity_order)
	for node in nodes:
		if node != self and !node.find_parent("DELETING"):
			var entry = data.get(node.get_path(), null)
			if entry == null:
				node.queue_free()
			else:
				node.load_save_data(entry)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"reload"):
		load_game("auto_save")
	if event is InputEventKey and event.keycode == KEY_F9:
		DirAccess.remove_absolute(get_save_path("auto_save"))
		get_tree().reload_current_scene()

func get_save_data() -> Array:
	return [
		in_combat,
		current_level.scene_file_path,
		calm_stream_path,
		battle_stream_path,
	]

func load_save_data(data: Array) -> void:
	load_level(data[1])
	in_combat = data[0]
	get_tree().call_group(&"combat_listener", &"set_combat", in_combat)
	calmMusic.volume_linear   = 0.0 if in_combat else 1.0
	battleMusic.volume_linear = 1.0 if in_combat else 0.0
	set_music(load(data[2]), load(data[3]) if data[3] else null, 0.0)
