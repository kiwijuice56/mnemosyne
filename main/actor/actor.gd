class_name Actor
extends CharacterBody2D

@export var max_health: float
@export var speed: float
@export var accel: float = 16.0
@export var knockback_scale: float = 1.0

var target_scene: PackedScene = preload("res://main/target/target.tscn")
var exclaim_scene: PackedScene = preload("res://main/exclaim/exclaim.tscn")
var hurt_by: Array[Actor]


var health: float = 0:
	set(val):
		health = val
		%HealthBar.max_value = max_health
		%HealthBar.value = health
var dead: bool = false

var locked: bool = false

var knockback: Vector2
var dir: Vector2 

signal died(global_death_position: Vector2)

@export var shoot_offset: Vector2

func _ready() -> void:
	health = max_health
	hurt_by = []
	
	%HurtArea2D.area_entered.connect(_on_area_entered_hurt)

func _on_area_entered_hurt(area: Area2D) -> void:
	if dead:
		return
	
	if area.get_parent() is Bullet:
		var bullet: Bullet = area.get_parent() as Bullet
		if bullet.destroyed or bullet.shooter == self or self in bullet.has_hit:
			return
		
		if bullet.shooter == Ref.player:
			Ref.player.hit_enemy()
		hurt_by.append(bullet.shooter)
		hurt(bullet.damage, (global_position - area.global_position).normalized())
		bullet.hit(self)
	if area.get_parent() is Spike:
		hurt(max_health * 0.25, (global_position - area.global_position).normalized(), 2.0)
		area.get_parent().slice()

func _physics_process(delta: float) -> void:
	if dir.is_zero_approx():
		velocity = lerp(velocity, Vector2(), delta * accel)
	else:
		velocity = lerp(velocity, dir * speed, delta * accel)
	velocity = min(speed, velocity.length()) * velocity.normalized()
	
	velocity += knockback
	knockback = lerp(knockback, Vector2(), delta * accel * 0.75)
	if not locked:
		move_and_slide()

func initialize(time: int) -> void:
	reset()

func reset() -> void:
	pass

func kill() -> void:
	%HealthBar.visible = false
	if dead:
		return
	died.emit(global_position)
	dead = true
	queue_free()

func hurt(damage: float, hurt_dir: Vector2, knockback_extra: float = 1.0) -> bool:
	if dead:
		return false
	
	knockback = hurt_dir * 48.0 * knockback_scale * knockback_extra
	
	health -= damage
	health = max(0, min(max_health, health))
	if health == 0:
		kill()
		knockback *= 1.5
	return true

func lock_on(other_target: Actor) -> void:
	var my_target: Exclaim = exclaim_scene.instantiate()
	my_target.target = self
	get_parent().add_child(my_target)
	my_target.offset_p = Vector2(0, -8.0)
	
	var their_target: Target = target_scene.instantiate()
	their_target.target = other_target
	get_parent().add_child(their_target)
	their_target.offset_p = Vector2(randf() - 0.5, randf() - 0.5) * 8.0

func shoot(bullet_scene: PackedScene, shoot_dir: Vector2) -> bool:
	if dead:
		return false
	
	if not %ShootCooldownTimer.is_stopped():
		return false
	
	var new_bullet: Bullet = bullet_scene.instantiate()
	get_parent().add_child(new_bullet)
	get_parent().move_child(new_bullet, get_index())
	new_bullet.global_position = global_position + shoot_offset
	new_bullet.shooter = self
	new_bullet.shoot(shoot_dir, velocity)
	
	%ShootCooldownTimer.start(new_bullet.cooldown)
	return true
