extends Sprite2D

@export var textures: Array[Texture2D]

var max_value: int

func set_max_value(new_max_value: int) -> void:
	max_value = new_max_value

func set_value(value: int) -> void:
	@warning_ignore("integer_division")
	texture = textures[min(value, max_value) * (textures.size() - 1) / max_value]
