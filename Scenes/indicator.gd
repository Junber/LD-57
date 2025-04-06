extends Sprite2D

@export var distance := 500.0

var enemy: Node2D
var camera: Camera2D
var spawn_time: int

func _process(_delta: float) -> void:
	if !enemy:
		queue_free()
		return
	var direction: Vector2 = enemy.global_position - get_parent().global_position
	modulate.a = min(direction.length() / distance - 1.0, 0.7)
	position = direction.normalized() * distance / camera.zoom
	rotation = -direction.angle_to(Vector2.UP)
