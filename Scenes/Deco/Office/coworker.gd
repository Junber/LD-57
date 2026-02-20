extends "res://Scenes/Interactables/trigger.gd"

@export var text_scene: PackedScene
@export var textures: Array[Texture2D]

func interact() -> void:
	if !$DialogCooldown.is_stopped():
		return
	var text := text_scene.instantiate()
	text.global_position = $TextPos.global_position
	text.set_text_from_file(dialog_file_name)
	get_parent().add_child(text)
	$DialogCooldown.start()

func rand() -> int:
	return rand_from_seed(int(global_position.x))[0] + rand_from_seed(int(global_position.y))[0]

func _ready() -> void:
	@warning_ignore("integer_division")
	var i := 2 * (rand() % (textures.size() / 2))
	$Sprite.texture = textures[i]
	$Sprite2.texture = textures[i + 1]

func _on_anim_timer_timeout() -> void:
	$Sprite.visible = !$Sprite.visible
	$Sprite2.visible = !$Sprite2.visible
