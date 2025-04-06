extends Camera2D

func get_save_data() -> Array:
	return [get_target_position(), zoom]

func load_save_data(data: Array) -> void:
	global_position = data[0]
	zoom = data[1]
	reset_smoothing()
