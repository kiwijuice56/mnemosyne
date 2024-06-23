class_name Daemon
extends Actor

@export var primary_bullet_scene: PackedScene
@export var gravity: float = 400.0
@export var tentacle_speed: float = 16.0
@export var tentacle_material: ShaderMaterial

var tentacle_time: float
var target: Actor = null
var approach: float = 0

var potential_targets: Array[Actor]

func _ready() -> void:
	super._ready()
	%HealthBar.hide_bar()
	
	%ScreamPlayer.pitch_scale = randf_range(0.6, 1.1)
	%DetectionArea2D.body_entered.connect(_on_body_entered)
	%DetectionArea2D.body_exited.connect(_on_body_exited)
	
	%RetargetTimer.timeout.connect(retarget)
	
	tentacle_material = tentacle_material.duplicate()
	for child in %TentacleHolder.get_children():
		child.material = tentacle_material

func _on_body_entered(node: Node) -> void:
	if node in potential_targets or node.dead:
		return
	if node is Player and not dead:
		%HealthBar.show_bar()
	node.died.connect(_on_target_died.bind(node))
	potential_targets.append(node)
	retarget()

func _on_body_exited(node: Node) -> void:
	if node == target:
		target = null
	if node in potential_targets:
		if node is Player:
			%HealthBar.hide_bar()
		
		node.died.disconnect(_on_target_died)
		potential_targets.remove_at(potential_targets.find(node))
	retarget()


func _on_area_entered_hurt(area: Area2D) -> void:
	if dead:
		return
	
	if area.get_parent() is Bullet:
		var bullet: Bullet = area.get_parent() as Bullet
		if bullet.destroyed or bullet.shooter == self or self in bullet.has_hit:
			return
		if is_instance_valid(bullet.shooter) and bullet.shooter is Daemon:
			return
		if bullet.shooter == Ref.player:
			Ref.player.hit_enemy()
		if bullet.shooter:
			hurt_by.append(bullet.shooter)
		hurt(bullet.damage, (global_position - area.global_position).normalized())
		bullet.hit(self)
	if area.get_parent() is Spike:
		hurt(max_health * 0.25, (global_position - area.global_position).normalized(), 2.0)
		area.get_parent().slice()

func _on_target_died(_position: Vector2, actor: Actor) -> void:
	_on_body_exited(actor)

func _physics_process(delta: float) -> void:
	if not on_screen:
		return
	
	tentacle_time += tentacle_speed * delta
	tentacle_material.set_shader_parameter("s", tentacle_time)
	
	if is_instance_valid(target) and not dead:
		shoot(primary_bullet_scene, (target.global_position - global_position).normalized())
		
		var dist: float = (target.global_position - global_position).length() 
		approach = lerp(approach, dist - (64.0 if target is Player else 56.0), delta)
		approach = clamp(approach, -1, 1)
		dir = (target.global_position - global_position).normalized() * approach + Vector2(cos(tentacle_time * 0.2), sin(tentacle_time * 0.2)) * 0.36
	
	if dead:
		if not is_on_floor():
			dir.y += gravity * delta
		else:
			dir.y = 8
		velocity = dir + knockback
		knockback = lerp(knockback, Vector2(), delta * accel * 0.25)
		move_and_slide()
	else:
		super._physics_process(delta)

func retarget() -> void:
	if dead:
		return
	
	var dist: float = INF
	var old_target: Actor = target
	target = null
	for actor in potential_targets:
		var test_dist: float = (actor.global_position - global_position).length()
		if test_dist < dist or actor in hurt_by:
			if actor is Player and not actor in hurt_by:
				if randf() < 0.3 - actor.alignment:
					continue
			
			dist = test_dist
			target = actor
	
	if old_target != target and target:
		lock_on(target)

func hurt(damage: float, hurt_dir: Vector2, knockback_extra: float = 1.0) -> bool:
	if super.hurt(damage, hurt_dir, knockback_extra):
		if health > 0:
			%AnimationPlayer.stop()
			%AnimationPlayer.play("hurt")
		return true
	return false

func kill() -> void:
	if dead:
		return
	%HealthBar.hide_bar()
	if Ref.player in hurt_by:
		Ref.player.alignment += 0.05
	died.emit(global_position)
	%AnimationPlayer.stop()
	%AnimationPlayer.play("die")
	dead = true
	await %AnimationPlayer.animation_finished

func shoot(bullet_scene: PackedScene, shoot_dir: Vector2) -> bool:
	if %ShootBeforeTimer.is_stopped():
		%ShootBeforeTimer.start(0.5)
	else:
		return false
	await %ShootBeforeTimer.timeout
	if super.shoot(bullet_scene, shoot_dir):
		# do something later
		return true
	return false
