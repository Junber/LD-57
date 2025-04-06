extends Node2D

var in_combat := false
var force_combat := false
var current_level: Node2D = null

func _ready() -> void:
	load_level("res://Scenes/Levels/office.tscn")

func load_level(path: String) -> void:
	if current_level:
		current_level.name = "DELETING"
		current_level.queue_free()
	current_level = load(path).instantiate()
	add_child.call_deferred(current_level)

func set_force_combat(new_force_combat: bool) -> void:
	force_combat = new_force_combat
	if force_combat and !in_combat:
		in_combat = true
		save_game("auto_save")
		get_tree().call_group(&"combat_listener", &"set_combat", in_combat)

func get_save_path(save_name: String) -> String:
	return "user://" + save_name + ".save"

func save_game(save_name: String) -> void:
	var data := {}
	for node in get_tree().get_nodes_in_group(&"saveable"):
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
			node.load_save_data(data.get(node.get_path(), null))

func _process(_delta: float) -> void:
	if !force_combat and in_combat:
		if get_tree().get_node_count_in_group(&"enemy") == 0 and\
		get_tree().get_node_count_in_group(&"spawn_indicator") == 0:
			in_combat = false
			get_tree().call_group(&"combat_listener", &"set_combat", in_combat)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"reload"):
		load_game("auto_save")

func get_save_data() -> Array:
	return [in_combat, force_combat, current_level.scene_file_path]

func load_save_data(data: Array) -> void:
	load_level(data[2])
	in_combat = data[0]
	force_combat = data[1]
	get_tree().call_group(&"combat_listener", &"set_combat", in_combat)
