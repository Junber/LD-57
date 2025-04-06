extends CanvasLayer

@export var top_ornaments: Dictionary[String, Texture2D]
@export var bottom_ornaments: Dictionary[String, Texture2D]

@onready var dialog_appear_timer := $DialogAppearTimer
@onready var label: RichTextLabel = $Label

var caller: Node
var last_file_name: String
var dialog_chunks: PackedStringArray = []
var dialog_progress := 0

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

func add_text(text: String) -> void:
	label.clear()
	if !ornament_name.is_empty():
		label.add_image(top_ornaments[ornament_name])
		label.add_text("\n")

	label.add_text(text)

	if !ornament_name.is_empty():
		label.add_text("\n")
		label.add_image(bottom_ornaments[ornament_name])

	#dialog_appear_timer.start(1.0)

func show_next_line() -> void:
	if dialog_progress >= dialog_chunks.size():
		return finish()

	var next_line := dialog_chunks[dialog_progress]
	dialog_progress += 1

	if next_line[0] == '!':
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
		else:
			show_error("Unknown command " + key)
	else:
		add_text(next_line)

func _process(_delta: float) -> void:
	if dialog_appear_timer.is_stopped():
		label.modulate.a = 1.0
	else:
		label.modulate.a = 1.0 - dialog_appear_timer.time_left / dialog_appear_timer.wait_time

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		if dialog_appear_timer.is_stopped():
			show_next_line()
		else:
			dialog_appear_timer.stop()
