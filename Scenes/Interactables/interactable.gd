extends StaticBody2D

@export_file("*.txt") var dialog_file_name: String

@onready var indicator := $Indicator

var player_nearby := false

func interact() -> void:
	var dialog_layer := get_tree().get_first_node_in_group(&"dialog")
	dialog_layer.load_file(dialog_file_name)
	dialog_layer.start(self)

func update_indicator() -> void:
	indicator.visible = player_nearby and !get_tree().get_first_node_in_group(&"game").in_combat

func _ready() -> void:
	update_indicator()

func _on_interaction_range_body_entered(_body: Node2D) -> void:
	player_nearby = true
	update_indicator()

func _on_interaction_range_body_exited(_body: Node2D) -> void:
	player_nearby = false
	update_indicator()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"interact") and indicator.visible:
		interact()

func set_combat(_in_combat: bool) -> void:
	update_indicator()

func get_save_data() -> Variant:
	return true

func load_save_data(_data: Variant) -> void:
	pass
