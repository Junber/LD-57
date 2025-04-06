extends Sprite2D

@onready var progress: Range = $Progress

var enemy_scene: PackedScene

func start(time: float) -> void:
	progress.max_value = 1.0
	var tween := create_tween()
	tween.tween_property(progress, ^"value", 1.0, time).from(0.0)
	tween.tween_callback(spawn)

func spawn() -> void:
	var enemy: Node2D = enemy_scene.instantiate()
	enemy.global_position = global_position
	get_parent().add_child(enemy)
	queue_free()
