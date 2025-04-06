extends Area2D

@onready var text_box := $TextBox
@onready var text := $Text
@onready var collision_shape := $CollisionShape

func _ready() -> void:
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
		body.on_hit()
	queue_free()
