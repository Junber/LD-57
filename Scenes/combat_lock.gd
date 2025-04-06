extends StaticBody2D

func _ready() -> void:
	set_combat(get_tree().get_first_node_in_group(&"game").in_combat)

func set_combat(in_combat: bool) -> void:
	visible = in_combat
	process_mode = PROCESS_MODE_INHERIT if in_combat else PROCESS_MODE_DISABLED
