extends Area2D

@export_file("*.txt") var dialog_file_name: String
@export var once := false

var player_nearby := false

func interact() -> void:
	var dialog_layer := get_tree().get_first_node_in_group(&"dialog")
	dialog_layer.load_file(dialog_file_name)
	dialog_layer.start(self)

func try_trigger() -> void:
	if player_nearby and !get_tree().get_first_node_in_group(&"game").in_combat:
		interact()
		if once:
			queue_free()

func set_combat(_in_combat: bool) -> void:
	try_trigger()

func _on_body_entered(body: Node2D) -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	if !overlaps_body(body):
		return
	player_nearby = true
	try_trigger()

func _on_body_exited(_body: Node2D) -> void:
	player_nearby = false

func get_save_data() -> Variant:
	return true

func load_save_data(_data: Variant) -> void:
	pass
