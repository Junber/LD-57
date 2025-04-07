extends CanvasLayer

func _ready() -> void:
	visible = false
	set_parameter(0.0)

func set_opacity(opacity: float) -> void:
	if opacity > 0.0:
		visible = true
	var tween := create_tween()
	tween.tween_method(set_parameter, get_parameter(), opacity, 2.0)
	if opacity <= 0.0:
		tween.tween_property(self,^"visible", false, 0.0)

func get_parameter() -> float:
	return $ColorRect.material.get_shader_parameter(&"opacity")

func set_parameter(opacity: float) -> void:
	$ColorRect.material.set_shader_parameter(&"opacity", opacity)
