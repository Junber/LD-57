extends CanvasLayer

@export var top_ornaments: Dictionary[String, Texture2D]
@export var bottom_ornaments: Dictionary[String, Texture2D]
@export var default_label_setting: LabelSettings
@export var special_label_setting: Dictionary[String, LabelSettings]

@onready var text_parent: Control = $Control
@onready var dialog_appear_timer: Timer = $DialogAppearTimer
@onready var top_ornament: TextureRect = $Control/VBoxContainer/TopOrnament
@onready var bottom_ornament: TextureRect = $Control/VBoxContainer/BottomOrnament
@onready var label: RichTextLabel = $Control/VBoxContainer/MarginContainer/Label

var caller: Node
var last_file_name: String
var dialog_chunks: PackedStringArray = []
var dialog_progress := 0
var waiting := false
var shaking_intensity := 0.0
var text_speed := 1.0
var fade_text_time := 0.0

var dialog_variables: Dictionary[String, bool] = {}

var ornament_name := ""

func _ready() -> void:
	apply_label_setting(default_label_setting)

func start(new_caller: Node) -> void:
	caller = new_caller
	visible = true
	get_tree().paused = true
	show_next_line()

func finish() -> void:
	$AudioStreamPlayer.stop()
	visible = false
	get_tree().paused = false
	dialog_progress = 0

func load_file(dialog_file_name: String) -> void:
	dialog_chunks.clear()
	dialog_progress = 0
	var file := FileAccess.open(dialog_file_name, FileAccess.READ)
	for chunk in file.get_as_text(true).strip_edges().split("\n\n"):
		dialog_chunks.append(chunk.dedent())
	file.close()
	last_file_name = dialog_file_name

func apply_label_setting(setting: LabelSettings) -> void:
	if setting.font:
		label.add_theme_font_override(&"normal_font", setting.font)
	else:
		label.remove_theme_font_override(&"normal_font")
	label.add_theme_color_override(&"default_color", setting.font_color)
	label.add_theme_color_override(&"font_outline_color", setting.outline_color)
	label.add_theme_font_size_override(&"normal_font_size", setting.font_size)
	label.add_theme_constant_override(&"outline_size", setting.outline_size)

func show_error(error: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.dialog_text = "{0} (file: {1}, chunk: {2})\n\"{3}\"".format(
		[error, last_file_name, dialog_progress-1, dialog_chunks[dialog_progress-1]])
	get_tree().get_first_node_in_group(&"game").add_child(dialog)
	dialog.popup_centered()
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	finish()



func command_ornament(data: Array[String]) -> void:
	if data.size() != 1:
		return show_error("\"ornament\" command needs exactly 1 argument")

	ornament_name = data[0]
	apply_label_setting(special_label_setting.get(data[0], default_label_setting))
	show_next_line()

func command_if(data: Array[String]) -> void:
	if data.size() != 2:
		return show_error("\"if\" command needs exactly 2 arguments")

	if dialog_variables.get(data[0], false):
		var path = "res://Resources/Dialog/" + data[1]
		if !FileAccess.file_exists(path):
			return show_error("File " + data[1] + " not found")

		load_file(path)

	show_next_line()

func command_set(data: Array[String]) -> void:
	if data.size() != 1:
		return show_error("\"set\" command needs exactly 1 argument")

	dialog_variables.set(data[0], true)
	show_next_line()

func command_remove(data: Array[String]) -> void:
	if data.size() != 0:
		return show_error("\"remove\" command does not take arguments")

	caller.queue_free()
	show_next_line()

func command_combat(data: Array[String]) -> void:
	if data.size() != 1:
		return show_error("\"combat\" command needs exactly 1 argument")

	get_tree().call_group(&"spawner", &"initiate_combat", data[0], true)
	show_next_line()

func command_ability(data: Array[String]) -> void:
	if data.size() != 1:
		return show_error("\"ability\" command needs exactly 1 argument")

	var ability_name := data[0].capitalize()

	if !get_tree().get_first_node_in_group(&"player").SpecialAbility.has(ability_name):
		return show_error("Ability not found: " + ability_name)

	get_tree().call_group(&"player", &"set_ability", ability_name)
	show_next_line()

func command_shot_upgrade(data: Array[String]) -> void:
	if data.size() != 0:
		return show_error("\"shot_upgrade\" command does not take any arguments")

	get_tree().call_group(&"player", &"get_shot_upgrade")
	show_next_line()

func command_dash_upgrade(data: Array[String]) -> void:
	if data.size() != 0:
		return show_error("\"dash_upgrade\" command does not take any arguments")

	get_tree().call_group(&"player", &"get_dash_upgrade")
	show_next_line()

func command_level(data: Array[String]) -> void:
	if data.size() != 1:
		return show_error("\"level\" command needs exactly 1 argument")

	var path = "res://Scenes/Levels/" + data[0] + ".tscn"
	if !ResourceLoader.exists(path):
		return show_error("Level not found: " + data[0])

	get_tree().call_group(&"game", &"load_level", path)
	show_next_line()

func command_save(data: Array[String]) -> void:
	if data.size() != 0:
		return show_error("\"save\" command does not take any arguments")

	get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, &"game", &"save_game", "auto_save")
	show_next_line()

func command_sfx(data: Array[String]) -> void:
	if data.size() != 2:
		return show_error("\"sfx\" command needs exactly 2 argument")

	var path = "res://Resources/Sounds/" + data[0] + ".ogg"
	if !ResourceLoader.exists(path):
		return show_error("Sound not found: " + data[0])

	$AudioStreamPlayer.stream = load(path)
	$AudioStreamPlayer.volume_db = data[1].to_float()
	$AudioStreamPlayer.play()
	show_next_line()

func command_wait(data: Array[String]) -> void:
	if data.size() != 1:
		return show_error("\"wait\" command needs exactly 1 argument")

	if !data[0].is_valid_float():
		return show_error("Not a valid float: " + data[0])

	waiting = true
	var tween := create_tween()
	tween.tween_interval(data[0].to_float())
	tween.tween_callback(show_next_line)
	tween.tween_property(self, ^"waiting", false, 0.0)

func command_clear(data: Array[String]) -> void:
	if data.size() != 0:
		return show_error("\"clear\" command does not take any arguments")

	top_ornament.texture = null
	label.text = ""
	bottom_ornament.texture = null
	show_next_line()

func command_background_opacity(data: Array[String]) -> void:
	if data.size() != 1:
		return show_error("\"background_opacity\" command needs exactly 1 argument")

	if !data[0].is_valid_float():
		return show_error("Not a valid float: " + data[0])

	$ColorRect.color.a = data[0].to_float()
	show_next_line()

func command_background_color(data: Array[String]) -> void:
	if data.size() != 2:
		return show_error("\"background_color\" command needs exactly 2 argument")

	if !data[0].is_valid_float():
		return show_error("Not a valid float: " + data[0])
	if !data[1].is_valid_float():
		return show_error("Not a valid float: " + data[1])
	var x := data[0].to_float()
	create_tween().tween_property($ColorRect, ^"color", Color(x, x, x, $ColorRect.color.a), data[1].to_float())
	show_next_line()

func command_shaking_intensity(data: Array[String]) -> void:
	if data.size() != 1:
		return show_error("\"shaking_intensity\" command needs exactly 1 argument")

	if !data[0].is_valid_float():
		return show_error("Not a valid float: " + data[0])

	shaking_intensity = data[0].to_float()
	show_next_line()

func command_drink(data: Array[String]) -> void:
	if data.size() != 0:
		return show_error("\"drink\" command does not take any arguments")

	$DrunkEffect.increasing = true
	show_next_line()

func command_vignette_opacity(data: Array[String]) -> void:
	if data.size() != 1:
		return show_error("\"vignette_opacity\" command needs exactly 1 argument")

	if !data[0].is_valid_float():
		return show_error("Not a valid float: " + data[0])

	$VignetteEffect.set_opacity(data[0].to_float())
	show_next_line()

func command_school(data: Array[String]) -> void:
	if data.size() != 0:
		return show_error("\"school\" command does not take any arguments")

	get_tree().call_group(&"player", &"start_school")
	show_next_line()

func command_music(data: Array[String]) -> void:
	if data.size() != 2:
		return show_error("\"music\" command needs exactly 2 argument")

	var path = "res://Resources/Music/" + data[0] + ".wav"
	if !ResourceLoader.exists(path):
		return show_error("Sound not found: " + data[0])

	var calm := load(path)
	var battle: AudioStream

	var path_battle = "res://Resources/Music/" + data[0] + "_battle.wav"
	if ResourceLoader.exists(path_battle):
		battle = load(path_battle)

	if !data[1].is_valid_float():
		return show_error("Not a valid float: " + data[1])

	get_tree().call_group(&"game", &"set_music", calm, battle, data[1].to_float())
	show_next_line()

func command_text_speed(data: Array[String]) -> void:
	if data.size() != 1:
		return show_error("\"text_speed\" command needs exactly 1 argument")

	if !data[0].is_valid_float():
		return show_error("Not a valid float: " + data[0])

	text_speed = data[0].to_float()
	show_next_line()

func command_fade_text(data: Array[String]) -> void:
	if data.size() != 1:
		return show_error("\"fade_text\" command needs exactly 1 argument")

	if !data[0].is_valid_float():
		return show_error("Not a valid float: " + data[0])

	fade_text_time = data[0].to_float()
	show_next_line()

func command_iris_in(data: Array[String]) -> void:
	if data.size() != 0:
		return show_error("\"iris_in\" command needs exactly 0 arguments")
	$IrisInEffect.start()
	show_next_line()

var zoom_tween: Tween
func command_zoom(data: Array[String]) -> void:
	if data.size() != 2:
		return show_error("\"zoom\" command needs exactly 2 argument")

	if !data[0].is_valid_float():
		return show_error("Not a valid float: " + data[0])
	if !data[1].is_valid_float():
		return show_error("Not a valid float: " + data[1])

	if zoom_tween:
		zoom_tween.kill()
	zoom_tween = create_tween()

	var x := data[0].to_float()
	zoom_tween.tween_property(text_parent, ^"scale", Vector2(x,x), data[1].to_float())
	show_next_line()

func command_text_sound(data: Array[String]) -> void:
	if data.size() != 3:
		return show_error("\"text_sound\" command needs exactly 3 argument")

	var path := "res://Resources/Sounds/" + data[0] + ".ogg"
	if !ResourceLoader.exists(path):
		return show_error("Sound not found: " + data[0])
	if !data[1].is_valid_float():
		return show_error("Not a valid float: " + data[1])
	if !data[2].is_valid_float():
		return show_error("Not a valid float: " + data[2])

	var stream := AudioStreamRandomizer.new()
	stream.add_stream(0, load(path))
	stream.random_pitch = data[1].to_float()
	stream.random_volume_offset_db = data[2].to_float()
	$DialogAppearPlayer.stream = stream
	show_next_line()

var start_progress := 0.0
func add_text(text: String) -> void:
	set_progress(0.0)
	top_ornament.texture = top_ornaments.get(ornament_name, null)
	label.text = text
	bottom_ornament.texture = bottom_ornaments.get(ornament_name, null)

	var first_line := text.split("\n")[0]
	if first_line.ends_with(":") or first_line.contains(":") and first_line.ends_with("*"):
		start_progress = float(first_line.length()) / text.length()
		set_progress(start_progress)
	else:
		start_progress = 0.0

	dialog_appear_timer.start(fade_text_time if fade_text_time != 0.0 else
								text.length() * 0.01 / text_speed)
	play_appear_sound()

func show_next_line() -> void:
	if dialog_progress >= dialog_chunks.size():
		return finish()

	var next_line := dialog_chunks[dialog_progress]
	dialog_progress += 1

	if next_line.is_empty() or next_line[0] == '#':
		show_next_line()
	elif next_line[0] == '!':
		var colonIndex := next_line.find(":")
		var key := next_line.substr(1, colonIndex - 1 if colonIndex >= 0 else -1)
		var data := next_line.substr(colonIndex + 1).split(";") if colonIndex >= 0 else PackedStringArray()
		if has_method("command_" + key):
			call("command_" + key, data)
		else:
			show_error("Unknown command " + key)
	else:
		add_text(next_line)

func set_progress(x: float) -> void:
	if fade_text_time != 0.0:
		label.modulate.a = x
		label.visible_ratio = 1.0
	else:
		label.modulate.a = 1.0
		label.visible_ratio = x

func _process(_delta: float) -> void:
	if dialog_appear_timer.is_stopped():
		set_progress(1.0)
	else:
		set_progress(1.0 - (1.0 - start_progress) * dialog_appear_timer.time_left / dialog_appear_timer.wait_time)

	if shaking_intensity > 0 and !dialog_appear_timer.is_stopped():
		text_parent.position = Vector2(randf(), randf()) * shaking_intensity
	else:
		text_parent.position = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		if waiting:
			return

		if dialog_appear_timer.is_stopped() || fade_text_time != 0.0:
			show_next_line()
		else:
			dialog_appear_timer.stop()

func play_appear_sound() -> void:
	$DialogAppearPlayer.play()
	$DialogAppearPlayer/Timer.start(randf_range(0.1, 0.2))

func _on_timer_timeout() -> void:
	if !dialog_appear_timer.is_stopped():
		play_appear_sound()


func get_save_data() -> Array:
	return [dialog_variables, text_speed]

func load_save_data(data: Array) -> void:
	dialog_variables = data[0]
	text_speed = data[1]
