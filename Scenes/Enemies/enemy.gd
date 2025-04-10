@tool
extends CharacterBody2D

signal walking(walking: bool, left: bool)

enum Behavior {
	None, Charge, Random, Distant, Close, Circling
}

enum BulletType {
	None, Directed, Undirected, Aoe
}

enum Special {
	None, Slows
}

@export_group("General")
@export var max_health := 5
@export_file("*.txt") var death_text_file: String
@export_file("*.txt") var bullet_text_file: String
@export var death_text_scene: PackedScene

@export_group("Movement")
@export var behavior: Behavior

@export var movement_speed := 400.0

@export_group("Bullets")
@export var bullet_type: BulletType:
	set(value):
		bullet_type = value
		notify_property_list_changed()

@export var bullet_scene: PackedScene
@export var bullet_speed := 500.0

@export var bullet_amount := 10

@export_group("Special")
@export var special: Special

@onready var health_bar := $Health
@onready var spawn_position := $SpawnPosition

var health: int
var was_walking := false
var was_left := false
var was_circling := false

func _validate_property(property: Dictionary):
	if property.name == "movement_speed" and behavior == Behavior.None:
		property.usage = PROPERTY_USAGE_NO_EDITOR

	if property.name == "bullet_amount" and bullet_type != BulletType.Undirected:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "bullet_speed" and bullet_type in [BulletType.None, BulletType.Aoe]:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "bullet_scene" and bullet_type == BulletType.None:
		property.usage = PROPERTY_USAGE_NO_EDITOR

func get_player() -> Node2D:
	return get_tree().get_first_node_in_group(&"player")

func _ready() -> void:
	$Timer.wait_time *= randf_range(0.8, 1.2)
	health = max_health
	health_bar.max_value = max_health
	health_bar.set_value(health)
	if special == Special.Slows:
		get_player().spawn_slow_indicator(spawn_position)

func move() -> void:
	if behavior == Behavior.Charge:
		var direction := (get_player().global_position - global_position)
		velocity = direction.normalized() * movement_speed
		move_and_slide()
		if direction.length() < 200.0:
			for i in range(100):
				var angle := i * TAU / 100
				spawn_bullet(Vector2.UP.rotated(angle))
			queue_free()
	elif behavior == Behavior.Random:
		if randf() < 0.05:
			if randf() < 0.1:
				velocity = Vector2.ZERO
			else:
				velocity = Vector2.UP.rotated(randf() * TAU) * movement_speed
		move_and_slide()
	elif behavior == Behavior.Distant:
		var direction := (get_player().global_position - global_position)
		if direction.length() < (800.0 if was_walking else 700.0):
			velocity = -direction.normalized() * movement_speed
			move_and_slide()
		else:
			velocity = Vector2.ZERO
	elif behavior == Behavior.Close:
		var direction := (get_player().global_position - global_position)
		if direction.length() > (500.0 if was_walking else 600.0):
			velocity = direction.normalized() * movement_speed
			move_and_slide()
		else:
			velocity = Vector2.ZERO
	elif behavior == Behavior.Circling:
		var direction := (get_player().global_position - global_position)
		if direction.length() > (700.0 if !was_circling else 1200.0):
			was_circling = false
			velocity = direction.normalized() * movement_speed
		else:
			was_circling = true
			velocity = direction.normalized().rotated(PI / 2.0 - 0.03) * movement_speed
		if move_and_slide():
			velocity = direction.normalized() * movement_speed
			move_and_slide()

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var old_position := position
	move()

	var new_walking := (position - old_position).length() > 0.5
	var new_left := velocity.x < 0 if new_walking else \
		get_player().global_position.x < global_position.x
	if new_walking != was_walking or new_left != was_left:
		walking.emit(new_walking, new_left)
		was_walking = new_walking
		was_left = new_left

func shoot() -> void:
	if bullet_type == BulletType.Directed:
		var direction = (get_player().global_position - global_position).normalized()
		spawn_bullet(direction)
	elif bullet_type == BulletType.Undirected:
		for i in range(bullet_amount):
			var angle := i * TAU / bullet_amount
			spawn_bullet(Vector2.UP.rotated(angle))
	elif bullet_type == BulletType.Aoe:
		var aoe: Node2D = bullet_scene.instantiate()
		aoe.global_position = get_player().global_position
		get_parent().add_child(aoe)

func spawn_bullet(direction: Vector2) -> void:
	var bullet: Bullet = bullet_scene.instantiate()
	bullet.global_position = spawn_position.global_position
	bullet.velocity = direction * bullet_speed
	get_parent().add_child(bullet)
	if !bullet_text_file.is_empty():
		bullet.set_text_from_file(bullet_text_file)

func spawn_death_text() -> void:
	var text := death_text_scene.instantiate()
	text.global_position = spawn_position.global_position
	text.set_text_from_file(death_text_file)
	get_parent().add_child(text)

func on_hit(_body: Node2D) -> void:
	if is_queued_for_deletion():
		return
	health -= 1
	health_bar.set_value(health)
	get_player().on_hit_enemy()
	if health <= 0:
		spawn_death_text()
		queue_free()


func _on_timer_timeout() -> void:
	shoot()
