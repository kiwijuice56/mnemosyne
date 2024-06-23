class_name Bullet
extends CharacterBody2D

@export var speed: float
@export var damage: float
@export var pierce: int
@export var lifetime: float = 4.0
@export var bounce_amount: int = 0
@export var cooldown: float = 0.3

var bounces: int = 0
var hits: int = 0
var flash_range: float = 12.0

var has_hit: Array[Actor]

# unused for now
var shooter_velocity: Vector2

var dir: Vector2
var destroyed: bool = false
var shooter: Actor

func _ready() -> void:
	%HitArea2D.body_entered.connect(_on_body_entered)
	%LifeTimer.timeout.connect(destroy)
	%LifeTimer.start(lifetime)
	has_hit = []

func _on_body_entered(_body: Node) -> void:
	destroy()

func _physics_process(delta: float) -> void:
	if destroyed:
		return
	
	velocity = dir.normalized() * speed 
	var collision: KinematicCollision2D = move_and_collide(velocity)
	if collision:
		if bounces >= bounce_amount:
			destroy()
		bounces += 1
		dir = dir.bounce(collision.get_normal())
		bounce()

func shoot(shoot_dir: Vector2, velocity: Vector2) -> void:
	var flash: Sprite2D = %Flash
	remove_child(flash)
	get_parent().add_child(flash)
	get_parent().move_child(flash, get_index())
	flash.global_position = global_position + shoot_dir * flash_range
	
	dir = shoot_dir
	shooter_velocity = velocity

func hit(target: Actor) -> void:
	has_hit.append(target)
	hits += 1
	if hits >= pierce:
		destroy()

func destroy() -> void:
	if destroyed:
		return
	destroyed = true
	queue_free()

func bounce() -> void:
	pass
