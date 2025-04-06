extends CharacterBody2D

enum SpecialAbility {
	None, Earbud, Notepad, Dog
}

@export var bullet_scene: PackedScene
@export var indicator_scene: PackedScene
@export var earbud_scene: PackedScene
@export var notepad_drawing_scene: PackedScene
@export var dog_scene: PackedScene

@export var move_speed := 1000.0
@export var acceleration := 7.0
@export var dash_speed := 3000.0
@export var bullet_speed := 2000.0
@export var max_health := 5
@export var ability_charge_time := 5.0
@export var ability_charge_per_hit := 1.0
@export var dash1_cooldown_time := 1.0
@export var dash2_cooldown_time := 2.0
@export var notepad_draw_length := 200

@onready var shoot_timer: Timer = $ShootCooldown
@onready var iframe_timer: Timer = $IFrame
@onready var dash_timer: Timer = $DashTimer
@onready var dash1_cooldown: Timer = $Dash1Cooldown
@onready var dash2_cooldown: Timer = $Dash2Cooldown
@onready var health_bar: Range = $UI/Health
@onready var dash1_bar: Range = $UI/Dash1
@onready var dash2_bar: Range = $UI/Dash2
@onready var ability_charge_bar: Range = $UI/AbilityCharge

@onready var sprite: Node2D = $Sprites
@onready var bullet_spawn_point: Node2D = $Sprites/BulletSpawnPosition

var health: int
var slowdown_indicators: Array[Node] = []
var ability_charge := 0.0
var notepad_draw_start: Vector2
var notepad_drawing := false

var ability := SpecialAbility.None
var has_shot_upgrade := false
var has_dash_upgrade := false

func _ready() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	ability_charge_bar.visible = false
	ability_charge_bar.max_value = ability_charge_time

func current_slowdown() -> float:
	var time := Time.get_ticks_msec()
	var slowdown := 1.0
	var index_to_remove := -1
	for i in range(slowdown_indicators.size()):
		var indicator = slowdown_indicators[i]
		if indicator:
			slowdown *= 1.0 / pow(1 + (time - indicator.spawn_time) * 0.0005, 0.4)
		else:
			index_to_remove = i
	if index_to_remove >= 0:
		slowdown_indicators.remove_at(index_to_remove)
	return slowdown

func _physics_process(delta: float) -> void:
	var input_vector := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")

	if dash_timer.is_stopped():
		var target_velocity := input_vector * move_speed
		var acc := maxf((target_velocity - velocity).length(), 100.0) * acceleration * delta
		velocity = velocity.move_toward(target_velocity, acc)
	elif !input_vector.is_zero_approx():
		velocity = input_vector * dash_speed

	if velocity.x < -0.01:
		sprite.scale.x = -1
	elif velocity.x > 0.01:
		sprite.scale.x = 1


	velocity *= current_slowdown()
	move_and_slide()

func _process(delta: float) -> void:
	dash1_bar.value = dash1_cooldown.time_left
	dash2_bar.value = dash2_cooldown.time_left
	dash1_bar.max_value = dash1_cooldown.wait_time
	dash2_bar.max_value = dash2_cooldown.wait_time
	ability_charge += delta
	ability_charge_bar.value = ability_charge

	if notepad_drawing:
		var mouse_pos = get_global_mouse_position()
		if (mouse_pos - notepad_draw_start).length() >= notepad_draw_length:
			var end_pos = notepad_draw_start + (mouse_pos - notepad_draw_start).limit_length(notepad_draw_length)
			spawn_notepad_drawing(notepad_draw_start, end_pos)
			notepad_drawing = false

func spawn_notepad_drawing(start: Vector2, end: Vector2) -> void:
	var drawing: Node = notepad_drawing_scene.instantiate()
	drawing.set_end_points(start, end)
	get_parent().add_child(drawing)

func on_hit_enemy() -> void:
	ability_charge += ability_charge_per_hit

func shoot() -> void:
	if !shoot_timer.is_stopped():
		return
	var direction := to_local(get_global_mouse_position() + Vector2(0, 108)).normalized()
	spawn_bullet(direction)
	if has_shot_upgrade:
		spawn_bullet(direction.rotated(-0.1))
		spawn_bullet(direction.rotated(0.1))

func spawn_bullet(direction: Vector2) -> void:
	var bullet: Bullet = bullet_scene.instantiate()
	bullet.global_position = bullet_spawn_point.global_position
	bullet.velocity = direction * bullet_speed
	get_parent().add_child(bullet)
	shoot_timer.start()

func get_dash_time_mult() -> float:
	return 0.5 if has_dash_upgrade else 1.0

func dash() -> void:
	if dash1_cooldown.is_stopped():
		dash1_cooldown.start(dash1_cooldown_time * get_dash_time_mult())
	elif dash2_cooldown.is_stopped():
		dash2_cooldown.start(dash2_cooldown_time * get_dash_time_mult())
		dash1_cooldown.paused = true
	else:
		return

	dash_timer.start()

func use_special_ability() -> void:
	if ability_charge < ability_charge_time:
		return

	ability_charge = 0
	if ability == SpecialAbility.Earbud:
		var earbud: Node2D = earbud_scene.instantiate()
		earbud.global_position = get_global_mouse_position()
		get_parent().add_child(earbud)
	elif ability == SpecialAbility.Notepad:
		notepad_drawing = true
		notepad_draw_start = get_global_mouse_position()
	elif ability == SpecialAbility.Dog:
		var dog: Node2D = dog_scene.instantiate()
		dog.global_position = get_global_mouse_position()
		get_parent().add_child(dog)

func on_hit(_body: Node2D) -> void:
	if !dash_timer.is_stopped() or !iframe_timer.is_stopped():
		return
	#health -= 1
	iframe_timer.start()
	health_bar.value = health
	if health <= 0:
		get_tree().call_group(&"game", &"load_game", "auto_save")

func spawn_slow_indicator(enemy: Node2D) -> void:
	var indicator := indicator_scene.instantiate()
	indicator.enemy = enemy
	indicator.camera = get_viewport().get_camera_2d()
	indicator.spawn_time = Time.get_ticks_msec()
	bullet_spawn_point.add_child(indicator)
	slowdown_indicators.push_back(indicator)

func set_ability(new_ability_name: String) -> void:
	ability = SpecialAbility.get(new_ability_name, SpecialAbility.None)
	ability_charge = 0
	ability_charge_bar.visible = ability != SpecialAbility.None

func get_shot_upgrade() -> void:
	has_shot_upgrade = true

func get_dash_upgrade() -> void:
	has_dash_upgrade = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"shoot"):
		shoot()

	if event.is_action_pressed(&"dash"):
		dash()

	if event.is_action_pressed(&"special"):
		use_special_ability()
	elif event.is_action_released(&"special"):
		if notepad_drawing:
			notepad_drawing = false
			ability_charge = ability_charge_time


func _on_dash_timer_timeout() -> void:
	velocity = velocity.limit_length(1.5 * move_speed)


func _on_dash_2_cooldown_timeout() -> void:
	dash1_cooldown.paused = false


func _on_shoot_cooldown_timeout() -> void:
	if Input.is_action_pressed(&"shoot"):
		shoot()

func set_combat(_in_combat: bool) -> void:
	health = max_health
	health_bar.value = health


func get_save_data() -> Array:
	return [has_shot_upgrade, has_dash_upgrade, ability, ability_charge, global_position]

func load_save_data(data: Array) -> void:
	has_shot_upgrade = data[0]
	has_dash_upgrade = data[1]
	ability = data[2]
	ability_charge = data[3]
	global_position = data[4]
	health = max_health

	ability_charge_bar.visible = ability != SpecialAbility.None
	health_bar.value = health
