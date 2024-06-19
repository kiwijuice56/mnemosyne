class_name Flash
extends Sprite2D

func _ready() -> void:
	$AnimationPlayer.animation_finished.connect(die)

func die(_anim: String) -> void:
	queue_free()
