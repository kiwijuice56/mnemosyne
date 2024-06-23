class_name Main
extends Node

@export var world_scene: PackedScene

var world: World
var time: int = 0

func _ready() -> void:
	start_level()
	Ref.player.died.connect(_on_player_died)

func _on_player_died(_p: Vector2) -> void:
	time += 1
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
