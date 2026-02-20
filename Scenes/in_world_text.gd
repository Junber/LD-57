extends Label

static var label_settings_cache: Dictionary[int, LabelSettings] = {}
func set_text_size(x: int) -> void:
	if !label_settings_cache.has(x):
		var settings: LabelSettings = label_settings.duplicate()
		settings.font_size = x
		label_settings_cache[x] = settings
	label_settings = label_settings_cache[x]

static var lines_left: Dictionary[String, PackedStringArray]= {}
func set_text_from_file(file_name: String) -> void:
	var lines: PackedStringArray
	if lines_left.has(file_name):
		lines = lines_left[file_name]
	else:
		var file := FileAccess.open(file_name, FileAccess.READ)
		lines = file.get_as_text(true).split("\n")
		file.close()
		lines_left[file_name] = lines

	var i := randi_range(0, lines.size() - 1)
	text = lines[i]
	lines.remove_at(i)
	if lines.is_empty():
		lines_left.erase(file_name)

func play_sound(stream: AudioStream) -> void:
	$AudioStreamPlayer.stream = stream
	$AudioStreamPlayer.play()

func _ready() -> void:
	var tween := create_tween()
	tween.tween_interval(3.0)
	tween.parallel().tween_property(self, ^"position", position - Vector2(0, 50), 3.5)
	tween.tween_property(self, ^"modulate", Color.TRANSPARENT, 0.5)
	tween.tween_callback(queue_free)
