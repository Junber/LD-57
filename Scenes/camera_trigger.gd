extends Area2D

@export var target_zoom := 0.75
@export var zoom_time := 1.0


func _on_body_entered(_body: Node2D) -> void:
	var center: Vector2 = $CollisionShape.global_position
	var collision_shape: RectangleShape2D = $CollisionShape.shape
	var camera := get_viewport().get_camera_2d()
	camera.limit_left = roundi(center.x - collision_shape.size.x / 2.0)
	camera.limit_right = roundi(center.x + collision_shape.size.x / 2.0)
	camera.limit_top = roundi(center.y - collision_shape.size.y / 2.0)
	camera.limit_bottom = roundi(center.y + collision_shape.size.y / 2.0)
	create_tween()\
		.tween_property(camera, ^"zoom", Vector2(target_zoom, target_zoom), zoom_time)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)

func _on_body_exited(_body: Node2D) -> void:
	var camera := get_viewport().get_camera_2d()
	if !camera:
		push_warning("Camera not found")
		return
	var large_number := 10000000
	camera.limit_left = -large_number
	camera.limit_right = large_number
	camera.limit_top = -large_number
	camera.limit_bottom = large_number
	create_tween().tween_property(camera, ^"zoom", Vector2(1, 1), zoom_time)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)
