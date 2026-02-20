extends Area2D

@onready var text_box := $TextBox
@onready var text := $Text
@onready var collision_shape := $CollisionShape
@export_file("*.txt") var bullet_text_file: String

func set_text_from_file(file_name: String) -> void:
	var file := FileAccess.open(file_name, FileAccess.READ)
	var lines := file.get_as_text(true).split("\n")
	file.close()
	text.text = lines[randi_range(0, lines.size() - 1)]

func _ready() -> void:
	set_text_from_file(bullet_text_file)
	text.visible = false
	var tween := create_tween()
	tween\
		.tween_property(text_box, ^"modulate", Color.RED, 1.0)\
		.from(Color(1.0, 1.0, 1.0, 0.3))
	tween.tween_callback(end_telegraphing)

func end_telegraphing() -> void:
	text.visible = true
	text_box.modulate = Color.WHITE
	collision_shape.disabled = false
	$LifeTimer.start()


func _on_life_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method(&"on_hit"):
		body.on_hit(self)
	queue_free()
