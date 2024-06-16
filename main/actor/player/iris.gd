class_name Iris
extends Sprite2D

@export var speed: float = 8.0
@export var radius: float = 2.0

func _physics_process(delta: float) -> void:
	var mouse_dir: Vector2 = get_global_mouse_position() - get_parent().global_position
	if mouse_dir.length() > radius:
		mouse_dir = mouse_dir.normalized() * radius
	position = lerp(position, mouse_dir, delta * speed)
