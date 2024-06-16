class_name Human
extends Actor

@export var gravity: float = 300

func _physics_process(delta: float) -> void:
	if not is_on_floor_only():
		velocity.y += gravity * delta
	else:
		velocity.y = gravity
	if not locked:
		move_and_slide()
