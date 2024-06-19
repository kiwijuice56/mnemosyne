class_name Spike
extends CharacterBody2D

@export var init_velocity: Vector2 
@export var reflect_h: bool = false
@export var reflect_v: bool = false

var stuck: bool = false
 
func slice() -> void:
	%AnimationPlayer.speed_scale = 0.1
	stuck = true
	await get_tree().create_timer(0.1).timeout
	%AnimationPlayer.speed_scale = 1.5
	stuck = false

func _physics_process(delta: float) -> void:
	if init_velocity.x > 0 and %Right.is_colliding() or init_velocity.x < 0 and %Left.is_colliding():
		init_velocity.x *= -1
		clang()
	if init_velocity.y > 0 and %Bottom.is_colliding() or init_velocity.y < 0 and %Top.is_colliding():
		init_velocity.y *= -1
		clang()
	velocity = init_velocity if not stuck else Vector2()
	move_and_slide()

func clang() -> void:
	%ClangPlayer.play()
	%DestroyParticles.emitting = true
