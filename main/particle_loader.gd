class_name ParticleLoader
extends Node2D

@export var scenes: Array[PackedScene]

func _ready() -> void:
	for scene in scenes:
		var p := scene.instantiate()
		add_child(p)
		if p is CPUParticles2D:
			p.emitting = true
		p.global_position = Ref.player.global_position
		p.modulate.a = 0.001
