extends Area2D
class_name Bullet

var velocity: Vector2

func _physics_process(delta: float) -> void:
	position += velocity*delta


func _on_life_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method(&"on_hit"):
		body.on_hit()
	queue_free()
