class_name Home
extends Decoration

func reset() -> void:
	%Tent.visible = false
	%Smoke.visible = false

func initialize(time: int) -> void:
	if randf() < 0.3:
		queue_free()
	
	if time <= 4:
		%Tent.frame = randi() % %Tent.hframes
		%Tent.visible = true
		%Smoke.visible = randf() < 0.3
