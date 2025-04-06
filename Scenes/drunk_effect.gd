extends CanvasLayer

var intensity := 0.0
var increasing := false

func _process(delta: float) -> void:
	return
	if intensity <= 0 and !increasing:
		$ColorRect.visible = false
	else:
		if increasing:
			intensity += delta / 5.0
			if intensity >= 1.0:
				increasing = false
		else:
			intensity -= delta / 60.0
		$ColorRect.visible = true
		$ColorRect.material.set_shader_parameter(&"intensity", intensity)

func get_save_data() -> Array:
	return [intensity, increasing]

func load_save_data(data: Array) -> void:
	intensity = data[0]
	increasing = data[1]
