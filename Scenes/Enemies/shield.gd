extends StaticBody2D

@export var bullet_scene: PackedScene
@export var rotation_speed := 0.5

func on_hit(body: Bullet) -> void:
	var velocity := body.velocity.bounce((body.global_position - global_position).normalized())
	var bullet: Bullet = bullet_scene.instantiate()
	bullet.global_position = body.global_position
	bullet.velocity = velocity
	get_parent().get_parent().add_child(bullet)


func get_target_angle() -> float:
	return (get_tree().get_first_node_in_group("player").global_position - global_position).angle()

func _ready() -> void:
	rotation = get_target_angle()

func _process(delta: float) -> void:
	var diff := get_target_angle() - rotation
	if abs(diff) > PI:
		diff = TAU - diff

	rotation += clamp(diff, -delta * rotation_speed, delta * rotation_speed)
