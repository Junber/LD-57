extends AnimatedSprite2D

@export_file("*.txt") var dialog_file_name: String
@export_file("*.txt") var bullet_text_file: String
@export var bullet_scene: PackedScene

@onready var initial_position := position

var first := true
func _process(_delta: float) -> void:
	if first:
		first = false
		_on_timer_2_timeout()
	position = initial_position + Vector2.from_angle(randf() * TAU) * randf() * 10.0

func _on_timer_timeout() -> void:
	var tween := create_tween()
	tween.tween_property($CanvasLayer/ColorRect, ^"color", Color.WHITE, 3.0)
	tween.parallel().tween_property($AudioStreamPlayer2D, ^"volume_linear", 0.0, 3.0)
	tween.tween_interval(0.5)
	tween.tween_callback(end)

func end() -> void:
	var dialog_layer := get_tree().get_first_node_in_group(&"dialog")
	dialog_layer.load_file(dialog_file_name)
	dialog_layer.start(self)

func spawn_bullet(direction: Vector2) -> void:
	var bullet: Bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.velocity = direction * 1000.0
	get_parent().add_child(bullet)
	if !bullet_text_file.is_empty():
		bullet.set_text_from_file(bullet_text_file)

func _on_timer_2_timeout() -> void:
	$AudioStreamPlayer2D.play()
	var angle_offset := randf() * TAU
	var bullet_amount := randi_range(5, 10)
	for i in range(bullet_amount):
		var angle := i * TAU / bullet_amount + angle_offset
		spawn_bullet(Vector2.UP.rotated(angle))


func _on_timer_3_timeout() -> void:
	if randf() < 0.2:
		$AudioStreamPlayer2D.play()
