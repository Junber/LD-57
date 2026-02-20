extends CharacterBody2D
class_name Bullet

@export var flip := true

func _ready() -> void:
	rotation = velocity.angle()
	if abs(rotation) > PI / 2:
		rotation = -PI * sign(rotation) + rotation
		if flip:
			scale.x = -scale.x
	$CollisionShape.global_position = global_position + $CollisionShape.position

func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity*delta)
	if collision:
		var body := collision.get_collider()
		if body.has_method(&"on_hit"):
			body.on_hit(self)
		queue_free()


func _on_life_timer_timeout() -> void:
	queue_free()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method(&"on_hit"):
		body.on_hit(self)
	queue_free()
