extends StaticBody2D

@export var bullet_scene: PackedScene

func set_end_points(a: Vector2, b: Vector2) -> void:
	global_position = a
	$CollisionShape.shape.b = b - a
	$Line.points[1] = b - a

func on_hit(body: Node2D) -> void:
	var bullet := body as Bullet
	if !bullet:
		return

	var new_bullet: Bullet = bullet_scene.instantiate()
	new_bullet.global_position = bullet.global_position
	new_bullet.velocity = bullet.velocity.reflect($CollisionShape.shape.b.normalized())
	get_parent().add_child.call_deferred(new_bullet)
	add_collision_exception_with(new_bullet)

func _on_life_timer_timeout() -> void:
	queue_free()
