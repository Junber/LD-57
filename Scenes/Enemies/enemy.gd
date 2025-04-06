@tool
extends CharacterBody2D

enum Behavior {
	None, Charge
}

enum BulletType {
	None, Directed, Undirected, Aoe
}

enum Special {
	None, Slows, Shield
}

@export_group("General")
@export var max_health := 5
@export_file("*.txt") var death_text_file: String
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
@onready var text_position := $TextPosition

var health: int

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
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	if special == Special.Slows:
		get_player().spawn_slow_indicator(self)
	if special != Special.Shield:
		$Shield.queue_free()

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if behavior == Behavior.Charge:
		var direction := (get_player().global_position - global_position)
		velocity = direction.normalized() * movement_speed
		move_and_slide()
		if direction.length() < 200.0:
			for i in range(100):
				var angle := i * TAU / 100
				spawn_bullet(Vector2.UP.rotated(angle))
			queue_free()

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
	bullet.global_position = global_position
	bullet.velocity = direction * bullet_speed
	get_parent().add_child(bullet)

func spawn_death_text() -> void:
	var text := death_text_scene.instantiate()
	text.global_position = text_position.global_position
	text.set_text_from_file(death_text_file)
	get_parent().add_child(text)

func on_hit(_body: Node2D) -> void:
	if is_queued_for_deletion():
		return
	health -= 1
	health_bar.value = health
	get_player().on_hit_enemy()
	if health <= 0:
		spawn_death_text()
		queue_free()


func _on_timer_timeout() -> void:
	shoot()
