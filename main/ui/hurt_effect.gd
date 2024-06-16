class_name HurtEffect
extends ColorRect

func hurt() -> void:
	$AnimationPlayer.play("hurt")
