class_name Main
extends Node

var time: int = 0

func _ready() -> void:
	start_level()

func start_level() -> void:
	for node in get_tree().get_nodes_in_group("Evolving"):
		node.initialize(time)
