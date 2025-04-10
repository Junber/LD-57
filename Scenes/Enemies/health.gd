extends Sprite2D

@export var textures: Array[Texture2D]

var max_value: int

func set_value(value: int) -> void:
	texture = textures[int(value * (textures.size() - 1) / max_value)]
