extends Bullet

func set_text_from_file(file_name: String) -> void:
	var file := FileAccess.open(file_name, FileAccess.READ)
	var lines := file.get_as_text(true).split("\n")
	file.close()
	set_text(lines[randi_range(0, lines.size() - 1)])

func set_text(text: String) -> void:
	$Label.text = text
	update_hitbox.call_deferred()

func update_hitbox() -> void:
	$CollisionShape.shape.size = $Label.get_rect().size

func _ready() -> void:
	set_text("Texting you ;)")
	super()
