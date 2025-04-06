extends Bullet

func _physics_process(delta: float) -> void:
	velocity = velocity.rotated(tan(Time.get_ticks_usec() / 500000.0) * delta * 10.0)
	super(delta)
