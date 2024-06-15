class_name Bullet
extends Area2D

@export var speed: float
@export var damage: float
@export var lifetime: float = 4.0
@export var cooldown: float = 0.3

# unused for now
var shooter_velocity: Vector2

var dir: Vector2
var destroyed: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	%LifeTimer.timeout.connect(destroy)
	%LifeTimer.start(lifetime)

func _on_body_entered(body: PhysicsBody2D) -> void:
	destroy()

func _physics_process(delta: float) -> void:
	position += dir.normalized() * speed * delta

func shoot(shoot_dir: Vector2, velocity: Vector2) -> void:
	dir = shoot_dir
	shooter_velocity = velocity

func destroy() -> void:
	if destroyed:
		return
	destroyed = true
