class_name Human
extends Actor

@export var fear_speed: float
@export var gravity: float = 128

@onready var old_weapon: PackedScene = preload("res://main/bullet/ball/ball.tscn")
@onready var mid_weapon: PackedScene = preload("res://main/bullet/spear/spear.tscn")
@onready var new_weapon: PackedScene = preload("res://main/bullet/rifle/rifle.tscn")

var weapon: PackedScene

var state: String = "idle"
var group: Array[Human]
var can_fight: bool = false
var fear_spot: Vector2

var potential_targets: Array[Actor]
var target: Actor = null

func _ready() -> void:
	super._ready()
	
	shoot_offset = Vector2(0.0, -5)
	%MoveTimer.start(randf_range(0.7, 3.5))
	%DetectionArea2D.body_entered.connect(_on_body_entered_detection)
	%DetectionArea2D.body_exited.connect(_on_body_exited_detection)
	%MoveTimer.timeout.connect(_on_idle_timeout)
	%RetargetTimer.timeout.connect(retarget)
	if randf() < 0.5:
		$SpriteHolder.scale.x *= -1

func _on_body_entered_detection(body: Node) -> void:
	if body is Human:
		var human: Human = body as Human
		if human.dead or human in group:
			return
		human.died.connect(_on_friend_died)
		group.append(human)
	else:
		if not can_fight:
			return
		if body in potential_targets or body.dead:
			return
		body.died.connect(_on_target_died.bind(body))
		potential_targets.append(body)
		retarget()

func _on_body_exited_detection(body: Node) -> void:
	if body is Human:
		var human: Human = body as Human
		if human in group:
			human.died.disconnect(_on_friend_died)
			group.remove_at(group.find(human))
	else:
		if not can_fight:
			return
		
		if body == target:
			target = null
		if body in potential_targets:
			body.died.disconnect(_on_target_died)
			potential_targets.remove_at(potential_targets.find(body))
		retarget()

func _on_area_entered_hurt(area: Area2D) -> void:
	if dead:
		return
	
	if area.get_parent() is Bullet:
		var bullet: Bullet = area.get_parent() as Bullet
		if bullet.destroyed or bullet.shooter == self or self in bullet.has_hit:
			return
		if is_instance_valid(bullet.shooter) and bullet.shooter is Human:
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
	_on_body_exited_detection(actor)

func _on_friend_died(global_death_position: Vector2) -> void:
	if can_fight:
		state = "fight"
	else:
		state = "scared"
	fear_spot = global_death_position + Vector2(randf() - 0.5, randf() - 0.5) * 32

func _on_idle_timeout() -> void:
	if state == "idle":
		dir.x = (-1 if randf() < 0.5 else 1) if randf() < 0.5 else 0

func _physics_process(delta: float) -> void:
	if not on_screen:
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 8
	
	if state == "idle" and not dead:
		if dir.x == 1 and (not %RightFloor.is_colliding() or %RightForward.is_colliding()):
			dir.x = 0
		if dir.x == -1 and (not %LeftFloor.is_colliding() or %LeftForward.is_colliding()):
			dir.x = 0
		velocity.x = dir.x * speed
	
	if (state == "scared" or state == "fight") and not dead:
		dir.x = sign(global_position.x - fear_spot.x)
		if state == "fight":
			dir.x *= -1
		if fear_spot.distance_to(global_position) > 128.0:
			state = "idle" 
		velocity.x = dir.x * fear_speed
	
	if dead:
		dir = Vector2()
		velocity.x = lerp(velocity.x, 0.0, delta * 16)
	
	if not dead and can_fight and is_instance_valid(target):
		shoot(weapon, (target.global_position - global_position).normalized())
	
	velocity += knockback
	knockback = lerp(knockback, Vector2(), delta * accel * 0.75)
	
	if not locked:
		move_and_slide()

func retarget() -> void:
	if dead:
		return
	if not can_fight:
		return
	
	var dist: float = INF
	var old_target: Actor = target
	target = null
	for actor in potential_targets:
		var test_dist: float = (actor.global_position - global_position).length()
		if test_dist < dist or actor in hurt_by:
			if actor is Player and not actor in hurt_by:
				if randf() < actor.alignment + 0.5:
					continue
			
			dist = test_dist
			target = actor
	
	if old_target != target and target:
		lock_on(target)

func kill() -> void:
	if dead:
		return
	if Ref.player in hurt_by:
		Ref.player.alignment -= 0.05
	died.emit(global_position)
	dead = true
	%AnimationPlayer.play("die")
	await %AnimationPlayer.animation_finished
	queue_free()

func initialize(time: int) -> void:
	if randf() < 0.35:
		queue_free()
	
	var weapon_bank: Array[PackedScene] = []
	weapon_bank.append(old_weapon)
	if time >= 2:
		weapon_bank.append(mid_weapon)
	if time >= 4:
		weapon_bank.append(new_weapon)
	weapon = weapon_bank.pick_random()
	can_fight = randf() < 0.4 - Ref.player.alignment * 0.25

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

