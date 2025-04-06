extends CharacterBody2D

@export var bullet_scene: PackedScene
@export var indicator_scene: PackedScene
@export var move_speed := 1000.0
@export var acceleration := 7.0
@export var dash_speed := 3000.0
@export var bullet_speed := 3000.0
@export var max_health := 5

@onready var shoot_timer: Timer = $ShootCooldown
@onready var iframe_timer: Timer = $IFrame
@onready var dash_timer: Timer = $DashTimer
@onready var dash1_cooldown: Timer = $Dash1Cooldown
@onready var dash2_cooldown: Timer = $Dash2Cooldown
@onready var health_bar: Range = $UI/Health
@onready var dash1_bar: Range = $UI/Dash1
@onready var dash2_bar: Range = $UI/Dash2

@onready var sprite: Node2D = $AnimatedSprite
@onready var bullet_spawn_point: Node2D = $BulletSpawnPosition

var health: int
var slowdown_indicators: Array[Node] = []

func _ready() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	dash1_bar.max_value = dash1_cooldown.wait_time
	dash2_bar.max_value = dash2_cooldown.wait_time

func current_slowdown() -> float:
	var time := Time.get_ticks_msec()
	var slowdown := 1.0
	var index_to_remove := -1
	for i in range(slowdown_indicators.size()):
		var indicator = slowdown_indicators[i]
		if indicator:
			slowdown *= 1.0 / pow(1 + (time - indicator.spawn_time) * 0.0005, 0.7)
		else:
			index_to_remove = i
	if index_to_remove >= 0:
		slowdown_indicators.remove_at(index_to_remove)
	return slowdown

func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO
	if Input.is_action_pressed(&"move_up"):
		input_vector += Vector2.UP
	if Input.is_action_pressed(&"move_down"):
		input_vector += Vector2.DOWN
	if Input.is_action_pressed(&"move_right"):
		input_vector += Vector2.RIGHT
	if Input.is_action_pressed(&"move_left"):
		input_vector += Vector2.LEFT

	if dash_timer.is_stopped():
		var target_velocity := input_vector.normalized() * move_speed
		var acc := maxf((target_velocity - velocity).length(), 100.0) * acceleration * delta
		velocity = velocity.move_toward(target_velocity, acc)
	elif !input_vector.is_zero_approx():
		velocity = input_vector.normalized() * dash_speed

	if velocity.x < -0.01:
		sprite.scale.x = -1
	elif velocity.x > 0.01:
		sprite.scale.x = 1


	velocity *= current_slowdown()
	move_and_slide()

func _process(_delta: float) -> void:
	dash1_bar.value = dash1_cooldown.time_left
	dash2_bar.value = dash2_cooldown.time_left

func shoot() -> void:
	if !shoot_timer.is_stopped():
		return
	var direction := to_local(get_global_mouse_position() + Vector2(0, 108)).normalized()

	var bullet: Bullet = bullet_scene.instantiate()
	bullet.global_position = bullet_spawn_point.global_position
	bullet.velocity = direction * bullet_speed
	get_parent().add_child(bullet)
	shoot_timer.start()

func dash() -> void:
	if dash1_cooldown.is_stopped():
		dash1_cooldown.start()
	elif dash2_cooldown.is_stopped():
		dash2_cooldown.start()
		dash1_cooldown.paused = true
	else:
		return

	dash_timer.start()

func on_hit() -> void:
	if !dash_timer.is_stopped() or !iframe_timer.is_stopped():
		return
	health -= 1
	iframe_timer.start()
	health_bar.value = health
	if health <= 0:
		get_tree().reload_current_scene.call_deferred()

func spawn_slow_indicator(enemy: Node2D) -> void:
	var indicator := indicator_scene.instantiate()
	indicator.enemy = enemy
	indicator.camera = get_viewport().get_camera_2d()
	indicator.spawn_time = Time.get_ticks_msec()
	add_child(indicator)
	slowdown_indicators.push_back(indicator)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"shoot"):
		shoot()

	if event.is_action_pressed(&"dash"):
		dash()


func _on_dash_timer_timeout() -> void:
	velocity = velocity.limit_length(1.5 * move_speed)


func _on_dash_2_cooldown_timeout() -> void:
	dash1_cooldown.paused = false


func _on_shoot_cooldown_timeout() -> void:
	if Input.is_action_pressed(&"shoot"):
		shoot()
