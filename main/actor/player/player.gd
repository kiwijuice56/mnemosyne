class_name Player
extends Actor

@export var primary_bullet_scene: PackedScene
@export var tentacle_scene: PackedScene
@export var tentacle_material: ShaderMaterial

@export var tentacle_speed_min: float = 5.0
@export var tentacle_speed_max: float = 16.0

var tentacle_time: float = 0.0
var tentacle_speed: float = 8.0
var tentacle_count: int = 8

func _ready() -> void:
	initialize()

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
	
	if dir.length() > 0:
		tentacle_speed = lerp(tentacle_speed, tentacle_speed_max, delta * 8.0)
	else:
		tentacle_speed = lerp(tentacle_speed, tentacle_speed_min, delta * 4.0)
	tentacle_time += tentacle_speed * delta
	tentacle_material.set_shader_parameter("s", tentacle_time)
	
	super._physics_process(delta)

func initialize() -> void:
	for i in range(tentacle_count):
		var new_tentacle: Sprite2D = tentacle_scene.instantiate()
		%TentacleHolder.add_child(new_tentacle)
		new_tentacle.rotation = i * 2 * PI / tentacle_count

func shoot(bullet_scene: PackedScene, shoot_dir: Vector2) -> bool:
	if super.shoot(bullet_scene, shoot_dir):
		%SecondaryAnimationPlayer.play("shoot")
		return true
	return false