class_name Actor
extends CharacterBody2D

@export var max_health: float
@export var speed: float
@export var accel: float = 16.0

var health: float = 0

var locked: bool = false

var dir: Vector2 

func _ready() -> void:
	health = max_health
	
	%HurtArea2D.area_entered.connect(_on_area_entered_hurt)

func _on_area_entered_hurt(area: Area2D) -> void:
	if area is Bullet:
		var bullet: Bullet = area as Bullet
		if bullet.destroyed:
			return
		hurt(area.damage)
		area.destroy()

func _physics_process(delta: float) -> void:
	if dir.is_zero_approx():
		velocity = lerp(velocity, Vector2(), delta * accel)
	else:
		velocity = lerp(velocity, dir * speed, delta * accel)
	velocity = min(speed, velocity.length()) * velocity.normalized()
	
	if not locked:
		move_and_slide()

func kill() -> void:
	queue_free()

func hurt(damage: int) -> void:
	health -= damage
	health = max(0, min(max_health, health))
	if health == 0:
		kill()

func shoot(bullet_scene: PackedScene, shoot_dir: Vector2) -> void:
	if not %ShootCooldownTimer.is_stopped():
		return
	
	var new_bullet: Bullet = bullet_scene.instantiate()
	get_parent().add_child(new_bullet)
	new_bullet.global_position = global_position
	new_bullet.shoot(shoot_dir, velocity)
	
	%ShootCooldownTimer.start(new_bullet.cooldown)
