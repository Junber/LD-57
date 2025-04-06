extends CharacterBody2D
class_name Bullet

func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity*delta)
	if collision:
		var body := collision.get_collider()
		if body.has_method(&"on_hit"):
			body.on_hit(self)
		queue_free()


func _on_life_timer_timeout() -> void:
	queue_free()
