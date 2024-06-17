class_name Debris
extends Decoration

func initialize(time: int) -> void:
	if randf() < 0.2:
		queue_free()
	%Stuff.frame = randi() % %Stuff.hframes
	scale.x *= -1 if randf() < 0.5 else 1
