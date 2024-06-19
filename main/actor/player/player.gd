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

var mood_potential_targets: Array[Actor]
var mood_target: Actor

func _ready() -> void:
	super._ready()
	%DetectionArea2D.body_entered.connect(_on_body_entered)
	%DetectionArea2D.body_exited.connect(_on_body_exited)
	%RetargetTimer.timeout.connect(retarget)

func _on_body_entered(node: Node) -> void:
	if node in mood_potential_targets or node.dead:
		return
	node.died.connect(_on_target_died.bind(node))
	mood_potential_targets.append(node)
	retarget()

func _on_body_exited(node: Node) -> void:
	if node == mood_target:
		mood_target = null
	if node in mood_potential_targets:
		node.died.disconnect(_on_target_died)
		mood_potential_targets.remove_at(mood_potential_targets.find(node))
	retarget()

func _on_target_died(_position: Vector2, actor: Actor) -> void:
	_on_body_exited(actor)

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
	
	var look_dir: Vector2 = get_global_mouse_position() - global_position
	look_dir = min(64, look_dir.length()) * look_dir.normalized()
	%ShakeCamera.center = lerp(%ShakeCamera.center, look_dir * 0.2, delta * 4)
	
	super._physics_process(delta)

func initialize(time: int) -> void:
	for i in range(tentacle_count):
		var new_tentacle: Sprite2D = tentacle_scene.instantiate()
		%TentacleHolder.add_child(new_tentacle)
		new_tentacle.rotation = i * 2 * PI / tentacle_count

func shoot(bullet_scene: PackedScene, shoot_dir: Vector2) -> bool:
	if super.shoot(bullet_scene, shoot_dir):
		%ShakeCamera.push = 6 * (global_position - get_global_mouse_position()).normalized()
		%SecondaryAnimationPlayer.play("shoot")
		return true
	return false

func hurt(damage: float, hurt_dir: Vector2, knockback_extra: float = 1.0) -> bool:
	if super.hurt(damage, hurt_dir, knockback_extra):
		%TertiaryAnimationPlayer.play("hurt")
		%ShakeCamera.shake(2.0)
		Ref.hurt_effect.hurt()
		return true
	return false

func retarget() -> void:
	var old_target: Actor = mood_target
	var dist: float = INF
	for actor in mood_potential_targets:
		var test_dist: float = (actor.global_position - global_position).length()
		if test_dist < dist:
			dist = test_dist
			mood_target = actor
	
	if mood_target == null:
		Ref.music.set_lead("normal")
		return
	
	if not old_target == mood_target:
		if mood_target is Daemon:
			Ref.music.set_lead("battle")
		else:
			Ref.music.set_lead("normal")

func hit_enemy() -> void:
	pass
	#%ShakeCamera.shake(0.9)
