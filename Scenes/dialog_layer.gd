extends CanvasLayer

@export var top_ornaments: Dictionary[String, Texture2D]
@export var bottom_ornaments: Dictionary[String, Texture2D]

@onready var dialog_appear_timer := $DialogAppearTimer
@onready var top_ornament: TextureRect = $Control/VBoxContainer/TopOrnament
@onready var bottom_ornament: TextureRect = $Control/VBoxContainer/BottomOrnament
@onready var label: RichTextLabel = $Control/VBoxContainer/Label

var caller: Node
var last_file_name: String
var dialog_chunks: PackedStringArray = []
var dialog_progress := 0
var waiting := false
var shaking_intensity := 0.0

var dialog_variables: Dictionary[String, bool] = {}

var ornament_name := ""

func start(new_caller: Node) -> void:
	caller = new_caller
	visible = true
	get_tree().paused = true
	show_next_line()

func finish() -> void:
	visible = false
	get_tree().paused = false
	dialog_progress = 0

func load_file(dialog_file_name: String) -> void:
	dialog_chunks.clear()
	var file := FileAccess.open(dialog_file_name, FileAccess.READ)
	for chunk in file.get_as_text(true).split("\n\n"):
		dialog_chunks.append(chunk.dedent())
	file.close()
	last_file_name = dialog_file_name

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
	if data[0] not in top_ornaments:
		return show_error("Ornament " + data[0] + " not found")

	ornament_name = data[0]
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

	get_tree().call_group(&"spawner", &"initiate_combat", data[0])
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
	if !FileAccess.file_exists(path):
		return show_error("Level not found: " + data[0])

	get_tree().call_group(&"game", &"load_level", path)
	show_next_line()

func command_save(data: Array[String]) -> void:
	if data.size() != 0:
		return show_error("\"save\" command does not take any arguments")

	get_tree().call_group(&"game", &"save_game", "auto_save")
	show_next_line()

func command_sfx(data: Array[String]) -> void:
	if data.size() != 1:
		return show_error("\"sfx\" command needs exactly 1 argument")

	var path = "res://Resources/Sounds/" + data[0] + ".wav"
	if !FileAccess.file_exists(path):
		return show_error("Sound not found: " + data[0])

	$AudioStreamPlayer.stream = load(path)
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

	$ColorRect.color = Color(0.9, 0.9, 0.9, data[0].to_float())
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

func add_text(text: String) -> void:
	label.visible_ratio = 0.0

	top_ornament.texture = top_ornaments.get(ornament_name, null)
	label.text = text
	bottom_ornament.texture = bottom_ornaments.get(ornament_name, null)

	dialog_appear_timer.start(1.0)

func show_next_line() -> void:
	if dialog_progress >= dialog_chunks.size():
		return finish()

	var next_line := dialog_chunks[dialog_progress]
	dialog_progress += 1

	if next_line[0] == '#':
		show_next_line()
	elif next_line[0] == '!':
		var colonIndex := next_line.find(":")
		var key := next_line.substr(1, colonIndex - 1 if colonIndex >= 0 else -1)
		var data := next_line.substr(colonIndex + 1).split(";") if colonIndex >= 0 else PackedStringArray()
		if key == "ornament":
			command_ornament(data)
		elif key == "if":
			command_if(data)
		elif key == "set":
			command_set(data)
		elif key == "remove":
			command_remove(data)
		elif key == "combat":
			command_combat(data)
		elif key == "ability":
			command_ability(data)
		elif key == "shot_upgrade":
			command_shot_upgrade(data)
		elif key == "dash_upgrade":
			command_dash_upgrade(data)
		elif key == "level":
			command_level(data)
		elif key == "save":
			command_save(data)
		elif key == "sfx":
			command_sfx(data)
		elif key == "wait":
			command_wait(data)
		elif key == "clear":
			command_clear(data)
		elif key == "background_opacity":
			command_background_opacity(data)
		elif key == "shaking_intensity":
			command_shaking_intensity(data)
		elif key == "drink":
			command_drink(data)
		else:
			show_error("Unknown command " + key)
	else:
		add_text(next_line)

func _process(_delta: float) -> void:
	if dialog_appear_timer.is_stopped():
		label.visible_ratio = 1.0
	else:
		label.visible_ratio = 1.0 - dialog_appear_timer.time_left / dialog_appear_timer.wait_time

	if shaking_intensity > 0 and !dialog_appear_timer.is_stopped():
		$Control.position = Vector2(randf(), randf()) * shaking_intensity
	else:
		$Control.position = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		if waiting:
			return

		if dialog_appear_timer.is_stopped():
			show_next_line()
		else:
			dialog_appear_timer.stop()


func get_save_data() -> Dictionary[String, bool]:
	return dialog_variables

func load_save_data(data: Dictionary[String, bool]) -> void:
	dialog_variables = data
