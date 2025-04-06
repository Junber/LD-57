extends Area2D

var bodies_inside: Array[PhysicsBody2D] = []

func _on_body_entered(body: PhysicsBody2D) -> void:
	if body is Bullet:
		body.queue_free()
	else:
		bodies_inside.push_back(body)


func _on_body_exited(body: PhysicsBody2D) -> void:
	bodies_inside.erase(body)

func _physics_process(delta: float) -> void:
	var index_to_remove := -1
	for i in range(bodies_inside.size()):
		var body := bodies_inside[i]
		if body:
			var direction := (body.global_position - global_position).normalized()
			body.move_and_collide(direction * delta * 3000.0)
		else:
			index_to_remove = i
	if index_to_remove >= 0:
		bodies_inside.remove_at(index_to_remove)


func _on_life_timer_timeout() -> void:
	queue_free()
