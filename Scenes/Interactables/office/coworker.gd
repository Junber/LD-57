extends "res://Scenes/Interactables/interactable.gd"

@export var textures: Array[Texture2D]

func rand() -> int:
	return rand_from_seed(int(global_position.x))[0] + rand_from_seed(int(global_position.y))[0]

func _ready() -> void:
	super()
	@warning_ignore("integer_division")
	var i := 2 * (rand() % (textures.size() / 2))
	$Sprite.texture = textures[i]
	$Sprite2.texture = textures[i + 1]
	if scale.x < 0.0:
		$Indicator.scale.x = -$Indicator.scale.x

func _on_anim_timer_timeout() -> void:
	$Sprite.visible = !$Sprite.visible
	$Sprite2.visible = !$Sprite2.visible
