class_name Main
extends Node

@export var world_scene: PackedScene

var world: World
var time: int = 8

func _ready() -> void:
	Ref.player.died.connect(_on_player_died)
	
	get_tree().paused = true
	%PauseMenu.can_pause = false
	
	var intro_lines: Array[String] = [
		"breathe.___",
		"i have given you the gift of life.___",
		"knowledge._\nhope.\n_despair.___",
		"._._.__",
		"this realm is missing its ruler.___",
		"you, _my lustrous white canvas,_ can decide its fate.___",
		"your physical form is a reflection of humanity's faith in you.___",
		"._._.__",
		"will you be remembered as humanity's shining star,___",
		"or as a catalyst of savage chaos?___",
		"._._.__",
		"come, to the throne of creation.___"]
	#await %Cutscene.show_lines(intro_lines)
	await %Cutscene.trans_out()
	get_tree().paused = false
	
	start_level()
	%PauseMenu.can_pause = true

func _on_player_died(_p: Vector2) -> void:
	time += 1
	
	
	await %Cutscene.trans_in()
	get_tree().paused = true
	var before_lines: Array[String] = [
		"oh?___ back so soon.___",
		"come,_ now._._._ you aren't quite ready to meet the infinite void.___",
	]
	await %Cutscene.show_lines(before_lines)
	
	if abs(Ref.player.alignment) <= 0.1:
		var neutral_lines: Array[String] = [
			"you didn't leave much of an impression on humanity,_ did you?___",
		]
		await %Cutscene.show_lines(neutral_lines)
	elif Ref.player.alignment <= -0.6:
		var true_daemon_lines: Array[String] = [
			"oh my._._._ you're set on dominating humanity,_ aren't you?___",
			"well._._.__",
		]
		await %Cutscene.show_lines(true_daemon_lines)
	elif Ref.player.alignment >= 0.6:
		var true_human_lines: Array[String] = [
			"ah._._.__ what is this warmth i sense?___",
			"i envy humanity's appreciation for you._._.__",
		]
		await %Cutscene.show_lines(true_human_lines)
	elif Ref.player.alignment < 0:
		var daemon_lines: Array[String] = [
			"say,_ you left quite the mark._._.__",
			"maybe humanity can still forgive your murders?___",
			"if that's what you want, anyways._._.__"
		]
		await %Cutscene.show_lines(daemon_lines)
	elif Ref.player.alignment > 0:
		var human_lines: Array[String] = [
			"it seems that humanity is starting to grow on you._._.__",
			"hopefully the daemons don't mind?___",
		]
		await %Cutscene.show_lines(human_lines)
	
	var death_lines: Array[String] = [
			"rest now,_ my child._._.__",
			"another century of sleep or so will do you some good._._.__",
			"._._._____"
		]
	await %Cutscene.show_lines(death_lines)
	
	start_level()
	get_tree().paused = false
	
	await %Cutscene.trans_out()

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
