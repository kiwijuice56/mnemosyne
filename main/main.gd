class_name Main
extends Node

@export var world_scene: PackedScene

var world: World
var time: int = 6

func _ready() -> void:
	start_level()

func start_level() -> void:
	if is_instance_valid(world):
		world.queue_free()
	world = world_scene.instantiate()
	%SubViewport.add_child(world)
	%SubViewport.move_child(world, 0)
	for node in get_tree().get_nodes_in_group("Evolving"):
		node.reset()
		node.initialize(time)
	%Player.global_position = world.get_node("%Spawn").global_position
