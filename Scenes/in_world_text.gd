extends Label

func set_text_from_file(file_name: String) -> void:
	var file := FileAccess.open(file_name, FileAccess.READ)
	var lines := file.get_as_text(true).split("\n")
	file.close()
	text = lines[randi_range(0, lines.size() - 1)]

func _ready() -> void:
	var tween := create_tween()
	tween.tween_interval(3.0)
	tween.parallel().tween_property(self, ^"position", position - Vector2(0, 50), 3.5)
	tween.tween_property(self, ^"modulate", Color.TRANSPARENT, 0.5)
	tween.tween_callback(queue_free)
