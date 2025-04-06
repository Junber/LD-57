extends StaticBody2D

func set_combat(in_combat: bool) -> void:
	visible = in_combat
	process_mode = PROCESS_MODE_INHERIT if in_combat else PROCESS_MODE_DISABLED
