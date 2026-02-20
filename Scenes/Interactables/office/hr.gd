extends "res://Scenes/Interactables/office/coworker.gd"

@export var text_scene: PackedScene
@export_file("*.txt") var text_file: String

func interact() -> void:
	super()
	$Timer.stop()

func _on_timer_timeout() -> void:
	var text := text_scene.instantiate()
	text.global_position = $TextPos.global_position
	text.set_text_from_file(text_file)
	text.set_text_size(80)
	get_parent().add_child(text)
