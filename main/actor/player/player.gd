class_name Player
extends Actor

@export var primary_bullet_scene: PackedScene

func _physics_process(delta: float) -> void:
	dir = Vector2()
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1
	if Input.is_action_pressed("ui_down"):
		dir.y += 1
	if Input.is_action_pressed("shoot"):
		shoot(primary_bullet_scene, (get_global_mouse_position() - global_position).normalized())
	super._physics_process(delta)

