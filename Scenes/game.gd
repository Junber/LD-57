extends Node2D

var in_combat := false
var force_combat := false

func _ready() -> void:
	get_tree().call_group(&"combat_listener", &"set_combat", in_combat)

func set_force_combat(new_force_combat: bool) -> void:
	force_combat = new_force_combat
	if force_combat and !in_combat:
		in_combat = true
		get_tree().call_group(&"combat_listener", &"set_combat", in_combat)

func _process(_delta: float) -> void:
	if !force_combat and in_combat:
		if get_tree().get_node_count_in_group(&"enemy") == 0:
			in_combat = false
			get_tree().call_group(&"combat_listener", &"set_combat", in_combat)
