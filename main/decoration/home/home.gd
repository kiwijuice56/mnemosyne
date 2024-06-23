class_name Home
extends Decoration

func reset() -> void:
	%Tent.visible = false
	%Smoke.visible = false
	%Middle.visible = false
	%New.visible = false

func initialize(time: int) -> void:
	if randf() < 0.15:
		queue_free()
	
	time += randi() % 2 
	
	if time <= 2:
		%Tent.frame = randi() % %Tent.hframes
		%Tent.visible = true
		%Smoke.visible = randf() < 0.3
	elif time <= 6:
		%Middle.frame = randi() % %Middle.hframes
		%Middle.visible = true
		%Smoke.visible = randf() < 0.3
	else:
		%New.frame = randi() % %New.hframes
		%New.visible = true
		%Smoke.visible = false
	
