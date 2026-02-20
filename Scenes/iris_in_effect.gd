extends CanvasLayer

func _ready() -> void:
	visible = false

func set_size(x: float) -> void:
	$ColorRect.material.set_shader_parameter(&"size", x)

func start() -> void:
	visible = true
	set_size(0.0)
	var tween := create_tween()
	tween.tween_interval(0.1)
	tween.tween_method(set_size, 0, 2000, 1.0)
	tween.tween_property(self, ^"visible", false, 0.0)
