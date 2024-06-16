class_name Human
extends Actor

@export var gravity: float = 300

func _ready() -> void:
	super._ready()
	if randf() < 0.5:
		$SpriteHolder.scale.x *= -1

func _physics_process(delta: float) -> void:
	if not is_on_floor_only():
		velocity.y += gravity * delta
	else:
		velocity.y = gravity
	if not locked:
		move_and_slide()

func kill() -> void:
	if dead:
		return
	dead = true
	%AnimationPlayer.play("die")
	await %AnimationPlayer.animation_finished
	queue_free()
