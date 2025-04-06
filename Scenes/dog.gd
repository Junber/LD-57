extends Node2D

@export var bullet_scene: PackedScene
@export var bullet_speed: float

func _on_life_timer_timeout() -> void:
	queue_free()


func _on_shot_timer_timeout() -> void:
	var closest_enemy: Node2D = null
	var closest_distance := INF
	for enemy: Node2D in get_tree().get_nodes_in_group(&"enemy"):
		var distance := (enemy.global_position - global_position).length()
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy

	if !closest_enemy:
		return
	var direction := (closest_enemy.global_position - global_position).normalized()

	var bullet: Bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.velocity = direction * bullet_speed
	get_parent().add_child(bullet)
