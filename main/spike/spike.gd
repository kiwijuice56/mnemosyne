class_name Spike
extends CharacterBody2D

func slice() -> void:
	%AnimationPlayer.speed_scale = 0.1
	await get_tree().create_timer(0.2).timeout
	%AnimationPlayer.speed_scale = 1.0
