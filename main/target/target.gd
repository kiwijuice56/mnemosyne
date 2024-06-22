class_name Target
extends Sprite2D

var target: Actor

var offset_p: Vector2

func _ready() -> void:
	%AnimationPlayer.play("target")
	await %AnimationPlayer.animation_finished
	queue_free()

func _physics_process(delta: float) -> void: 
	global_position = target.global_position + offset
